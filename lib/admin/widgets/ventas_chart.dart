import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// Gráfica de barras de las ventas. Hecha con widgets, sin paquete de
/// charts: son pocas barras y no vale la pena una dependencia.
///
/// La última barra va resaltada porque es el período en curso: hoy, esta
/// semana o este mes, según el corte que se esté mirando.
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
                    _abreviado(valores[i]),
                    style: AppTextStyles.body(
                      size: 9.5,
                      color: esHoy
                          ? AppColors.texto(context)
                          : AppColors.textoSuave(context),
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
                      size: 10.5,
                      color: esHoy
                          ? AppColors.texto(context)
                          : AppColors.textoSuave(context),
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

/// El valor encima de cada barra, corto para que quepa: "420k" en la vista
/// de días, "1,2M" cuando son meses y las cifras se vuelven millones.
String _abreviado(int valor) {
  if (valor >= 1000000) {
    final millones = valor / 1000000;
    return '${millones.toStringAsFixed(millones >= 10 ? 0 : 1)}M'
        .replaceAll('.', ',');
  }
  return '${(valor / 1000).round()}k';
}
