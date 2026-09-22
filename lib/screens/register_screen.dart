import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/business_info.dart';
import '../models/documento.dart';
import '../state/app_scope.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/aparicion.dart';
import '../widgets/app_form_field.dart';
import '../widgets/app_image.dart';
import '../widgets/app_logo.dart';
import '../widgets/primary_button.dart';
import 'main_nav_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nombre = TextEditingController();
  final _documento = TextEditingController();
  final _email = TextEditingController();
  final _telefono = TextEditingController();
  final _password = TextEditingController();
  final _confirmar = TextEditingController();

  String _tipoDocumento = kTiposDocumento.first.codigo;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  /// Solo se valida en vivo después del primer intento de guardar, para no
  /// pintar todo de rojo apenas se abre la pantalla.
  bool _intentoGuardar = false;

  @override
  void dispose() {
    _nombre.dispose();
    _documento.dispose();
    _email.dispose();
    _telefono.dispose();
    _password.dispose();
    _confirmar.dispose();
    super.dispose();
  }

  void _crearCuenta() {
    setState(() => _intentoGuardar = true);

    if (!_formKey.currentState!.validate()) {
      avisarCamposIncompletos(context);
      return;
    }

    // Se toman antes de navegar: después de cambiar de pantalla este
    // context ya no sirve para buscarlos.
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    // Los datos de la cuenta quedan guardados y se usan en todo el resto
    // de la app: encabezado, saludo del inicio, perfil y pedidos.
    AppScope.usuarioSinEscuchar(context).registrar(
      nombre: _nombre.text,
      email: _email.text,
      telefono: _telefono.text,
      tipoDocumento: _tipoDocumento,
      documento: _documento.text,
    );

    navigator.pushAndRemoveUntil(
      rutaConFundido(const MainNavScreen()),
      (route) => false,
    );
    avisarExitoEn(messenger, 'Tu cuenta quedó creada. ¡Bienvenido al parche!');
  }

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
            child: Column(
              children: [
                // Barra propia: la flecha va arriba a la izquierda y siempre
                // visible, sin depender del scroll del formulario.
                Padding(
                  padding: const EdgeInsets.fromLTRB(6, 4, 14, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        tooltip: 'Volver',
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      Expanded(
                        child: Text(
                          'Crear cuenta',
                          style: AppTextStyles.heading(size: 15, color: Colors.white),
                        ),
                      ),
                      const AppLogo(height: 34, mostrarNombre: false),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(18, 10, 18, 20),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Form(
                        key: _formKey,
                        autovalidateMode: _intentoGuardar
                            ? AutovalidateMode.onUserInteraction
                            : AutovalidateMode.disabled,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text('Tus datos', style: AppTextStyles.heading(size: 14)),
                            const SizedBox(height: 2),
                            Text(
                              'Los campos con * son obligatorios',
                              style: AppTextStyles.body(
                                  size: 10.5, color: AppColors.muted),
                            ),
                            const SizedBox(height: 14),

                            AppTextField(
                              controller: _nombre,
                              hint: 'Nombre completo',
                              icon: Icons.person_outline_rounded,
                              obligatorio: true,
                              validarAdemas: (v) =>
                                  v.length < 3 ? 'Escribe tu nombre completo' : null,
                            ),
                            const SizedBox(height: 10),

                            // Tipo de documento + número, en una sola fila.
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: DropdownButtonFormField<String>(
                                    initialValue: _tipoDocumento,
                                    isExpanded: true,
                                    style: AppTextStyles.body(size: 12.5),
                                    decoration: campoDecoration(
                                      hint: 'Tipo',
                                      icon: Icons.badge_outlined,
                                      obligatorio: true,
                                    ),
                                    items: kTiposDocumento
                                        .map(
                                          (t) => DropdownMenuItem(
                                            value: t.codigo,
                                            child: Text(
                                              t.codigo,
                                              style: AppTextStyles.body(size: 12.5),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (v) => setState(
                                        () => _tipoDocumento = v ?? _tipoDocumento),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 6,
                                  child: AppTextField(
                                    controller: _documento,
                                    hint: 'N° documento',
                                    teclado: TextInputType.number,
                                    obligatorio: true,
                                    formatters: [
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    validarAdemas: (v) =>
                                        v.length < 5 ? 'Número muy corto' : null,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              tipoDocumentoPorCodigo(_tipoDocumento)?.nombre ?? '',
                              style: AppTextStyles.body(
                                  size: 10, color: AppColors.muted),
                            ),
                            const SizedBox(height: 10),

                            AppTextField(
                              controller: _email,
                              hint: 'Correo electrónico',
                              icon: Icons.mail_outline_rounded,
                              teclado: TextInputType.emailAddress,
                              obligatorio: true,
                              validarAdemas: (v) => !v.contains('@') || !v.contains('.')
                                  ? 'Correo no válido'
                                  : null,
                            ),
                            const SizedBox(height: 10),

                            AppTextField(
                              controller: _telefono,
                              hint: 'Teléfono',
                              icon: Icons.phone_outlined,
                              teclado: TextInputType.phone,
                              obligatorio: true,
                              formatters: [FilteringTextInputFormatter.digitsOnly],
                              validarAdemas: (v) =>
                                  v.length < 7 ? 'Teléfono no válido' : null,
                            ),
                            const SizedBox(height: 10),

                            AppTextField(
                              controller: _password,
                              hint: 'Contraseña',
                              icon: Icons.lock_outline_rounded,
                              obscure: _obscurePassword,
                              obligatorio: true,
                              validarAdemas: (v) =>
                                  v.length < 6 ? 'Mínimo 6 caracteres' : null,
                              suffix: _OjoBoton(
                                oculto: _obscurePassword,
                                onTap: () => setState(
                                    () => _obscurePassword = !_obscurePassword),
                              ),
                            ),
                            const SizedBox(height: 10),

                            AppTextField(
                              controller: _confirmar,
                              hint: 'Confirmar contraseña',
                              icon: Icons.lock_outline_rounded,
                              obscure: _obscureConfirm,
                              obligatorio: true,
                              validarAdemas: (v) => v != _password.text
                                  ? 'Las contraseñas no coinciden'
                                  : null,
                              suffix: _OjoBoton(
                                oculto: _obscureConfirm,
                                onTap: () => setState(
                                    () => _obscureConfirm = !_obscureConfirm),
                              ),
                            ),
                            const SizedBox(height: 18),

                            PrimaryButton(label: 'Crear cuenta', onPressed: _crearCuenta),
                            const SizedBox(height: 10),
                            GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              child: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: AppTextStyles.body(
                                      size: 11.5, color: AppColors.carbon),
                                  children: [
                                    const TextSpan(text: '¿Ya tienes cuenta? '),
                                    TextSpan(
                                      text: 'Inicia sesión',
                                      style: AppTextStyles.heading(
                                          size: 11.5, color: AppColors.mostaza),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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

class _OjoBoton extends StatelessWidget {
  final bool oculto;
  final VoidCallback onTap;
  const _OjoBoton({required this.oculto, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(
        oculto ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        size: 18,
        color: AppColors.muted,
      ),
    );
  }
}
