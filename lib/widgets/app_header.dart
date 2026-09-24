import 'package:flutter/material.dart';
import '../state/app_scope.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'app_logo.dart';
import '../state/app_scope.dart';

/// Encabezado que se ve en todas las pantallas de adentro de la app:
/// el logo a la izquierda y el círculo del perfil a la derecha.
class AppHeader extends StatelessWidget {
<<<<<<< HEAD
  /// Qué hacer al tocar el círculo del perfil (ir a la pestaña Perfil).
  final VoidCallback? onPerfil;

  const AppHeader({super.key, this.onPerfil});
=======
  final VoidCallback? onVolver;

  const AppHeader({super.key, this.onVolver});
>>>>>>> c438655f150cab2ad02ddc8ca1916c8e0bc9c7bf

  @override
  Widget build(BuildContext context) {
    final usuario = AppScope.usuario(context);
<<<<<<< HEAD

=======
>>>>>>> c438655f150cab2ad02ddc8ca1916c8e0bc9c7bf
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
<<<<<<< HEAD
            const Expanded(
              child: AppLogo(height: 40, horizontal: true),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: onPerfil,
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.crema2,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.mostaza, width: 1.8),
                ),
                child: Text(
                  usuario.iniciales,
                  style:
                      AppTextStyles.heading(size: 13, color: AppColors.mostaza),
=======
            if (onVolver != null)
              IconButton(
                tooltip: 'Volver a repartidor',
                onPressed: onVolver,
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            const Expanded(
              child: AppLogo(height: 40, horizontal: true),
            ),
            CircleAvatar(
              radius: 19,
              backgroundColor: const Color(0xFFB68C1C),
              child: Text(
                usuario.iniciales,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
>>>>>>> c438655f150cab2ad02ddc8ca1916c8e0bc9c7bf
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
