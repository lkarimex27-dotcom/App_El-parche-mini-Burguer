import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/business_info.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_image.dart';
import '../widgets/app_logo.dart';
import '../widgets/primary_button.dart';

enum _Paso { correo, codigo, nueva }

/// Recuperar la contraseña en tres pasos:
/// 1. El cliente escribe su correo.
/// 2. Le llega un código de 6 dígitos y lo escribe.
/// 3. Crea su contraseña nueva.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  _Paso _paso = _Paso.correo;

  final _correo = TextEditingController();
  final _codigo = TextEditingController();
  final _nueva = TextEditingController();
  final _confirmar = TextEditingController();

  /// El código que "se envió". Cuando conectes el backend, esto lo valida
  /// el servidor y aquí solo se manda lo que escribió el cliente.
  String? _codigoEnviado;

  String? _error;
  bool _ocultarNueva = true;

  int _segundosParaReenviar = 0;
  Timer? _contador;

  @override
  void dispose() {
    _contador?.cancel();
    _correo.dispose();
    _codigo.dispose();
    _nueva.dispose();
    _confirmar.dispose();
    super.dispose();
  }

  // ───────────────────────────── Pasos ─────────────────────────────

  void _enviarCodigo({bool reenvio = false}) {
    final correo = _correo.text.trim();
    if (!correo.contains('@') || !correo.contains('.')) {
      setState(() => _error = 'Escribe un correo válido');
      return;
    }

    // TODO: reemplazar por el envío real del código (correo o SMS) cuando
    // esté el backend. Por ahora se genera aquí para poder probar el flujo.
    final codigo = (Random().nextInt(900000) + 100000).toString();

    setState(() {
      _codigoEnviado = codigo;
      _error = null;
      _paso = _Paso.codigo;
      _codigo.clear();
    });

    _iniciarContador();

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: AppColors.carbon,
          duration: const Duration(seconds: 8),
          content: Text(
            reenvio
                ? 'Te reenviamos el código: $codigo'
                : 'Código enviado a $correo: $codigo',
            style: AppTextStyles.body(size: 12.5, color: Colors.white),
          ),
          action: SnackBarAction(
            label: 'Copiar',
            textColor: AppColors.ambar,
            onPressed: () => Clipboard.setData(ClipboardData(text: codigo)),
          ),
        ),
      );
  }

  void _iniciarContador() {
    _contador?.cancel();
    setState(() => _segundosParaReenviar = 30);
    _contador = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _segundosParaReenviar--;
        if (_segundosParaReenviar <= 0) timer.cancel();
      });
    });
  }

  void _verificarCodigo() {
    if (_codigo.text.trim() != _codigoEnviado) {
      setState(() => _error = 'El código no coincide, revísalo');
      return;
    }
    setState(() {
      _error = null;
      _paso = _Paso.nueva;
    });
  }

  void _guardarContrasena() {
    if (_nueva.text.length < 6) {
      setState(() => _error = 'La contraseña debe tener al menos 6 caracteres');
      return;
    }
    if (_nueva.text != _confirmar.text) {
      setState(() => _error = 'Las dos contraseñas no son iguales');
      return;
    }

    // TODO: mandar la contraseña nueva al backend.
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: AppColors.verde,
          content: Text('Tu contraseña quedó actualizada. Ya puedes entrar.',
              style: AppTextStyles.body(size: 12.5, color: Colors.white)),
        ),
      );
  }

  void _volverAtras() {
    if (_paso == _Paso.correo) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _error = null;
      _paso = _paso == _Paso.nueva ? _Paso.codigo : _Paso.correo;
    });
  }

  // ───────────────────────────── Interfaz ────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AppImage(
            'assets/images/login_bg.jpg',
            fallbackUrl: BusinessInfo.fotoAmbiente,
            fit: BoxFit.cover,
          ),
          Container(color: Colors.black.withValues(alpha: 0.6)),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: _volverAtras,
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                  const AppLogo(height: 72, colorNombre: Colors.white),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.94),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _Pasos(actual: _paso),
                        const SizedBox(height: 18),
                        ..._contenidoDelPaso(),
                        if (_error != null) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.error_outline,
                                  size: 16, color: AppColors.tomate),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(_error!,
                                    style: AppTextStyles.body(
                                        size: 11.5, color: AppColors.tomate)),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _contenidoDelPaso() {
    switch (_paso) {
      case _Paso.correo:
        return [
          Text('¿Olvidaste tu contraseña?',
              textAlign: TextAlign.center, style: AppTextStyles.heading(size: 16)),
          const SizedBox(height: 6),
          Text(
            'Escribe el correo de tu cuenta y te mandamos\nun código de 6 dígitos.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body(size: 12, color: AppColors.muted),
          ),
          const SizedBox(height: 18),
          _Campo(
            controller: _correo,
            hint: 'Correo electrónico',
            icon: Icons.mail_outline_rounded,
            teclado: TextInputType.emailAddress,
          ),
          const SizedBox(height: 18),
          PrimaryButton(label: 'Enviar código', onPressed: _enviarCodigo),
        ];

      case _Paso.codigo:
        return [
          Text('Revisa tu correo',
              textAlign: TextAlign.center, style: AppTextStyles.heading(size: 16)),
          const SizedBox(height: 6),
          Text(
            'Mandamos un código de 6 dígitos a\n${_correo.text.trim()}',
            textAlign: TextAlign.center,
            style: AppTextStyles.body(size: 12, color: AppColors.muted),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _codigo,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 6,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: AppTextStyles.heading(size: 22).copyWith(letterSpacing: 10),
            decoration: InputDecoration(
              counterText: '',
              hintText: '––––––',
              hintStyle: AppTextStyles.heading(size: 22, color: AppColors.borde)
                  .copyWith(letterSpacing: 10),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.borde),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.mostaza, width: 1.6),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: _segundosParaReenviar > 0
                ? Text(
                    'Puedes reenviarlo en $_segundosParaReenviar s',
                    style: AppTextStyles.body(size: 11.5, color: AppColors.muted),
                  )
                : GestureDetector(
                    onTap: () => _enviarCodigo(reenvio: true),
                    child: Text('Reenviar código',
                        style: AppTextStyles.heading(
                            size: 12, color: AppColors.mostaza)),
                  ),
          ),
          const SizedBox(height: 16),
          PrimaryButton(label: 'Verificar código', onPressed: _verificarCodigo),
        ];

      case _Paso.nueva:
        return [
          Text('Crea tu contraseña nueva',
              textAlign: TextAlign.center, style: AppTextStyles.heading(size: 16)),
          const SizedBox(height: 6),
          Text(
            'Mínimo 6 caracteres.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body(size: 12, color: AppColors.muted),
          ),
          const SizedBox(height: 18),
          _Campo(
            controller: _nueva,
            hint: 'Contraseña nueva',
            icon: Icons.lock_outline_rounded,
            oculto: _ocultarNueva,
            onVerOcultar: () => setState(() => _ocultarNueva = !_ocultarNueva),
          ),
          const SizedBox(height: 12),
          _Campo(
            controller: _confirmar,
            hint: 'Confirmar contraseña',
            icon: Icons.lock_outline_rounded,
            oculto: _ocultarNueva,
          ),
          const SizedBox(height: 18),
          PrimaryButton(label: 'Guardar contraseña', onPressed: _guardarContrasena),
        ];
    }
  }
}

