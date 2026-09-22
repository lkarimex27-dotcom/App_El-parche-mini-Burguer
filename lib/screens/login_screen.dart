import 'package:flutter/material.dart';
import '../admin/screens/admin_nav_screen.dart';
import '../models/business_info.dart';
import '../models/rol.dart';
import '../state/app_scope.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/aparicion.dart';
import '../widgets/app_form_field.dart';
import '../widgets/app_image.dart';
import '../widgets/app_logo.dart';
import '../widgets/primary_button.dart';
import '../widgets/social_button.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';
import 'main_nav_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _intentoEntrar = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _entrar() {
    setState(() => _intentoEntrar = true);

    if (!_formKey.currentState!.validate()) {
      avisarCamposIncompletos(context);
      return;
    }

    AppScope.usuarioSinEscuchar(context)
        .iniciarSesionConCorreo(_emailController.text);
    _abrirApp();
  }

  void _entrarCon(String proveedor) {
    // TODO: conectar el SDK real de Google / Apple cuando esté el backend.
    // Mientras tanto se usa el correo que ya haya escrito el cliente.
    AppScope.usuarioSinEscuchar(context).iniciarSesionExterna(
      proveedor: proveedor,
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
    );
    _abrirApp();
  }

  /// Según el rol: el cliente va a la app de siempre, el resto al panel.
  void _abrirApp() {
    final rol = AppScope.usuarioSinEscuchar(context).rol;
    Navigator.of(context).pushReplacement(
      rutaConFundido(
        rol.esDelPanel ? const AdminNavScreen() : const MainNavScreen(),
      ),
    );
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
          Container(color: Colors.black.withValues(alpha: 0.55)),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 24, 18, 20),
              child: Column(
                children: [
                  const AppLogo(height: 92, colorNombre: Colors.white),
                  const SizedBox(height: 26),
                  Container(
                    padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Form(
                      key: _formKey,
                      autovalidateMode: _intentoEntrar
                          ? AutovalidateMode.onUserInteraction
                          : AutovalidateMode.disabled,
                      child: Column(
                        children: [
                          Text('Inicia sesión',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.heading(size: 15)),
                          const SizedBox(height: 16),
                          AppTextField(
                            controller: _emailController,
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
                            controller: _passwordController,
                            hint: 'Contraseña',
                            icon: Icons.lock_outline_rounded,
                            obscure: _obscurePassword,
                            obligatorio: true,
                            suffix: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: AppColors.muted,
                                size: 18,
                              ),
                              onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) => const ForgotPasswordScreen()),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Text(
                                  '¿Olvidaste tu contraseña?',
                                  style: AppTextStyles.heading(
                                      size: 11, color: AppColors.mostaza),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          PrimaryButton(label: 'Iniciar sesión', onPressed: _entrar),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              const Expanded(child: Divider(color: AppColors.borde)),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Text('o continúa con',
                                    style: AppTextStyles.body(
                                        size: 10.5, color: AppColors.muted)),
                              ),
                              const Expanded(child: Divider(color: AppColors.borde)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: SocialButton.google(
                                  onPressed: () => _entrarCon('Google'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: SocialButton.apple(
                                  onPressed: () => _entrarCon('Apple'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          GestureDetector(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const RegisterScreen()),
                            ),
                            child: RichText(
                              text: TextSpan(
                                style: AppTextStyles.body(
                                    size: 11.5, color: AppColors.carbon),
                                children: [
                                  const TextSpan(text: '¿No tienes cuenta? '),
                                  TextSpan(
                                    text: 'Crear una cuenta',
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
