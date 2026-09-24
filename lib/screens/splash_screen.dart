import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../models/business_info.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/aparicion.dart';
import '../widgets/app_image.dart';
import '../widgets/app_logo.dart';
import '../widgets/primary_button.dart';
import 'login_screen.dart';

/// Pantalla de entrada.
///
/// Coreografía, toda sobre un único [AnimationController]:
///   1. Un círculo se abre desde el centro y revela la foto de fondo.
///   2. El logo cae desde arriba con rebote y levanta una nube de polvo.
///   3. El logo sube a su sitio y entran el texto y el botón "Comenzar".
///
/// Después de la animación el logo responde al arrastre (inclinación 3D con
/// rebote elástico) y a la inclinación del celular, y el texto se aparta
/// del dedo.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

/// Revela la foto con un círculo que crece desde el centro.
class _CircleRevealClipper extends CustomClipper<Path> {
  final double progress;
  const _CircleRevealClipper(this.progress);

  @override
  Path getClip(Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    // La diagonal/2 es el radio que alcanza las esquinas.
    final maxRadius =
        sqrt(size.width * size.width + size.height * size.height) / 2;
    return Path()
      ..addOval(Rect.fromCircle(center: center, radius: maxRadius * progress));
  }

  @override
  bool shouldReclip(covariant _CircleRevealClipper oldClipper) =>
      oldClipper.progress != progress;
}

