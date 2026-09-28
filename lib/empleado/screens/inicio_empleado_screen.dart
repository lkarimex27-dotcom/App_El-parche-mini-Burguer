import 'package:flutter/material.dart';
import '../../admin/data/admin_mock.dart';
import '../../admin/models/permisos.dart';
import '../../admin/widgets/admin_card.dart';
import '../../admin/widgets/admin_states.dart';
import '../../models/order.dart';
import '../../screens/order_detail_screen.dart';
import '../../state/app_scope.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/aparicion.dart';
import '../../widgets/order_status_badge.dart';
import 'pedidos_filtrados_screen.dart';

/// El inicio del empleado: su turno, no el negocio.
///
/// El orden es el de su jornada: primero lo que se va a acabar, después lo
/// siguiente que tiene que hacer, después cómo van los pedidos del día, y
/// al final la meta y los accesos. A propósito no muestra ventas ni ticket
/// promedio: esa es información del dueño.
class InicioEmpleadoScreen extends StatelessWidget {
  /// Para que los accesos rápidos cambien de pestaña o abran el módulo.
  final void Function(ModuloAdmin modulo)? onAbrirModulo;

  const InicioEmpleadoScreen({super.key, this.onAbrirModulo});

  /// La meta de pedidos entregados en el día. Es de pedidos y no de plata:
  /// lo que el empleado puede mover con su trabajo.
  static const int metaDePedidos = 20;

  @override
  Widget build(BuildContext context) {
    final usuario = AppScope.usuario(context);
    final pedidos = AppScope.pedidos(context).pedidos;

    final hoy = pedidos.where(_esDeHoy).toList(growable: false);
    final enCurso = hoy.where(_estaEnCurso).toList(growable: false);
    final listos = hoy.where(_estaListo).toList(growable: false);
    final pendientes = hoy
        .where((p) => p.status == OrderStatus.pendiente)
        .toList(growable: false);
    final entregados = hoy
        .where((p) => p.status == OrderStatus.entregado)
        .toList(growable: false);

    // Lo siguiente que hay que preparar: lo que ya está en marcha antes que
    // lo que apenas entró, y dentro de eso el más viejo primero.
    final porHacer = [...enCurso, ...pendientes]
      ..sort((a, b) => a.fecha.compareTo(b.fecha));
    final proxima = porHacer.isEmpty ? null : porHacer.first;

    return Container(
      color: AppColors.fondo(context),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Aparicion(orden: 0, child: _saludo(context, usuario.primerNombre)),
          const SizedBox(height: 14),

          // ── 1. Lo que se va a acabar ──
          Aparicion(orden: 1, child: _Alertas(onAbrirModulo: onAbrirModulo)),

          // ── 2. La próxima tarea ──
          Aparicion(
            orden: 2,
            child: _ProximaTarea(
              pedido: proxima,
              onTap: proxima == null
                  ? null
                  : () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => OrderDetailScreen(order: proxima),
                        ),
                      ),
            ),
          ),
          const SizedBox(height: 18),

