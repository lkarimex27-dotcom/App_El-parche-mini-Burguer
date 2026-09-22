import 'package:flutter/material.dart';
import '../models/business_info.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// El logo del negocio, tal cual como es: completo, sin círculo que lo
/// recorte y sin caja de fondo. Debajo (o al lado) va el nombre pequeño.
class AppLogo extends StatelessWidget {
  /// Alto del logo. El ancho lo calcula la propia imagen.
  final double height;

  /// Muestra el nombre del negocio junto al logo.
  final bool mostrarNombre;

  /// `true` = nombre al lado (encabezado). `false` = nombre debajo.
  final bool horizontal;

  final Color colorNombre;

  const AppLogo({
    super.key,
    this.height = 40,
    this.mostrarNombre = true,
    this.horizontal = false,
    this.colorNombre = AppColors.carbon,
  });

  @override
  Widget build(BuildContext context) {
    final imagen = Image.asset(
      BusinessInfo.logo,
      height: height,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => Icon(
        Icons.lunch_dining,
        size: height * 0.8,
        color: AppColors.mostaza,
      ),
    );

    if (!mostrarNombre) return imagen;

    final nombre = Text(
      BusinessInfo.nombre,
      textAlign: horizontal ? TextAlign.start : TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: AppTextStyles.heading(
        size: horizontal ? 11 : (height * 0.14).clamp(11.0, 15.0),
        weight: FontWeight.w700,
        color: colorNombre,
      ).copyWith(height: 1.2),
    );

    if (horizontal) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          imagen,
          const SizedBox(width: 8),
          Flexible(child: nombre),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        imagen,
        const SizedBox(height: 6),
        nombre,
      ],
    );
  }
}
