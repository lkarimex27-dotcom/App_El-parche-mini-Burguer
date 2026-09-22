import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../models/product.dart';
import '../../state/app_scope.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_image.dart';
import '../../widgets/order_status_badge.dart';
import '../widgets/admin_card.dart';
import '../widgets/admin_search_bar.dart';
import '../widgets/admin_states.dart';
import 'admin_pedido_detalle_screen.dart';

/// Listado administrativo de pedidos: buscar, filtrar por estado y entrar
/// al detalle. Los que esperan aprobación quedan de primeros.
class AdminPedidosScreen extends StatefulWidget {
  const AdminPedidosScreen({super.key});

  @override
  State<AdminPedidosScreen> createState() => _AdminPedidosScreenState();
}

class _AdminPedidosScreenState extends State<AdminPedidosScreen> {
  final _busquedaController = TextEditingController();
  String _busqueda = '';
  OrderStatus? _filtro;

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  /// Busca por número de pedido, cliente o producto.
  bool _coincide(Order pedido) {
    if (_busqueda.isEmpty) return true;
    final texto = _busqueda.toLowerCase();
    if (pedido.id.contains(texto)) return true;
    if (pedido.cliente.toLowerCase().contains(texto)) return true;
    return pedido.lineas.any((l) => l.nombre.toLowerCase().contains(texto));
  }

  @override
  Widget build(BuildContext context) {
    final todos = AppScope.pedidos(context).pedidos;

    final filtrados = todos
        .where((p) => _filtro == null || p.status == _filtro)
        .where(_coincide)
        .toList()
      // Lo que espera aprobación se atiende primero.
      ..sort((a, b) {
        if (a.requiereAprobacion != b.requiereAprobacion) {
          return a.requiereAprobacion ? -1 : 1;
        }
        return b.fecha.compareTo(a.fecha);
      });

    return Container(
      color: AppColors.crema,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text('Pedidos',
                          style: AppTextStyles.heading(size: 22)),
                    ),
                    Text('${filtrados.length} de ${todos.length}',
                        style: AppTextStyles.body(
                            size: 12, color: AppColors.muted)),
                  ],
                ),
                const SizedBox(height: 12),
                AdminSearchBar(
                  hint: 'Buscar por número, cliente o producto',
                  controller: _busquedaController,
                  onBuscar: (v) => setState(() => _busqueda = v.trim()),
                ),
                const SizedBox(height: 10),
                FiltroChips<OrderStatus>(
                  seleccionado: _filtro,
                  onSeleccionar: (v) => setState(() => _filtro = v),
                  opciones: [
                    FiltroOpcion('Todos', null, cantidad: todos.length),
                    for (final estado in OrderStatus.values)
                      if (todos.any((p) => p.status == estado))
                        FiltroOpcion(
                          estado.label,
                          estado,
                          cantidad:
                              todos.where((p) => p.status == estado).length,
                        ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: filtrados.isEmpty
                ? Center(
                    child: AdminEmptyState(
                      icono: Icons.receipt_long_outlined,
                      titulo: todos.isEmpty
                          ? 'Todavía no hay pedidos'
                          : 'Ningún pedido coincide',
                      detalle: todos.isEmpty
                          ? 'Aquí llegan los pedidos de los clientes.'
                          : 'Prueba con otro texto o quita el filtro.',
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtrados.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) =>
                        _TarjetaPedido(pedido: filtrados[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _TarjetaPedido extends StatelessWidget {
  final Order pedido;
  const _TarjetaPedido({required this.pedido});

  @override
  Widget build(BuildContext context) {
    final principal = pedido.lineaPrincipal;
    final otros = pedido.lineas.length - 1;

    return AdminCard(
      borde: pedido.requiereAprobacion ? AppColors.mostaza : null,
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => AdminPedidoDetalleScreen(pedido: pedido),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (pedido.requiereAprobacion) ...[
            Row(
              children: [
                const Icon(Icons.pending_actions_rounded,
                    size: 15, color: AppColors.mostaza),
                const SizedBox(width: 6),
                Text('Requiere tu aprobación',
                    style: AppTextStyles.heading(
                        size: 11, color: AppColors.mostaza)),
              ],
            ),
            const SizedBox(height: 10),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (principal != null)
                AppImage(
                  principal.imageAsset,
                  fallbackUrl: principal.imageUrl,
                  placeholderIcon: iconoDeCategoria(principal.categoria),
                  width: 54,
                  height: 54,
                  borderRadius: BorderRadius.circular(12),
                ),
              if (principal != null) const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pedido.cliente.isEmpty ? 'Sin cliente' : pedido.cliente,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.heading(size: 13.5),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      principal == null
                          ? '#${pedido.id}'
                          : '${principal.cantidad} × ${principal.nombre}'
                              '${otros > 0 ? ' +$otros' : ''}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body(
                          size: 12, color: AppColors.muted),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '#${pedido.id} · ${pedido.fechaTexto} · ${pedido.metodoPago}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body(
                          size: 11, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text('\$${pedido.total}',
                  style:
                      AppTextStyles.heading(size: 14, color: AppColors.tomate)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Flexible(child: OrderStatusBadge(status: pedido.status)),
              const Spacer(),
              Text('Ver detalle',
                  style: AppTextStyles.body(
                      size: 11.5, color: AppColors.mostaza)),
              const Icon(Icons.chevron_right_rounded,
                  size: 18, color: AppColors.mostaza),
            ],
          ),
        ],
      ),
    );
  }
}