          // ── 3. Cómo van los pedidos de hoy ──
          Aparicion(
            orden: 3,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _TarjetaPedidos(
                        etiqueta: 'Pedidos de hoy',
                        cantidad: hoy.length,
                        icono: Icons.receipt_long_rounded,
                        color: AppColors.mostaza,
                        onTap: () => _verPedidos(context, 'Pedidos de hoy', hoy),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _TarjetaPedidos(
                        etiqueta: 'En curso',
                        cantidad: enCurso.length,
                        icono: Icons.outdoor_grill_rounded,
                        color: AppColors.ambar,
                        onTap: () =>
                            _verPedidos(context, 'En curso', enCurso),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _TarjetaPedidos(
                        etiqueta: 'Listos',
                        cantidad: listos.length,
                        icono: Icons.shopping_bag_rounded,
                        color: AppColors.verde,
                        onTap: () => _verPedidos(context, 'Listos', listos),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _TarjetaPedidos(
                        etiqueta: 'Pendientes',
                        cantidad: pendientes.length,
                        icono: Icons.pending_actions_rounded,
                        color: AppColors.tomate,
                        onTap: () =>
                            _verPedidos(context, 'Pendientes', pendientes),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // ── 4. La meta del día ──
          Aparicion(
            orden: 4,
            child: _Meta(entregados: entregados.length, meta: metaDePedidos),
          ),
          const SizedBox(height: 18),

          // ── 5. Accesos rápidos ──
          const TituloSeccion(titulo: 'Accesos rápidos'),
          Aparicion(
            orden: 5,
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _Acceso(
                  icono: Icons.outdoor_grill_outlined,
                  label: 'Producción',
                  onTap: () => onAbrirModulo?.call(ModuloAdmin.produccion),
                ),
                _Acceso(
                  icono: Icons.inventory_2_outlined,
                  label: 'Inventario',
                  onTap: () => onAbrirModulo?.call(ModuloAdmin.inventario),
                ),
                _Acceso(
                  icono: Icons.menu_book_outlined,
                  label: 'Fichas técnicas',
                  onTap: () => onAbrirModulo?.call(ModuloAdmin.fichasTecnicas),
                ),
                _Acceso(
                  icono: Icons.lunch_dining_outlined,
                  label: 'Productos',
                  onTap: () => onAbrirModulo?.call(ModuloAdmin.productos),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // ── 6. Pedidos recientes ──
          const TituloSeccion(titulo: 'Pedidos recientes'),
          Aparicion(
            orden: 6,
            child: AdminCard(
              child: hoy.isEmpty
                  ? const AdminEmptyState(
                      icono: Icons.receipt_long_outlined,
                      titulo: 'Sin pedidos hoy',
                      detalle: 'Los que entren van a aparecer aquí.',
                    )
                  : Column(
                      children: [
                        for (var i = 0; i < hoy.length && i < 5; i++) ...[
                          if (i > 0)
                            Divider(
                                height: 18, color: AppColors.linea(context)),
                          _FilaPedido(pedido: hoy[i]),
                        ],
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _verPedidos(BuildContext context, String titulo, List<Order> pedidos) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PedidosFiltradosScreen(titulo: titulo, pedidos: pedidos),
      ),
    );
  }

  static bool _esDeHoy(Order pedido) {
    final ahora = DateTime.now();
    return pedido.fecha.year == ahora.year &&
        pedido.fecha.month == ahora.month &&
        pedido.fecha.day == ahora.day;
  }

  /// Lo que la cocina tiene entre manos.
  static bool _estaEnCurso(Order pedido) =>
      pedido.status == OrderStatus.aprobado ||
      pedido.status == OrderStatus.preparacion;

  /// Listo para entregar: esperando en el local o ya con el repartidor.
  static bool _estaListo(Order pedido) =>
      pedido.status == OrderStatus.listo ||
      pedido.status == OrderStatus.enLocal ||
      pedido.status == OrderStatus.enCamino;

  Widget _saludo(BuildContext context, String nombre) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          nombre.isEmpty ? 'Hola' : 'Hola, $nombre',
          style: AppTextStyles.heading(size: 17, color: AppColors.texto(context)),
        ),
        const SizedBox(height: 2),
        Text('Esto es lo que hay para hoy',
            style: AppTextStyles.body(
                size: 12, color: AppColors.textoSuave(context))),
      ],
    );
  }
}

/// Lo que se está acabando. Va de primero porque es lo único que, si nadie
/// lo mira a tiempo, para la cocina.
class _Alertas extends StatelessWidget {
  final void Function(ModuloAdmin modulo)? onAbrirModulo;
  const _Alertas({required this.onAbrirModulo});

  @override
  Widget build(BuildContext context) {
    if (insumosBajos.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        for (final insumo in insumosBajos)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: (insumo.esCritico ? AppColors.tomate : AppColors.ambar)
                  .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded,
                    size: 18,
                    color:
                        insumo.esCritico ? AppColors.tomate : AppColors.ambar),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Va a faltar ${insumo.nombre.toLowerCase()}: quedan '
                    '${insumo.stock} de ${insumo.minimo} ${insumo.unidad}',
                    style: AppTextStyles.body(
                        size: 11.5, color: AppColors.texto(context)),
                  ),
                ),
                // Lleva a Inventario y no a Compras: comprar es del
                // administrador; lo del empleado es avisar y descargar.
                TextButton(
                  onPressed: () => onAbrirModulo?.call(ModuloAdmin.inventario),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text('Ver',
                      style: AppTextStyles.heading(
                          size: 11, color: AppColors.mostaza)),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// La tarjeta grande de lo siguiente que hay que preparar.
class _ProximaTarea extends StatelessWidget {
  final Order? pedido;
  final VoidCallback? onTap;

  const _ProximaTarea({required this.pedido, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = pedido;

    return AdminCard(
      onTap: onTap,
      borde: p == null ? null : AppColors.mostaza,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.mostaza.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              p == null ? Icons.check_circle_outline_rounded : Icons.timer_rounded,
              color: AppColors.mostaza,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Próxima tarea',
                    style: AppTextStyles.body(
                        size: 11, color: AppColors.textoSuave(context))),
                const SizedBox(height: 3),
                Text(
                  p == null ? 'Nada pendiente' : 'Preparar pedido #${p.id}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.heading(
                      size: 15, color: AppColors.texto(context)),
                ),
                const SizedBox(height: 2),
                Text(
                  p == null
                      ? 'No hay pedidos por preparar'
                      : 'Entrega estimada ${_estimado(p)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body(
                      size: 11.5, color: AppColors.textoSuave(context)),
                ),
              ],
            ),
          ),
          if (p != null)
            Icon(Icons.chevron_right_rounded,
                color: AppColors.textoSuave(context)),
        ],
      ),
    );
  }

  /// Lo que falta para la hora de entrega. Si el pedido ya trae la hora del
  /// backend manda esa; si no, se cuenta desde que entró.
  String _estimado(Order pedido) {
    final dada = pedido.horaEstimada;
    if (dada != null && dada.isNotEmpty) return dada;

    const prometidos = 25;
    final pasados = DateTime.now().difference(pedido.fecha).inMinutes;
    final faltan = prometidos - pasados;
    if (faltan <= 0) return 'ya vencida';
    return '$faltan min';
  }
}

