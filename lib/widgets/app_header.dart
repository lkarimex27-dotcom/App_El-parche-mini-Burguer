import 'package:flutter/material.dart';
import '../state/app_scope.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'app_logo.dart';

/// Encabezado que se ve en todas las pantallas de adentro de la app:
/// logo a la izquierda y, cuando corresponde, el acceso al perfil a la derecha.
class AppHeader extends StatelessWidget {
  final VoidCallback? onPerfil;
  final bool mostrarPerfil;

  const AppHeader({
    super.key,
    this.onPerfil,
    this.mostrarPerfil = true,
  });

  @override
  Widget build(BuildContext context) {
    final usuario = AppScope.usuario(context);

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            const Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: AppLogo(height: 40, mostrarNombre: false),
              ),
            ),
            if (mostrarPerfil) ...[
              const SizedBox(width: 12),
              Tooltip(
                message: 'Abrir perfil',
                child: GestureDetector(
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
                      style: AppTextStyles.heading(
                        size: 13,
                        color: AppColors.mostaza,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
