import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// La tarjeta base del panel: blanca, redondeada, borde sutil.
/// Todas las secciones del admin se arman encima de esta.
class AdminCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;
  final Color? borde;

  const AdminCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.onTap,
    this.color,
    this.borde,
  });

  @override
  Widget build(BuildContext context) {
    final contenido = Padding(padding: padding, child: child);

    // Material y no Container: adentro van ListTile e InkWell, y sobre un
    // Container con color no se les ve ni el fondo ni el toque.
    return Material(
      color: color ?? Colors.white,
      elevation: 1,
      shadowColor: AppColors.carbon.withAlpha(30),
      surfaceTintColor: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borde ?? AppColors.borde),
      ),
      child: onTap == null
          ? contenido
          : InkWell(onTap: onTap, child: contenido),
    );
  }
}

/// Encabezado de sección: título a la izquierda y una acción opcional.
class TituloSeccion extends StatelessWidget {
  final String titulo;
  final String? accion;
  final VoidCallback? onAccion;

  const TituloSeccion({
    super.key,
    required this.titulo,
    this.accion,
    this.onAccion,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(child: Text(titulo, style: AppTextStyles.heading(size: 19))),
          if (accion != null)
            GestureDetector(
              onTap: onAccion,
              child: Text(accion!,
                  style: AppTextStyles.body(size: 13, color: AppColors.mostaza)),
            ),
        ],
      ),
    );
  }
}