/// Una de las cuatro tarjetas de pedidos: cuántos hay y a dónde llevan.
class _TarjetaPedidos extends StatelessWidget {
  final String etiqueta;
  final int cantidad;
  final IconData icono;
  final Color color;
  final VoidCallback onTap;

  const _TarjetaPedidos({
    required this.etiqueta,
    required this.cantidad,
    required this.icono,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AdminCard(
      onTap: onTap,
      padding: const EdgeInsets.all(13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icono, size: 16, color: color),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  etiqueta,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body(
                      size: 10, color: AppColors.textoSuave(context)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('$cantidad',
              style: AppTextStyles.heading(size: 19, color: color)),
        ],
      ),
    );
  }
}

/// La meta del día, contada en pedidos entregados. Se calcula de los
/// pedidos reales: no es un número escrito a mano.
class _Meta extends StatelessWidget {
  final int entregados;
  final int meta;

  const _Meta({required this.entregados, required this.meta});

  @override
  Widget build(BuildContext context) {
    final avance = meta == 0 ? 0.0 : (entregados / meta).clamp(0.0, 1.0);
    final faltan = (meta - entregados).clamp(0, meta);
    final cumplida = entregados >= meta;

    return AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Meta del día',
                    style: AppTextStyles.heading(
                        size: 13, color: AppColors.texto(context))),
              ),
              Text('$entregados de $meta',
                  style: AppTextStyles.heading(
                      size: 12.5,
                      color: cumplida ? AppColors.verde : AppColors.mostaza)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: avance,
              minHeight: 10,
              backgroundColor: AppColors.linea(context),
              valueColor: AlwaysStoppedAnimation<Color>(
                cumplida ? AppColors.verde : AppColors.mostaza,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            cumplida
                ? '¡Meta cumplida! ${entregados == meta ? "" : "+${entregados - meta} "}'
                    'pedidos entregados hoy'
                : 'Faltan $faltan ${faltan == 1 ? "pedido" : "pedidos"} '
                    'para llegar a la meta',
            style: AppTextStyles.body(
                size: 11, color: AppColors.textoSuave(context)),
          ),
        ],
      ),
    );
  }
}

class _Acceso extends StatelessWidget {
  final IconData icono;
  final String label;
  final VoidCallback onTap;

  const _Acceso({
    required this.icono,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.superficie(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.linea(context)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, size: 16, color: AppColors.mostaza),
            const SizedBox(width: 7),
            Text(label,
                style: AppTextStyles.body(
                    size: 11.5,
                    weight: FontWeight.w600,
                    color: AppColors.texto(context))),
          ],
        ),
      ),
    );
  }
}

class _FilaPedido extends StatelessWidget {
  final Order pedido;
  const _FilaPedido({required this.pedido});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => OrderDetailScreen(order: pedido)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pedido #${pedido.id}',
                      style: AppTextStyles.heading(
                          size: 12.5, color: AppColors.texto(context))),
                  const SizedBox(height: 2),
                  Text(
                    '${pedido.itemCount} productos · ${pedido.fechaTexto}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body(
                        size: 11, color: AppColors.textoSuave(context)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            OrderStatusBadge(status: pedido.status),
          ],
        ),
      ),
    );
  }
}
