import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final Color colorTexto;

  /// Tamaño de la letra. El de por defecto está pensado para que el texto
  /// quepa cómodo aunque lleve el precio al lado.
  final double tamanoTexto;

  final double alto;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color = AppColors.ambar,
    this.colorTexto = Colors.white,
    this.tamanoTexto = 13,
    this.alto = 46,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: alto,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: colorTexto,
          disabledBackgroundColor: AppColors.borde,
          disabledForegroundColor: AppColors.muted,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            maxLines: 1,
            style: AppTextStyles.heading(size: tamanoTexto, color: colorTexto),
          ),
        ),
      ),
    );
  }
}
