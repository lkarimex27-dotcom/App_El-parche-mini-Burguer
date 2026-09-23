import 'package:flutter/material.dart';
import '../models/order.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Las fases del pedido en fila vertical: cuáles ya pasó, en cuál está y
/// cuáles le faltan. Si lo rechazaron o lo cancelaron, el camino se corta
/// ahí y el último paso sale en rojo con el motivo.
class OrderProgress extends StatelessWidget {
  final Order order;
  const OrderProgress({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final cortado = order.status == OrderStatus.rechazado ||
        order.status == OrderStatus.cancelado;
    final fase = order.faseActual;

    // Un pedido cortado muestra hasta donde llegó y remata con el corte;
    // uno normal muestra el camino completo.
    final pasos = <Widget>[];
    for (var i = 0; i < kFasesPedido.length; i++) {
      final estado = kFasesPedido[i];
      if (cortado && i > fase) break;

      pasos.add(_Paso(
        icono: estado.icon,
        titulo: estado.label,
        // Con el pedido cortado, ni siquiera la fase en la que se quedó
        // sigue "en curso": ya no avanza.
        cumplido: i < fase || (i == fase && cortado),
        actual: i == fase && !cortado,
        hora: order.fechaDeFase(estado),
        color: AppColors.verde,
        esUltimo: !cortado && i == kFasesPedido.length - 1,
      ));
    }

    if (cortado) {
      pasos.add(_Paso(
        icono: order.status.icon,
        titulo: order.status.label,
        cumplido: false,
        actual: true,
        hora: order.fechaDeFase(order.status) ?? order.historial.last.fecha,
        color: AppColors.tomate,
        esUltimo: true,
      ));
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Seguimiento', style: AppTextStyles.heading(size: 12.5)),
          const SizedBox(height: 12),
          ...pasos,
        ],
      ),
    );
  }
}

class _Paso extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final bool cumplido;
  final bool actual;
  final DateTime? hora;
  final Color color;
  final bool esUltimo;

  const _Paso({
    required this.icono,
    required this.titulo,
    required this.cumplido,
    required this.actual,
    required this.hora,
    required this.color,
    required this.esUltimo,
  });

  @override
  Widget build(BuildContext context) {
    final alcanzado = cumplido || actual;
    final colorPaso = alcanzado ? color : AppColors.borde;

    return IntrinsicHeight(
      // El paso crece con su texto: un alto fijo se queda corto en cuanto
      // el cliente usa la letra grande del sistema.
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: alcanzado ? colorPaso : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: colorPaso, width: 1.6),
                ),
                child: Icon(
                  cumplido ? Icons.check_rounded : icono,
                  size: 14,
                  color: alcanzado ? Colors.white : AppColors.muted,
                ),
              ),
              if (!esUltimo)
                Expanded(
                  child: Container(
                    width: 2,
                    // La línea se pinta del color del paso de arriba solo si
                    // ya se cumplió: así se ve hasta dónde avanzó.
                    color: cumplido ? color : AppColors.borde,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              // Lo de abajo es el aire entre un paso y el siguiente.
              padding: EdgeInsets.only(top: 3, bottom: esUltimo ? 0 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.heading(
                      size: 12,
                      color: alcanzado ? AppColors.carbon : AppColors.muted,
                      weight: actual ? FontWeight.w700 : FontWeight.w600,
                    ),
                  ),
                  if (hora != null)
                    Text(
                      horaEnPalabras(hora!),
                      style: AppTextStyles.body(
                          size: 10.5, color: AppColors.muted),
                    ),
                ],
              ),
            ),
          ),
          if (actual)
            // Sin el Align, el Row estirado le daría al badge todo el alto.
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text('Ahora',
                    style: AppTextStyles.heading(size: 9.5, color: color)),
              ),
            ),
        ],
      ),
    );
  }
}
