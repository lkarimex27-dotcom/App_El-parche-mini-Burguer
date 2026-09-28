import 'package:flutter/material.dart';
import '../../admin/widgets/admin_card.dart';
import '../../admin/widgets/admin_states.dart';
import '../../models/order.dart';
import '../../screens/order_detail_screen.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/aparicion.dart';
import '../../widgets/order_status_badge.dart';

/// Lo que se abre al tocar una de las cuatro tarjetas del inicio: los
/// pedidos de ese grupo, y de cada uno se entra al detalle.
class PedidosFiltradosScreen extends StatelessWidget {
  final String titulo;
  final List<Order> pedidos;

  const PedidosFiltradosScreen({
    super.key,
    required this.titulo,
    required this.pedidos,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo(context),
      appBar: AppBar(
        backgroundColor: AppColors.superficie(context),
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.texto(context)),
        title: Text(titulo,
            style:
                AppTextStyles.heading(size: 15, color: AppColors.texto(context))),
      ),
      body: pedidos.isEmpty
          ? Center(
              child: AdminEmptyState(
                icono: Icons.receipt_long_outlined,
                titulo: 'Nada en $titulo',
                detalle: 'Cuando haya pedidos aquí, van a aparecer.',
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              itemCount: pedidos.length,
              itemBuilder: (context, i) => Aparicion(
                orden: i,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _Tarjeta(pedido: pedidos[i]),
                ),
              ),
            ),
    );
  }
}

class _Tarjeta extends StatelessWidget {
  final Order pedido;
  const _Tarjeta({required this.pedido});

  @override
  Widget build(BuildContext context) {
    final principal = pedido.lineaPrincipal;

    return AdminCard(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => OrderDetailScreen(order: pedido)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Pedido #${pedido.id}',
                    style: AppTextStyles.heading(
                        size: 13.5, color: AppColors.texto(context))),
              ),
              const SizedBox(width: 8),
              Flexible(child: OrderStatusBadge(status: pedido.status)),
            ],
          ),
          const SizedBox(height: 6),
          if (principal != null)
            Text(
              '${principal.cantidad} × ${principal.nombre}'
              '${pedido.lineas.length > 1 ? " y ${pedido.lineas.length - 1} más" : ""}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body(
                  size: 12, color: AppColors.texto(context)),
            ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.schedule_rounded,
                  size: 13, color: AppColors.textoSuave(context)),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  pedido.fechaTexto,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body(
                      size: 11, color: AppColors.textoSuave(context)),
                ),
              ),
              Text('${pedido.itemCount} productos',
                  style: AppTextStyles.body(
                      size: 11, color: AppColors.textoSuave(context))),
            ],
          ),
        ],
      ),
    );
  }
}
