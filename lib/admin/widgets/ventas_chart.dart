import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// Gráfica de barras de las ventas de la semana. Hecha con widgets, sin
/// paquete de charts: son 7 barras y no vale la pena una dependencia.
class VentasChart extends StatelessWidget {
  final List<int> valores;
  final List<String> etiquetas;
  final double alto;

  const VentasChart({
    super.key,
    required this.valores,
    required this.etiquetas,
    this.alto = 130,
  });

  @override
  Widget build(BuildContext context) {
    if (valores.isEmpty) return const SizedBox.shrink();

    final maximo = valores.reduce((a, b) => a > b ? a : b);
    // El último día es "hoy": va resaltado.
    final ultimo = valores.length - 1;

    return SizedBox(
      height: alto,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(valores.length, (i) {
          final proporcion = maximo == 0 ? 0.0 : valores[i] / maximo;
          final esHoy = i == ultimo;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '${(valores[i] / 1000).round()}k',
                    style: AppTextStyles.body(
                      size: 10,
                      color: esHoy ? AppColors.carbon : AppColors.muted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: FractionallySizedBox(
                      alignment: Alignment.bottomCenter,
                      // Un mínimo para que la barra más baja siga viéndose.
                      heightFactor: 0.12 + proporcion * 0.88,
                      child: Container(
                        decoration: BoxDecoration(
                          color: esHoy ? AppColors.mostaza : AppColors.ambar.withAlpha(90),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    etiquetas.length > i ? etiquetas[i] : '',
                    style: AppTextStyles.heading(
                      size: 11,
                      color: esHoy ? AppColors.carbon : AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
