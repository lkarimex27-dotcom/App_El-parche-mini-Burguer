import 'package:flutter/material.dart';
import '../../models/rol.dart';
import '../../screens/login_screen.dart';
import '../../screens/profile_data_screen.dart';
import '../../state/app_scope.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/primary_button.dart';

class AdminProfileScreen extends StatelessWidget {
  const AdminProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final usuario = AppScope.usuario(context);

    return Scaffold(
      backgroundColor: AppColors.crema,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.carbon),
        title: Text('Perfil', style: AppTextStyles.heading(size: 15)),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 24, 18, 26),
            decoration: const BoxDecoration(gradient: AppColors.ambarMostaza),
            child: Column(
              children: [
                Container(
                  width: 68,
                  height: 68,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    usuario.iniciales,
                    style: AppTextStyles.heading(
                        size: 21, color: AppColors.mostaza),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  usuario.nombre.isEmpty ? 'Tu cuenta' : usuario.nombre,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.heading(size: 15, color: Colors.white),
                ),
                if (usuario.email.isNotEmpty)
                  Text(usuario.email,
                      style:
                          AppTextStyles.body(size: 11.5, color: Colors.white)),
                const SizedBox(height: 4),
                Text(usuario.rol.label,
                    style: AppTextStyles.body(
                        size: 11.5,
                        color: Colors.white,
                        weight: FontWeight.w600)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  clipBehavior: Clip.antiAlias,
                  child: ListTile(
                    leading: const Icon(Icons.person_outline_rounded,
                        color: AppColors.mostaza),
                    title: Text('Configuración de perfil',
                        style: AppTextStyles.body(
                            size: 12.5, weight: FontWeight.w600)),
                    subtitle: Text('Nombre, documento, correo y teléfono',
                        style: AppTextStyles.body(
                            size: 11, color: AppColors.muted)),
                    trailing: const Icon(Icons.chevron_right_rounded,
                        color: AppColors.muted),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const ProfileDataScreen()),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                PrimaryButton(
                  label: 'Cerrar sesión',
                  color: Colors.white,
                  colorTexto: AppColors.tomate,
                  onPressed: () => _confirmarSalida(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmarSalida(BuildContext context) async {
    final salir = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text('¿Cerrar sesión?', style: AppTextStyles.heading(size: 14)),
        content: Text('Vas a volver a la pantalla de inicio de sesión.',
            style: AppTextStyles.body(size: 12.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancelar', style: AppTextStyles.body(size: 12.5)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Cerrar sesión',
                style:
                    AppTextStyles.heading(size: 12.5, color: AppColors.tomate)),
          ),
        ],
      ),
    );

    if (salir != true || !context.mounted) return;
    AppScope.usuarioSinEscuchar(context).cerrarSesion();
    AppScope.carritoSinEscuchar(context).vaciar();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }
}
