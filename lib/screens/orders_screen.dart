import 'package:flutter/material.dart';
import '../models/order.dart';
import '../models/product.dart';
import '../state/app_scope.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_image.dart';
import '../widgets/order_status_badge.dart';
import 'order_detail_screen.dart';
import '../models/precio.dart';

/// Pestaña "Mis pedidos" del bottom nav.
class OrdersScreen extends StatelessWidget {
  final VoidCallback? onVerMenu;

  const OrdersScreen({super.key, this.onVerMenu});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.crema,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
            color: Colors.white,
            child: Text('Mis pedidos', style: AppTextStyles.heading(size: 17)),
          ),
          Expanded(child: OrdersList(onVerMenu: onVerMenu)),
        ],
      ),
    );
  }
}

/// La misma lista, pero como pantalla propia con botón de volver.
/// Es la que abre "Historial de pedidos" desde el Perfil.
class OrdersHistoryPage extends StatelessWidget {
  const OrdersHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.crema,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.carbon),
        title: Text('Historial de pedidos',
            style: AppTextStyles.heading(size: 15)),
      ),
      body: const OrdersList(),
    );
  }
}

class OrdersList extends StatelessWidget {
  final VoidCallback? onVerMenu;

  const OrdersList({super.key, this.onVerMenu});

  @override
  Widget build(BuildContext context) {
    final pedidos = AppScope.pedidos(context).pedidos;

    if (pedidos.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.receipt_long_outlined,
                  size: 46, color: AppColors.borde),
              const SizedBox(height: 12),
              Text('Todavía no tienes pedidos',
                  style: AppTextStyles.heading(size: 14)),
              const SizedBox(height: 4),
              Text(
                'Cuando hagas tu primer pedido aparece aquí\ncon todo el detalle.',
                textAlign: TextAlign.center,
                style: AppTextStyles.body(size: 12, color: AppColors.muted),
              ),
              if (onVerMenu != null) ...[
                const SizedBox(height: 18),
                TextButton(
                  onPressed: onVerMenu,
                  child: Text('Ver el menú',
                      style: AppTextStyles.heading(
                          size: 12.5, color: AppColors.mostaza)),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(18),
      itemCount: pedidos.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) => _TarjetaPedido(order: pedidos[index]),
    );
  }
}

/// Tarjeta de un pedido: lo que manda es el producto principal con su foto,
/// no el número del pedido. Todo sale de lo que el cliente realmente pidió.
class _TarjetaPedido extends StatelessWidget {
  final Order order;
  const _TarjetaPedido({required this.order});

  @override
  Widget build(BuildContext context) {
    final principal = order.lineaPrincipal;
    final otros = order.lineas.length - 1;

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => OrderDetailScreen(order: order)),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Foto del producto principal del pedido.
                if (principal != null)
                  AppImage(
                    principal.imageAsset,
                    fallbackUrl: principal.imageUrl,
                    placeholderIcon: iconoDeCategoria(principal.categoria),
                    width: 58,
                    height: 58,
                    borderRadius: BorderRadius.circular(12),
                  ),
                if (principal != null) const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        principal == null
                            ? 'Pedido #${order.id}'
                            : '${principal.cantidad} × ${principal.nombre}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.heading(size: 12.5),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          if (otros > 0) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.crema2,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Text(
                                '+$otros ${otros == 1 ? "producto" : "productos"}',
                                style: AppTextStyles.heading(
                                    size: 9.5, color: AppColors.mostaza),
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                          Flexible(
                            child: Text(
                              '${order.itemCount} en total · ${order.fechaTexto}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.body(
                                  size: 10.5, color: AppColors.muted),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(formatoPesos(order.total),
                  style: AppTextStyles.heading(size: 13, color: AppColors.verde)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Flexible(child: OrderStatusBadge(status: order.status)),
                const Spacer(),
                Text('Pedido #${order.id}',
                    style:
                        AppTextStyles.body(size: 10, color: AppColors.muted)),
                const Icon(Icons.chevron_right_rounded,
                    size: 18, color: AppColors.muted),
              ],
            ),
            if (order.note != null) ...[
              const SizedBox(height: 6),
              Text(order.note!,
                  style: AppTextStyles.body(size: 11, color: AppColors.tomate)),
            ],
          ],
        ),
      ),
    );
  }
}
