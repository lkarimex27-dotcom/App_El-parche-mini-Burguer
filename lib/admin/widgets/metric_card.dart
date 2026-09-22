import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import 'admin_card.dart';

/// Indicador numérico del dashboard: etiqueta arriba, número grande abajo.
class MetricCard extends StatelessWidget {
  final String etiqueta;
  final String valor;
  final IconData icono;

  /// Color del ícono y del número cuando el dato pide atención.
  final Color color;

  final String? detalle;
  final VoidCallback? onTap;

  const MetricCard({
    super.key,
    required this.etiqueta,
    required this.valor,
    required this.icono,
    this.color = AppColors.mostaza,
    this.detalle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AdminCard(
      onTap: onTap,
      padding: const EdgeInsets.all(13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: color.withAlpha(28),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icono, size: 16, color: color),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  etiqueta.toUpperCase(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body(size: 10.5, color: AppColors.muted),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(valor,
                maxLines: 1, style: AppTextStyles.heading(size: 26, color: color)),
          ),
          if (detalle != null) ...[
            const SizedBox(height: 2),
            Text(detalle!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body(size: 11, color: AppColors.muted)),
          ],
        ],
      ),
    );
  }
}
