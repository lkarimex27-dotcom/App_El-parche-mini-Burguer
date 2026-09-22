import 'package:flutter/material.dart';
import '../models/business_info.dart';
import '../theme/app_text_styles.dart';
import '../widgets/aparicion.dart';
import '../widgets/app_image.dart';
import '../widgets/app_logo.dart';
import 'login_screen.dart';

/// Pantalla de entrada. El logo aparece con una animación suave (se acerca
/// y se aclara), el tagline entra después, y al final la app pasa al login
/// con un desvanecido en vez de un corte seco.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );

  late final Animation<double> _logoOpacidad = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
  );

  // Sin rebote: sube de tamaño y frena, que se sienta tranquilo.
  late final Animation<double> _logoEscala = Tween<double>(
    begin: 0.88,
    end: 1.0,
  ).animate(CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
  ));

  /// El fondo se acerca apenas un poco durante toda la entrada: da
  /// profundidad sin que se note el movimiento.
  late final Animation<double> _fondoEscala = Tween<double>(
    begin: 1.08,
    end: 1.0,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

  late final Animation<double> _taglineOpacidad = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.45, 0.85, curve: Curves.easeOut),
  );

  late final Animation<Offset> _taglineDesplazamiento = Tween<Offset>(
    begin: const Offset(0, 0.6),
    end: Offset.zero,
  ).animate(CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.45, 0.9, curve: Curves.easeOutCubic),
  ));

  @override
  void initState() {
    super.initState();
    _controller.forward();

    // Da tiempo a que termine la entrada y se alcance a leer el tagline.
    Future.delayed(const Duration(milliseconds: 2600), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(rutaConFundido(const LoginScreen()));
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Foto de ingredientes/hamburguesas de fondo, acercándose apenas.
          ScaleTransition(
            scale: _fondoEscala,
            child: const AppImage(
              'assets/images/splash_bg.jpg',
              fallbackUrl: BusinessInfo.fotoAmbiente,
              fit: BoxFit.cover,
            ),
          ),
          // Gradiente ámbar cálido sobre la foto
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xCCD29A42),
                  Color(0xE6B68C1C),
                ],
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FadeTransition(
                  opacity: _logoOpacidad,
                  child: ScaleTransition(
                    scale: _logoEscala,
                    child: const AppLogo(height: 150, colorNombre: Colors.white),
                  ),
                ),
                const SizedBox(height: 14),
                FadeTransition(
                  opacity: _taglineOpacidad,
                  child: SlideTransition(
                    position: _taglineDesplazamiento,
                    child: Text(
                      'Grandes delicias desde ${BusinessInfo.desde}',
                      style: AppTextStyles.tagline(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
