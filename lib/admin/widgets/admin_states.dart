import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// Lo que se muestra cuando una lista del panel está vacía.
/// Los estados de carga y error se agregarán cuando haya datos remotos
/// que puedan tardar o fallar.
class AdminEmptyState extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String? detalle;
  final Widget? accion;

  const AdminEmptyState({
    super.key,
    required this.icono,
    required this.titulo,
    this.detalle,
    this.accion,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 38, color: AppColors.borde),
          const SizedBox(height: 10),
          Text(titulo,
              textAlign: TextAlign.center,
              style: AppTextStyles.heading(size: 14)),
          if (detalle != null) ...[
            const SizedBox(height: 4),
            Text(detalle!,
                textAlign: TextAlign.center,
                style: AppTextStyles.body(size: 12.5, color: AppColors.muted)),
          ],
          if (accion != null) ...[const SizedBox(height: 14), accion!],
        ],
      ),
    );
  }
}
