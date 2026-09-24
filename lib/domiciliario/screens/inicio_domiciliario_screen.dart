import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../models/business_info.dart';
import '../../state/app_scope.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/aparicion.dart';
import '../widgets/domiciliario_card.dart';
import '../widgets/estado_entrega_badge.dart';
import 'detalle_entrega_screen.dart';

class InicioDomiciliarioScreen extends StatelessWidget {
  final VoidCallback? onPerfil;

  const InicioDomiciliarioScreen({super.key, this.onPerfil});

  @override
  Widget build(BuildContext context) {
    final usuario = AppScope.usuario(context);
    final pedidosModel = AppScope.pedidos(context);
    final domicilio = AppScope.domiciliario(context);
    final asignados = pedidosModel.pedidosAsignados(usuario.email);
    final completados = asignados
        .where((pedido) => pedido.status == OrderStatus.entregado)
        .length;
    final enCurso = asignados
        .where((pedido) =>
            pedido.status == OrderStatus.enLocal ||
            pedido.status == OrderStatus.enCamino)
        .length;
    final pendientes = asignados
        .where((pedido) =>
            pedido.status == OrderStatus.listo ||
            pedido.status == OrderStatus.preparacion)
        .length;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 22, 16, 24),
        children: [
          Aparicion(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hola, ${usuario.primerNombre}',
                          style: AppTextStyles.heading(size: 22)),
                      Text('Tu ruta de hoy',
                          style: AppTextStyles.body(
                              size: 12.5, color: AppColors.muted)),
                    ],
                  ),
                ),
                Semantics(
                  button: true,
                  label: 'Abrir perfil',
                  child: InkWell(
                    onTap: onPerfil,
                    borderRadius: BorderRadius.circular(24),
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.mostaza,
                      child: Text(usuario.iniciales,
                          style: AppTextStyles.heading(
                              size: 13, color: Colors.white)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Aparicion(
            orden: 1,
            child: DomiciliarioCard(
              borde: domicilio.enTurno ? AppColors.verde : AppColors.borde,
              child: Row(
                children: [
                  Icon(
                    domicilio.enTurno
                        ? Icons.radio_button_checked_rounded
                        : Icons.pause_circle_outline_rounded,
                    color:
                        domicilio.enTurno ? AppColors.verde : AppColors.muted,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          domicilio.enTurno ? 'En turno' : 'Fuera de turno',
                          style: AppTextStyles.heading(size: 13),
                        ),
                        Text(
                          domicilio.enTurno
                              ? 'Puedes gestionar tus entregas asignadas'
                              : 'No iniciarás nuevas entregas',
                          style: AppTextStyles.body(
                              size: 10.5, color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: domicilio.enTurno,
                    activeThumbColor: AppColors.verde,
                    onChanged: domicilio.cambiarTurno,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Aparicion(
            orden: 2,
            child: Row(
              children: [
                Expanded(
                    child: _Resumen(valor: completados, texto: 'Entregadas')),
                const SizedBox(width: 8),
                Expanded(child: _Resumen(valor: enCurso, texto: 'En curso')),
                const SizedBox(width: 8),
                Expanded(
                    child: _Resumen(valor: pendientes, texto: 'Pendientes')),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Aparicion(
            orden: 3,
            child: DomiciliarioCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.storefront_outlined,
                      color: AppColors.mostaza),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Punto de recogida',
                            style: AppTextStyles.heading(size: 12.5)),
                        const SizedBox(height: 3),
                        Text(BusinessInfo.direccion,
                            style: AppTextStyles.body(
                                size: 11, color: AppColors.muted)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Aparicion(
            orden: 4,
            child: Text('Pedidos asignados',
                style: AppTextStyles.heading(size: 15)),
          ),
          const SizedBox(height: 10),
          if (asignados.isEmpty)
            const DomiciliarioCard(
              child: Text('No tienes pedidos asignados en este momento.'),
            )
          else
            ...asignados.asMap().entries.map(
                  (entry) => Aparicion(
                    orden: 4 + entry.key,
                    child: _PedidoAsignado(pedido: entry.value),
                  ),
                ),
        ],
      ),
    );
  }
}

class _Resumen extends StatelessWidget {
  final int valor;
  final String texto;
  const _Resumen({required this.valor, required this.texto});

  @override
  Widget build(BuildContext context) {
    return DomiciliarioCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$valor',
              style: AppTextStyles.heading(size: 21, color: AppColors.tomate)),
          const SizedBox(height: 3),
          Text(texto,
              style: AppTextStyles.body(size: 10, color: AppColors.muted)),
        ],
      ),
    );
  }
}

class _PedidoAsignado extends StatelessWidget {
  final Order pedido;
  const _PedidoAsignado({required this.pedido});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DomiciliarioCard(
        child: InkWell(
          onTap: () => Navigator.of(context).push(
            rutaConFundido(DetalleEntregaScreen(pedido: pedido)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text('Pedido #${pedido.id}',
                        style: AppTextStyles.heading(size: 13.5)),
                  ),
                  EstadoEntregaBadge(estado: pedido.status),
                ],
              ),
              const SizedBox(height: 9),
              Text(
                  pedido.cliente.isEmpty
                      ? 'Cliente sin nombre'
                      : pedido.cliente,
                  style:
                      AppTextStyles.body(size: 12.5, weight: FontWeight.w600)),
              const SizedBox(height: 3),
              Text(pedido.direccion ?? 'Sin dirección de entrega',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body(size: 11, color: AppColors.muted)),
              if (pedido.horaEstimada != null) ...[
                const SizedBox(height: 7),
                Row(
                  children: [
                    const Icon(Icons.schedule_rounded,
                        size: 15, color: AppColors.ambar),
                    const SizedBox(width: 5),
                    Text('Entrega estimada: ${pedido.horaEstimada}',
                        style: AppTextStyles.body(
                            size: 10.5, color: AppColors.ambar)),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
