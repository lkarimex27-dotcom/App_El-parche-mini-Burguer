import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../models/product.dart';
import '../../models/rol.dart';
import '../../state/app_scope.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/aparicion.dart';
import '../../widgets/app_image.dart';
import '../../widgets/order_status_badge.dart';
import '../data/admin_mock.dart';
import '../models/permisos.dart';
import '../widgets/admin_card.dart';
import '../widgets/admin_states.dart';
import '../widgets/metric_card.dart';
import '../widgets/ventas_chart.dart';
import '../../models/precio.dart';

/// Pantalla principal del panel: lo que el administrador necesita ver de
/// una, sin entrar a ningún módulo.
class DashboardScreen extends StatelessWidget {
  /// Para que los accesos rápidos y "ver todos" cambien de pestaña.
  final void Function(ModuloAdmin modulo)? onAbrirModulo;

  const DashboardScreen({super.key, this.onAbrirModulo});

  @override
  Widget build(BuildContext context) {
    final usuario = AppScope.usuario(context);
    final pedidos = AppScope.pedidos(context).pedidos;

    final porAprobar = pedidos.where((p) => p.requiereAprobacion).toList();
    final enCurso = pedidos.where((p) => !p.estaCerrado).length;
    final ticketPromedio = pedidos.isEmpty
        ? 0
        : (pedidos.fold<int>(0, (sum, p) => sum + p.total) / pedidos.length)
            .round();
    const metaDiaria = 1500000;
    final cumplimientoMeta = ventasHoy / metaDiaria;
    final entregadosHoy =
        pedidos.where((p) => p.status == OrderStatus.entregado).length;

    return Container(
      color: AppColors.crema,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Aparicion(
            orden: 0,
            child: _saludo(usuario.primerNombre, usuario.rol.label),
          ),
          const SizedBox(height: 16),

          // ── Alertas que piden acción ──
          Aparicion(
            orden: 1,
            child: Column(
              children: [
                for (final insumo in insumosBajos)
                  _Alerta(
                    icono: Icons.warning_amber_rounded,
                    color:
                        insumo.esCritico ? AppColors.tomate : AppColors.ambar,
                    texto: '${insumo.nombre} por debajo del stock mínimo '
                        '(${insumo.stock} de ${insumo.minimo} ${insumo.unidad})',
                    onTap: () => onAbrirModulo?.call(ModuloAdmin.inventario),
                  ),
                for (final pedido in porAprobar)
                  _Alerta(
                    icono: Icons.pending_actions_rounded,
                    color: AppColors.mostaza,
                    texto:
                        'Pedido #${pedido.id} por ${formatoPesos(pedido.total)} '
                        'requiere aprobación',
                    onTap: () => onAbrirModulo?.call(ModuloAdmin.pedidos),
                  ),
              ],
            ),
          ),

          // ── Indicadores clave del negocio ──
          Aparicion(
            orden: 2,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: MetricCard(
                        etiqueta: 'Ventas hoy',
                        valor: formatoPesos(ventasHoy),
                        icono: Icons.payments_outlined,
                        onTap: () => onAbrirModulo?.call(ModuloAdmin.ventas),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: MetricCard(
                        etiqueta: 'Ticket promedio',
                        valor: '\$${ticketPromedio.toString()}',
                        icono: Icons.account_balance_wallet_rounded,
                        color: AppColors.verde,
                        onTap: () => onAbrirModulo?.call(ModuloAdmin.ventas),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: MetricCard(
                        etiqueta: 'Meta del día',
                        valor:
                            '${(cumplimientoMeta * 100).clamp(0, 100).round()}%',
                        icono: Icons.flag_circle_rounded,
                        detalle:
                            '\$${metaDiaria.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.')}',
                        color: AppColors.mostaza,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: MetricCard(
                        etiqueta: 'Pedidos en curso',
                        valor: '$enCurso',
                        icono: Icons.receipt_long_outlined,
                        detalle: porAprobar.isEmpty
                            ? '$entregadosHoy entregados hoy'
                            : '${porAprobar.length} por aprobar',
                        color: porAprobar.isEmpty
                            ? AppColors.mostaza
                            : AppColors.tomate,
                        onTap: () => onAbrirModulo?.call(ModuloAdmin.pedidos),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Aparicion(
            orden: 3,
            child: AdminCard(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Cumplimiento de meta',
                          style: AppTextStyles.body(
                              size: 11,
                              weight: FontWeight.w700,
                              color: AppColors.carbon),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          '\$${ventasHoy.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.')} / \$${metaDiaria.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.')}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.end,
                          style: AppTextStyles.body(
                              size: 10, color: AppColors.muted),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: cumplimientoMeta.clamp(0.0, 1.0),
                    minHeight: 8,
                    backgroundColor: AppColors.crema2,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(AppColors.verde),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(cumplimientoMeta * 100).clamp(0, 100).round()}% de la meta diaria alcanzada',
                    style: AppTextStyles.body(size: 12, color: AppColors.muted),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),

          // ── Ventas por día ──
          const Aparicion(
            orden: 4,
            child: Column(
              children: [
                TituloSeccion(titulo: 'Ventas por día'),
                AdminCard(
                  child: VentasChart(
                    valores: ventasPorDia,
                    etiquetas: diasSemana,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          // ── Accesos rápidos ──
          Aparicion(
            orden: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TituloSeccion(titulo: 'Accesos rápidos'),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _Acceso(
                      icono: Icons.add_shopping_cart_rounded,
                      label: 'Nuevo pedido',
                      onTap: () => onAbrirModulo?.call(ModuloAdmin.pedidos),
                    ),
                    _Acceso(
                      icono: Icons.local_shipping_outlined,
                      label: 'Registrar compra',
                      onTap: () => onAbrirModulo?.call(ModuloAdmin.compras),
                    ),
                    _Acceso(
                      icono: Icons.lunch_dining_outlined,
                      label: 'Agregar producto',
                      onTap: () => onAbrirModulo?.call(ModuloAdmin.productos),
                    ),
                    _Acceso(
                      icono: Icons.report_gmailerrorred_outlined,
                      label: 'Registrar pérdida',
                      onTap: () => onAbrirModulo?.call(ModuloAdmin.perdidas),
                    ),
                    _Acceso(
                      icono: Icons.outdoor_grill_outlined,
                      label: 'Ver producción',
                      onTap: () => onAbrirModulo?.call(ModuloAdmin.produccion),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          // ── Productos más vendidos ──
          Aparicion(
            orden: 6,
            child: Column(
              children: [
                const TituloSeccion(titulo: 'Productos más vendidos'),
                AdminCard(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    children: [
                      for (final v in masVendidos)
                        if (v.producto != null) _FilaVendido(vendido: v),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          // ── Pedidos recientes ──
          Aparicion(
            orden: 7,
            child: Column(
              children: [
                TituloSeccion(
                  titulo: 'Pedidos recientes',
                  accion: pedidos.isEmpty ? null : 'Ver todos',
                  onAccion: () => onAbrirModulo?.call(ModuloAdmin.pedidos),
                ),
                if (pedidos.isEmpty)
                  const AdminCard(
                    child: AdminEmptyState(
                      icono: Icons.receipt_long_outlined,
                      titulo: 'Todavía no hay pedidos',
                      detalle: 'Aquí van apareciendo a medida que entran.',
                    ),
                  )
                else
                  for (final pedido in pedidos.take(3))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _FilaPedido(
                        pedido: pedido,
                        onTap: () => onAbrirModulo?.call(ModuloAdmin.pedidos),
                      ),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _saludo(String nombre, String rol) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nombre.isEmpty ? 'Hola, $rol' : 'Hola, $nombre',
                style: AppTextStyles.heading(size: 22),
              ),
              const SizedBox(height: 2),
              Text('Resumen de tu negocio',
                  style: AppTextStyles.body(size: 13, color: AppColors.muted)),
            ],
          ),
        ),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borde),
          ),
          child: const Icon(Icons.notifications_none_rounded,
              size: 20, color: AppColors.carbon),
        ),
      ],
    );
  }
}

class _Alerta extends StatelessWidget {
  final IconData icono;
  final Color color;
  final String texto;
  final VoidCallback? onTap;

  const _Alerta({
    required this.icono,
    required this.color,
    required this.texto,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AdminCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        color: color.withAlpha(18),
        borde: color.withAlpha(70),
        child: Row(
          children: [
            Icon(icono, size: 18, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Text(texto, style: AppTextStyles.body(size: 12.5)),
            ),
            const Icon(Icons.chevron_right_rounded,
                size: 18, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}

class _Acceso extends StatelessWidget {
  final IconData icono;
  final String label;
  final VoidCallback onTap;

  const _Acceso(
      {required this.icono, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Dos por fila en cualquier celular, contando el padding de la lista.
    final ancho = (MediaQuery.sizeOf(context).width - 32 - 10) / 2;

    return SizedBox(
      width: ancho,
      child: AdminCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.crema2,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icono, size: 17, color: AppColors.mostaza),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body(size: 12, weight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilaVendido extends StatelessWidget {
  final ProductoVendido vendido;
  const _FilaVendido({required this.vendido});

  @override
  Widget build(BuildContext context) {
    final producto = vendido.producto!;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
      leading: AppImage(
        producto.imageAsset,
        fallbackUrl: producto.imageUrl,
        placeholderIcon: iconoDeCategoria(producto.category),
        width: 40,
        height: 40,
        borderRadius: BorderRadius.circular(10),
      ),
      title: Text(producto.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.body(size: 13, weight: FontWeight.w600)),
      subtitle: Text(producto.category,
          style: AppTextStyles.body(size: 11, color: AppColors.muted)),
      trailing: Text('${vendido.unidades}',
          style: AppTextStyles.heading(size: 15, color: AppColors.mostaza)),
    );
  }
}

class _FilaPedido extends StatelessWidget {
  final Order pedido;
  final VoidCallback onTap;

  const _FilaPedido({required this.pedido, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final principal = pedido.lineaPrincipal;

    return AdminCard(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  principal == null
                      ? 'Pedido #${pedido.id}'
                      : '${principal.cantidad} × ${principal.nombre}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body(size: 13, weight: FontWeight.w600),
                ),
                const SizedBox(height: 3),
                Text('#${pedido.id} · ${pedido.fechaTexto}',
                    style:
                        AppTextStyles.body(size: 11, color: AppColors.muted)),
                const SizedBox(height: 6),
                OrderStatusBadge(status: pedido.status),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(formatoPesos(pedido.total),
              style: AppTextStyles.heading(size: 14, color: AppColors.verde)),
        ],
      ),
    );
  }
}
