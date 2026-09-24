import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../theme/app_text_styles.dart';

class EstadoEntregaBadge extends StatelessWidget {
  final OrderStatus estado;
  const EstadoEntregaBadge({super.key, required this.estado});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: estado.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        estado.label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.heading(size: 10, color: estado.color),
      ),
    );
  }
}