/// Los tres puntitos que muestran en qué paso va.
class _Pasos extends StatelessWidget {
  final _Paso actual;
  const _Pasos({required this.actual});

  @override
  Widget build(BuildContext context) {
    final indice = _Paso.values.indexOf(actual);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_Paso.values.length * 2 - 1, (i) {
        if (i.isOdd) {
          return Container(
            width: 26,
            height: 2,
            color: i ~/ 2 < indice ? AppColors.mostaza : AppColors.borde,
          );
        }
        final paso = i ~/ 2;
        final hecho = paso <= indice;
        return Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: hecho ? AppColors.mostaza : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: hecho ? AppColors.mostaza : AppColors.borde,
              width: 1.6,
            ),
          ),
          child: Text(
            '${paso + 1}',
            style: AppTextStyles.heading(
              size: 11,
              color: hecho ? Colors.white : AppColors.muted,
            ),
          ),
        );
      }),
    );
  }
}

class _Campo extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType? teclado;
  final bool oculto;
  final VoidCallback? onVerOcultar;

  const _Campo({
    required this.controller,
    required this.hint,
    required this.icon,
    this.teclado,
    this.oculto = false,
    this.onVerOcultar,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: teclado,
      obscureText: oculto,
      style: AppTextStyles.body(size: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.body(size: 12.5, color: AppColors.muted),
        prefixIcon: Icon(icon, color: AppColors.mostaza, size: 20),
        suffixIcon: onVerOcultar == null
            ? null
            : IconButton(
                onPressed: onVerOcultar,
                icon: Icon(
                  oculto ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  size: 19,
                  color: AppColors.muted,
                ),
              ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.borde),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.mostaza, width: 1.6),
        ),
      ),
    );
  }
}