/// Textura de puntitos sobre el fondo. Se pinta una vez y se cachea.
class _TexturaPuntos extends CustomPainter {
  const _TexturaPuntos();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.carbon.withValues(alpha: 0.04);
    const separacion = 26.0;
    for (double y = 0; y < size.height; y += separacion) {
      for (double x = 0; x < size.width; x += separacion) {
        canvas.drawCircle(Offset(x, y), 1.4, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Nube de polvo cuando el logo aterriza, como un sello contra la mesa.
class _PintorPolvo extends CustomPainter {
  final double progress;
  final Offset centro;
  final List<Offset> direcciones;

  const _PintorPolvo({
    required this.progress,
    required this.centro,
    required this.direcciones,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final paint = Paint()
      ..color = AppColors.mostaza.withValues(alpha: (1 - progress) * 0.45);
    for (final dir in direcciones) {
      final pos = centro + dir * (70 * progress);
      canvas.drawCircle(pos, 2.5 * (1 - progress) + 1, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _PintorPolvo oldDelegate) =>
      oldDelegate.progress != progress;
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  /// Todo el splash dura esto. Bajarlo acelera la coreografía completa.
  static const Duration _duracion = Duration(milliseconds: 3000);

  // Línea de tiempo, en fracciones de 0 a 1 del controlador.
  static const double _tRevelado = 0.26;
  static const double _tLogoDentro = 0.62;
  static const double _tLogoArriba = 0.80;

  /// Proporción real de assets/images/logo-parche.png (647 × 386). El logo NO es
  /// cuadrado: de aquí sale el alto, y con él el centro del polvo.
  static const double _proporcionLogo = 386 / 647;

  late final AnimationController _controller;
  late final Animation<double> _revelado;
  late final Animation<double> _logoOpacidad;
  late final Animation<double> _logoEscala;
  late final Animation<double> _logoCaida;
  late final Animation<double> _logoSube;
  late final Animation<double> _abajoOpacidad;

  // Pulso del botón.
  late final AnimationController _pulso;
  late final Animation<double> _pulsoEscala;

  // Polvo al aterrizar.
  late final AnimationController _polvo;
  bool _polvoLanzado = false;
  final List<Offset> _direccionesPolvo = List.generate(14, (i) {
    final angulo = (2 * pi / 14) * i;
    return Offset(cos(angulo), sin(angulo));
  });

  // Dónde está el dedo, para que el texto se aparte.
  final ValueNotifier<Offset?> _dedo = ValueNotifier<Offset?>(null);
  final GlobalKey _bloqueTexto = GlobalKey();

  // Arrastre del logo y su rebote elástico al soltar.
  final ValueNotifier<Offset> _arrastreLogo =
      ValueNotifier<Offset>(Offset.zero);
  late final AnimationController _resorte;
  Animation<Offset>? _resorteAnim;

  // Inclinación del celular. Va en un ValueNotifier para repintar solo el
  // logo y no toda la pantalla 60 veces por segundo.
  StreamSubscription<AccelerometerEvent>? _sensor;
  final ValueNotifier<Offset> _inclinacion = ValueNotifier<Offset>(Offset.zero);

  bool _imagenesPrecargadas = false;

  // Modo ligero: si el aparato no da abasto, se apagan los adornos.
  final Stopwatch _cronoFrame = Stopwatch();
  int _framesPesados = 0;
  bool _modoLigero = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: _duracion);

    // El círculo abre desde el primer frame: es lo primero que se ve.
    _revelado = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, _tRevelado, curve: Curves.easeOut),
    );
    _logoOpacidad = CurvedAnimation(
      parent: _controller,
      curve: const Interval(_tRevelado, _tLogoDentro, curve: Curves.easeOut),
    );
    _logoEscala = Tween<double>(begin: 0.6, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve:
            const Interval(_tRevelado, _tLogoDentro, curve: Curves.bounceOut),
      ),
    );
    _logoCaida = CurvedAnimation(
      parent: _controller,
      curve: const Interval(_tRevelado, _tLogoDentro, curve: Curves.bounceOut),
    );
    _logoSube = CurvedAnimation(
      parent: _controller,
      curve:
          const Interval(_tLogoDentro, _tLogoArriba, curve: Curves.easeInOut),
    );
    _abajoOpacidad = CurvedAnimation(
      parent: _controller,
      curve: const Interval(_tLogoArriba, 1, curve: Curves.easeOut),
    );

    _polvo = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _pulso = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pulsoEscala = Tween<double>(begin: 1, end: 1.04)
        .animate(CurvedAnimation(parent: _pulso, curve: Curves.easeInOut));

    _resorte = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..addListener(() {
        if (_resorteAnim != null) _arrastreLogo.value = _resorteAnim!.value;
      });

    _controller.addListener(_alAvanzar);
    _escucharSensor();
  }

  /// Dispara el polvo cuando el logo aterriza, arranca el pulso del botón
  /// cuando ya se ve, y vigila la fluidez.
  void _alAvanzar() {
    final t = _controller.value;

    if (!_polvoLanzado && t >= _tLogoDentro) {
      _polvoLanzado = true;
      _polvo.forward(from: 0);
    }
    // El pulso solo corre cuando el botón está en pantalla: un controlador
    // repitiendo para siempre deja el árbol animándose sin necesidad.
    if (t >= _tLogoArriba && !_pulso.isAnimating) {
      _pulso.repeat(reverse: true);
    }

    _vigilarFluidez();
  }

  /// sensors_plus no existe en web ni en escritorio, y en pruebas el plugin
  /// tampoco está: si falla, el splash se ve igual, solo sin parallax.
  void _escucharSensor() {
    try {
      _sensor = accelerometerEventStream(
        samplingPeriod: SensorInterval.uiInterval,
      ).listen((event) {
        if (!mounted) return;
        final x = (event.x / 9.8).clamp(-1.0, 1.0);
        final y = (event.y / 9.8).clamp(-1.0, 1.0);
        final actual = _inclinacion.value;
        // Filtro de ruido: solo avisa si el cambio se nota.
        if ((x - actual.dx).abs() > 0.03 || (y - actual.dy).abs() > 0.03) {
          _inclinacion.value = Offset(x, y);
        }
      }, onError: (_) {});
    } catch (_) {
      _sensor = null;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_imagenesPrecargadas) return;
    _imagenesPrecargadas = true;
    _precargarYArrancar();
  }

  /// Precarga el fondo y el logo antes de empezar; si tarda o falla, arranca
  /// igual y las imágenes entran cuando puedan.
  Future<void> _precargarYArrancar() async {
    final media = MediaQuery.of(context);
    final anchoMaximo = min(media.size.width * media.devicePixelRatio, 1440.0);

    final fondo = ResizeImage(
      const NetworkImage(BusinessInfo.fotoAmbiente),
      width: anchoMaximo.round(),
    );
    final logo = ResizeImage(
      const AssetImage(BusinessInfo.logo),
      width: (media.size.width * media.devicePixelRatio * 0.6).round(),
    );

    try {
      await Future.wait([
        // Sin onError, un fallo de red escupe la excepción a la consola
        // (y tumba las pruebas) aunque el splash sepa seguir sin la foto.
        precacheImage(fondo, context, onError: (_, __) {}),
        precacheImage(logo, context, onError: (_, __) {}),
      ]).timeout(const Duration(seconds: 3));
    } catch (_) {
      // Sin internet o sin tiempo: seguimos igual.
    }

    if (!mounted) return;
    FlutterNativeSplash.remove();
    _controller.forward();
  }

  @override
  void dispose() {
    // Todo lo que anima o escucha se apaga aquí: lo que quede vivo hace
    // fallar las pruebas y filtra memoria.
    _controller.dispose();
    _pulso.dispose();
    _polvo.dispose();
    _resorte.dispose();
    _sensor?.cancel();
    _cronoFrame.stop();
    _dedo.dispose();
    _arrastreLogo.dispose();
    _inclinacion.dispose();
    super.dispose();
  }

  // ─────────────────────────── Rendimiento ───────────────────────────

  /// Mide el tiempo entre avances del controlador. Si se acumulan tres de
  /// más de 40 ms durante el revelado, apaga los adornos y termina rápido.
  /// En debug no hace nada, para no estorbar al desarrollar ni en pruebas.
  void _vigilarFluidez() {
    if (_modoLigero || kDebugMode) return;

    if (_cronoFrame.isRunning) {
      if (_cronoFrame.elapsedMilliseconds > 40) {
        _framesPesados++;
        final t = _controller.value;
        if (_framesPesados >= 3 && t <= _tLogoDentro) {
          _activarModoLigero();
          return;
        }
      } else {
        _framesPesados = 0;
      }
    }
    _cronoFrame
      ..reset()
      ..start();
  }

  void _activarModoLigero() {
    setState(() => _modoLigero = true);
    _cronoFrame.stop();
    _inclinacion.value = Offset.zero;
    _sensor?.cancel();
    _sensor = null;
    _controller.animateTo(
      1,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  // ───────────────────────────── Interacción ─────────────────────────

  bool get _listo => _controller.value >= 0.95;

  void _entrar() {
    HapticFeedback.lightImpact();
    Navigator.of(context).pushReplacement(rutaConFundido(const LoginScreen()));
  }

  /// Cuánto se aparta el bloque de texto del dedo. Devuelve cero si el dedo
  /// está lejos o si el bloque todavía no está en pantalla.
  Offset _apartarTexto(Offset? dedo) {
    if (dedo == null) return Offset.zero;
    final caja = _bloqueTexto.currentContext?.findRenderObject() as RenderBox?;
    if (caja == null || !caja.attached) return Offset.zero;

    final centro = caja.localToGlobal(caja.size.center(Offset.zero));
    final delta = centro - dedo;
    final distancia = delta.distance;
    const radio = 170.0;
    if (distancia > radio || distancia == 0) return Offset.zero;

    final fuerza = (1 - distancia / radio) * 18;
    return Offset(delta.dx / distancia, delta.dy / distancia) * fuerza;
  }

  // ──────────────────────────────── Layout ───────────────────────────

  /// Reparte la pantalla entre logo, texto y botón. Si no alcanza el alto,
  /// encoge primero el logo y después el espacio, hasta que todo quepa.
  ({
    double logoAncho,
    double logoAlto,
    double logoTopFinal,
    double textoTop,
    double botonBottom,
    double botonAncho,
  }) _calcularLayout(Size size, EdgeInsets padding) {
    final ancho = size.width;
    final alto = size.height;
    const altoBoton = 52.0;
    // El nombre puede ocupar dos líneas (heading 21) más el tagline (15).
    const altoTexto = 2 * 21 * 1.25 * 1.15 + 12 + 15 * 1.5 * 1.15;

    final botonBottom = padding.bottom + max(24.0, alto * 0.05);
    final logoTopFinal = padding.top + alto * 0.06;
    final botonAncho = min(240.0, ancho - 64.0);

    double logoAncho = min(ancho * 0.66, alto * 0.30).clamp(150.0, 300.0);
    double espacio = 32;

    double libre() =>
        (alto - botonBottom - altoBoton) -
        (logoTopFinal + logoAncho * _proporcionLogo + espacio + altoTexto);

    while (libre() < 12 && (logoAncho > 150 || espacio > 20)) {
      if (logoAncho > 150) {
        logoAncho = max(150.0, logoAncho - 6);
      } else {
        espacio = max(20.0, espacio - 2);
      }
    }

    final logoAlto = logoAncho * _proporcionLogo;
    return (
      logoAncho: logoAncho,
      logoAlto: logoAlto,
      logoTopFinal: logoTopFinal,
      textoTop: logoTopFinal + logoAlto + espacio,
      botonBottom: botonBottom,
      botonAncho: botonAncho,
    );
  }

  // ──────────────────────────────── Pintura ──────────────────────────

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    // Con la letra del sistema al máximo el layout se desarma: se limita.
    return MediaQuery(
      data: media.copyWith(
        textScaler: media.textScaler.clamp(maxScaleFactor: 1.15),
      ),
      child: _construirSplash(media.size, media.padding),
    );
  }

  Widget _construirSplash(Size size, EdgeInsets padding) {
    final layout = _calcularLayout(size, padding);
    final logoCentrado = (size.height - layout.logoAlto) / 2;

    return Scaffold(
      backgroundColor: AppColors.crema,
      body: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (e) {
          if (!_listo) return;
          _dedo.value = e.localPosition;
        },
        onPointerMove: (e) {
          if (!_listo) return;
          _dedo.value = e.localPosition;
        },
        onPointerUp: (_) => _dedo.value = null,
        onPointerCancel: (_) => _dedo.value = null,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final t = _controller.value;
            // Dentro del builder: fuera quedaría congelado en el primer frame.
            final caidaY = (-size.height * 0.25) * (1 - _logoCaida.value);

            return Stack(
              children: [
                ..._fondoRevelado(size),
                _logo(layout, logoCentrado, caidaY),
                _texto(layout),
                _boton(layout, t),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Foto + velo crema (el logo es negro: sobre la foto sola no se leería)
  /// + textura de puntitos.
  List<Widget> _fondoRevelado(Size size) {
    return [
      Positioned.fill(
        child: RepaintBoundary(
          child: ClipPath(
            clipper: _CircleRevealClipper(_revelado.value),
            child: Stack(
              fit: StackFit.expand,
              children: [
                const AppImage(
                  '',
                  fallbackUrl: BusinessInfo.fotoAmbiente,
                  fit: BoxFit.cover,
                ),
                ColoredBox(color: AppColors.crema.withValues(alpha: 0.82)),
              ],
            ),
          ),
        ),
      ),
      if (!_modoLigero)
        const Positioned.fill(
          child: IgnorePointer(
            child: RepaintBoundary(
              child: CustomPaint(painter: _TexturaPuntos()),
            ),
          ),
        ),
    ];
  }

  /// El logo: cae, sube a su sitio, y después se deja arrastrar (inclinación
  /// 3D con rebote) y reacciona a la inclinación del celular.
  Widget _logo(
    ({
      double logoAncho,
      double logoAlto,
      double logoTopFinal,
      double textoTop,
      double botonBottom,
      double botonAncho,
    }) layout,
    double logoCentrado,
    double caidaY,
  ) {
    return Positioned(
      top: logoCentrado +
          (layout.logoTopFinal - logoCentrado) * _logoSube.value +
          caidaY,
      left: 0,
      right: 0,
      child: RepaintBoundary(
        child: ValueListenableBuilder<Offset>(
          valueListenable: _inclinacion,
          builder: (context, inclinacion, _) {
            return ValueListenableBuilder<Offset>(
              valueListenable: _arrastreLogo,
              builder: (context, arrastre, __) {
                return Center(
                  child: Opacity(
                    opacity: _logoOpacidad.value,
                    child: GestureDetector(
                      onPanUpdate: (d) {
                        _arrastreLogo.value = Offset(
                          (arrastre.dx + d.delta.dx / 40).clamp(-1.0, 1.0),
                          (arrastre.dy + d.delta.dy / 40).clamp(-1.0, 1.0),
                        );
                      },
                      onPanEnd: (_) {
                        _resorteAnim = Tween<Offset>(
                          begin: _arrastreLogo.value,
                          end: Offset.zero,
                        )
                            .chain(CurveTween(curve: Curves.elasticOut))
                            .animate(_resorte);
                        _resorte.forward(from: 0);
                      },
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.0015) // perspectiva
                          ..rotateX(-arrastre.dy * 0.4 - inclinacion.dy * 0.15)
                          ..rotateY(arrastre.dx * 0.4 + inclinacion.dx * 0.15)
                          ..rotateZ(arrastre.dx * 0.05)
                          ..scaleByDouble(
                            _logoEscala.value,
                            _logoEscala.value,
                            1,
                            1,
                          ),
                        child: SizedBox(
                          width: layout.logoAncho,
                          height: layout.logoAlto,
                          child: Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.center,
                            children: [
                              AppLogo(
                                height: layout.logoAlto,
                                mostrarNombre: false,
                              ),
                              if (!_modoLigero)
                                AnimatedBuilder(
                                  animation: _polvo,
                                  builder: (context, _) => CustomPaint(
                                    size: Size(
                                      layout.logoAncho,
                                      layout.logoAlto,
                                    ),
                                    painter: _PintorPolvo(
                                      progress: _polvo.value,
                                      // El logo es rectangular: el centro no
                                      // es (lado/2, lado/2).
                                      centro: Offset(
                                        layout.logoAncho / 2,
                                        layout.logoAlto / 2,
                                      ),
                                      direcciones: _direccionesPolvo,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _texto(
    ({
      double logoAncho,
      double logoAlto,
      double logoTopFinal,
      double textoTop,
      double botonBottom,
      double botonAncho,
    }) layout,
  ) {
    return Positioned(
      top: layout.textoTop,
      left: 32,
      right: 32,
      child: Opacity(
        opacity: _abajoOpacidad.value,
        child: IgnorePointer(
          child: ValueListenableBuilder<Offset?>(
            valueListenable: _dedo,
            builder: (context, dedo, _) {
              final apartar = _apartarTexto(dedo);
              return AnimatedContainer(
                key: _bloqueTexto,
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOut,
                transform: Matrix4.translationValues(apartar.dx, apartar.dy, 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      BusinessInfo.nombre,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.heading(size: 21),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Grandes delicias desde ${BusinessInfo.desde}',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.tagline(
                        size: 15,
                        color: AppColors.carbon,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _boton(
    ({
      double logoAncho,
      double logoAlto,
      double logoTopFinal,
      double textoTop,
      double botonBottom,
      double botonAncho,
    }) layout,
    double t,
  ) {
    return Positioned(
      bottom: layout.botonBottom,
      left: 32,
      right: 32,
      child: Opacity(
        opacity: _abajoOpacidad.value,
        child: IgnorePointer(
          // Hasta que no termina la animación el botón no se puede tocar.
          ignoring: t < 0.98,
          child: Center(
            child: AnimatedBuilder(
              animation: _pulso,
              builder: (context, child) =>
                  Transform.scale(scale: _pulsoEscala.value, child: child),
              child: SizedBox(
                width: layout.botonAncho,
                child: PrimaryButton(
                  label: 'Comenzar',
                  tamanoTexto: 15,
                  alto: 52,
                  onPressed: _entrar,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
