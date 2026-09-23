import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../models/product.dart';
import '../../state/app_scope.dart';
import '../../state/orders_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_form_field.dart';
import '../../widgets/app_image.dart';
import '../../widgets/order_status_badge.dart';
import '../../widgets/primary_button.dart';
import '../models/permisos.dart';
import '../widgets/admin_card.dart';

/// Detalle administrativo del pedido: todo lo que el cliente eligió, más
/// las acciones del negocio (aprobar, rechazar, avanzar el estado).
class AdminPedidoDetalleScreen extends StatelessWidget {
  final Order pedido;
  const AdminPedidoDetalleScreen({super.key, required this.pedido});

  @override
  Widget build(BuildContext context) {
    // Escucha al modelo: al cambiar el estado, la pantalla se repinta.
    final pedidos = AppScope.pedidos(context);
    final rol = AppScope.usuario(context).rol;
    final puedeMover = puede(rol, ModuloAdmin.pedidos, Permiso.cambiarEstado);

    return Scaffold(
      backgroundColor: AppColors.crema,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.carbon),
        title: Text('Pedido #${pedido.id}',
            style: AppTextStyles.heading(size: 16)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          // ── Estado y aprobación ──
          AdminCard(
            borde: pedido.requiereAprobacion ? AppColors.mostaza : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(child: OrderStatusBadge(status: pedido.status)),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        pedido.fechaTexto,
                        textAlign: TextAlign.right,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body(
                            size: 11.5, color: AppColors.muted),
                      ),
                    ),
                  ],
                ),
                if (pedido.note != null) ...[
                  const SizedBox(height: 10),
                  Text(pedido.note!,
                      style: AppTextStyles.body(
                          size: 12, color: pedido.status.color)),
                ],
                if (pedido.requiereAprobacion) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Supera los \$$kMontoAprobacion, así que necesita tu visto '
                    'bueno antes de pasar a producción.',
                    style:
                        AppTextStyles.body(size: 12, color: AppColors.muted),
                  ),
                  const SizedBox(height: 12),
                  if (puedeMover)
                    Row(
                      children: [
                        Expanded(
                          child: PrimaryButton(
                            label: 'Aprobar',
                            color: AppColors.verde,
                            onPressed: () => _aprobar(context, pedidos),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: PrimaryButton(
                            label: 'Rechazar',
                            color: Colors.white,
                            colorTexto: AppColors.tomate,
                            onPressed: () => _rechazar(context, pedidos),
                          ),
                        ),
                      ],
                    )
                  else
                    Text('Tu rol no puede aprobar pedidos.',
                        style: AppTextStyles.body(
                            size: 12, color: AppColors.tomate)),
                ] else if (puedeMover && !pedido.estaCerrado) ...[
                  const SizedBox(height: 12),
                  _SiguientePaso(pedido: pedido, pedidos: pedidos),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Cliente y entrega ──
          const TituloSeccion(titulo: 'Cliente y entrega'),
          AdminCard(
            child: Column(
              children: [
                _Fila(
                  etiqueta: 'Cliente',
                  valor: pedido.cliente.isEmpty ? '—' : pedido.cliente,
                ),
                _Fila(
                  etiqueta: 'Entrega',
                  valor: pedido.direccion ?? 'Recoge en el local',
                ),
                _Fila(etiqueta: 'Método de pago', valor: pedido.metodoPago),
                if (pedido.comprobante != null)
                  _Fila(etiqueta: 'Comprobante', valor: pedido.comprobante!),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Productos ──
          TituloSeccion(titulo: 'Productos (${pedido.itemCount})'),
          ...pedido.lineas.map((l) => _LineaPedido(linea: l)),

          const SizedBox(height: 6),
          AdminCard(
            child: Column(
              children: [
                _Fila(
                    etiqueta: '${pedido.itemCount} productos',
                    valor: '\$${pedido.subtotal}'),
                _Fila(etiqueta: 'Domicilio', valor: '\$${pedido.domicilio}'),
                const Divider(height: 18, color: AppColors.borde),
                Row(
                  children: [
                    Text('Total', style: AppTextStyles.heading(size: 14)),
                    const Spacer(),
                    Text('\$${pedido.total}',
                        style: AppTextStyles.heading(
                            size: 17, color: AppColors.tomate)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Historial ──
          const TituloSeccion(titulo: 'Historial'),
          AdminCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < pedido.historial.length; i++)
                  _PasoHistorial(
                    evento: pedido.historial[i],
                    esUltimo: i == pedido.historial.length - 1,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _aprobar(BuildContext context, OrdersModel pedidos) {
    final messenger = ScaffoldMessenger.of(context);
    pedidos.cambiarEstado(pedido, OrderStatus.aprobado);
    avisarExitoEn(messenger,
        'Pedido #${pedido.id} aprobado. Ya puede pasar a producción.');
  }

  Future<void> _rechazar(BuildContext context, OrdersModel pedidos) async {
    final motivo = await _pedirMotivo(context);
    if (motivo == null) return;
    if (!context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    pedidos.cambiarEstado(pedido, OrderStatus.rechazado, nota: motivo);
    avisarExitoEn(messenger, 'Pedido #${pedido.id} rechazado.');
  }

  /// Rechazar sin decir por qué deja al cliente sin explicación, así que
  /// el motivo es obligatorio.
  Future<String?> _pedirMotivo(BuildContext context) {
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text('¿Por qué se rechaza?',
            style: AppTextStyles.heading(size: 15)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: AppTextStyles.body(size: 13),
          decoration: campoDecoration(
            hint: 'Motivo (ej: comprobante no válido)',
            obligatorio: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancelar', style: AppTextStyles.body(size: 12.5)),
          ),
          TextButton(
            onPressed: () {
              final texto = controller.text.trim();
              if (texto.isEmpty) {
                avisarCamposIncompletos(context, 'Escribe el motivo');
                return;
              }
              Navigator.of(context).pop(texto);
            },
            child: Text('Rechazar',
                style: AppTextStyles.heading(
                    size: 12.5, color: AppColors.tomate)),
          ),
        ],
      ),
    );
  }
}

/// Botón que mueve el pedido al siguiente estado lógico.
class _SiguientePaso extends StatelessWidget {
  final Order pedido;
  final OrdersModel pedidos;

  const _SiguientePaso({required this.pedido, required this.pedidos});

  /// A dónde sigue cada estado. `null` = no hay siguiente automático.
  OrderStatus? get _siguiente {
    switch (pedido.status) {
      case OrderStatus.pendiente:
        return OrderStatus.aprobado;
      case OrderStatus.aprobado:
        return OrderStatus.preparacion;
      case OrderStatus.preparacion:
        return OrderStatus.listo;
      case OrderStatus.listo:
        return OrderStatus.entregado;
      case OrderStatus.entregado:
      case OrderStatus.rechazado:
      case OrderStatus.cancelado:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final siguiente = _siguiente;
    if (siguiente == null) return const SizedBox.shrink();

    return PrimaryButton(
      label: 'Marcar como ${siguiente.label.toLowerCase()}',
      onPressed: () {
        final messenger = ScaffoldMessenger.of(context);
        pedidos.cambiarEstado(pedido, siguiente);
        avisarExitoEn(messenger, 'Pedido #${pedido.id}: ${siguiente.label}');
      },
    );
  }
}

class _LineaPedido extends StatelessWidget {
  final OrderLine linea;
  const _LineaPedido({required this.linea});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AdminCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppImage(
                  linea.imageAsset,
                  fallbackUrl: linea.imageUrl,
                  placeholderIcon: iconoDeCategoria(linea.categoria),
                  width: 48,
                  height: 48,
                  borderRadius: BorderRadius.circular(11),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${linea.cantidad} × ${linea.nombre}',
                          style: AppTextStyles.heading(size: 13)),
                      Text(linea.categoria,
                          style: AppTextStyles.body(
                              size: 11, color: AppColors.muted)),
                    ],
                  ),
                ),
                Text('\$${linea.total}',
                    style: AppTextStyles.heading(
                        size: 13, color: AppColors.tomate)),
              ],
            ),
            if (linea.opciones.isNotEmpty ||
                linea.salsas.isNotEmpty ||
                linea.adiciones.isNotEmpty) ...[
              const Divider(height: 18, color: AppColors.borde),
              for (final o in linea.opciones.entries)
                _Detalle(etiqueta: o.key, texto: o.value),
              if (linea.salsas.isNotEmpty)
                _Detalle(
                  etiqueta: 'Salsas',
                  texto: linea.salsas.map((e) => e.nombre).join(', '),
                ),
              if (linea.adiciones.isNotEmpty)
                _Detalle(
                  etiqueta: 'Adiciones',
                  texto: linea.adiciones
                      .map((e) => '${e.nombre} +\$${e.precio}')
                      .join(', '),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Detalle extends StatelessWidget {
  final String etiqueta;
  final String texto;
  const _Detalle({required this.etiqueta, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 74,
            child: Text(etiqueta,
                style:
                    AppTextStyles.body(size: 11.5, color: AppColors.muted)),
          ),
          Expanded(
            child: Text(texto, style: AppTextStyles.body(size: 11.5)),
          ),
        ],
      ),
    );
  }
}

class _Fila extends StatelessWidget {
  final String etiqueta;
  final String valor;
  const _Fila({required this.etiqueta, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(etiqueta,
              style: AppTextStyles.body(size: 12.5, color: AppColors.muted)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(valor,
                textAlign: TextAlign.right,
                style: AppTextStyles.body(size: 12.5)),
          ),
        ],
      ),
    );
  }
}

class _PasoHistorial extends StatelessWidget {
  final OrderEvento evento;
  final bool esUltimo;

  const _PasoHistorial({required this.evento, required this.esUltimo});

  @override
  Widget build(BuildContext context) {
    final color = evento.estado?.color ?? AppColors.muted;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              if (!esUltimo)
                Expanded(
                  child: Container(width: 2, color: AppColors.borde),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: esUltimo ? 0 : 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(evento.texto,
                      style: AppTextStyles.body(
                          size: 12.5, weight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(_hora(evento.fecha),
                      style: AppTextStyles.body(
                          size: 11, color: AppColors.muted)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _hora(DateTime f) =>
      '${f.day.toString().padLeft(2, '0')}/'
      '${f.month.toString().padLeft(2, '0')} · ${horaEnPalabras(f)}';
}
