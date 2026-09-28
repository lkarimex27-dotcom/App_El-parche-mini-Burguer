import 'package:flutter/material.dart';
import '../../admin/data/admin_mock.dart';
import '../../admin/data/admin_repository.dart';
import '../../admin/models/permisos.dart';
import '../../admin/widgets/admin_card.dart';
import '../../admin/widgets/admin_states.dart';
import '../../admin/widgets/metric_card.dart';
import '../../state/app_scope.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/aparicion.dart';

/// El inicio del empleado: su turno, no el negocio.
///
/// A propósito no muestra nada de plata —ventas del día, ticket promedio,
/// meta, gráfica de ingresos—: eso es del administrador. Aquí va lo que el
/// empleado tiene que hacer hoy: qué producir, qué se está acabando y a qué
/// módulos entra a trabajar.
class InicioEmpleadoScreen extends StatelessWidget {
  /// Para que los accesos rápidos cambien de pestaña o abran el módulo.
  final void Function(ModuloAdmin modulo)? onAbrirModulo;

  const InicioEmpleadoScreen({super.key, this.onAbrirModulo});

  @override
  Widget build(BuildContext context) {
    final usuario = AppScope.usuario(context);
    final repositorio = AppScope.admin(context);

    final ordenes = repositorio.registros(ModuloAdmin.produccion);
    final pendientes =
        ordenes.where((o) => o.estado != 'Terminada').toList(growable: false);
    final criticos = insumosBajos.where((i) => i.esCritico).length;

    return Container(
      color: AppColors.crema,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Aparicion(orden: 0, child: _saludo(usuario.primerNombre)),
          const SizedBox(height: 16),

          // ── Lo que hay que hacer hoy ──
          Aparicion(
            orden: 1,
            child: Row(
              children: [
                Expanded(
                  child: MetricCard(
                    etiqueta: 'Órdenes por hacer',
                    valor: '${pendientes.length}',
                    icono: Icons.restaurant_rounded,
                    onTap: () => onAbrirModulo?.call(ModuloAdmin.produccion),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: MetricCard(
                    etiqueta: 'Insumos por reponer',
                    valor: '${insumosBajos.length}',
                    icono: Icons.inventory_2_outlined,
                    detalle: criticos == 0
                        ? 'Ninguno crítico'
                        : '$criticos ${criticos == 1 ? "crítico" : "críticos"}',
                    color:
                        criticos == 0 ? AppColors.mostaza : AppColors.tomate,
                    onTap: () => onAbrirModulo?.call(ModuloAdmin.inventario),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // ── Órdenes de producción ──
          const TituloSeccion(titulo: 'En producción'),
          Aparicion(
            orden: 2,
            child: AdminCard(
              child: pendientes.isEmpty
                  ? const AdminEmptyState(
                      icono: Icons.check_circle_outline_rounded,
                      titulo: 'Nada pendiente',
                      detalle: 'No hay órdenes de producción por atender.',
                    )
                  : Column(
                      children: [
                        for (var i = 0; i < pendientes.length; i++) ...[
                          if (i > 0)
                            const Divider(height: 18, color: AppColors.borde),
                          _Orden(orden: pendientes[i]),
                        ],
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 18),

          // ── Insumos que se están acabando ──
          const TituloSeccion(titulo: 'Se está acabando'),
          Aparicion(
            orden: 3,
            child: AdminCard(
              child: insumosBajos.isEmpty
                  ? const AdminEmptyState(
                      icono: Icons.inventory_rounded,
                      titulo: 'Inventario al día',
                      detalle: 'Ningún insumo por debajo del mínimo.',
                    )
                  : Column(
                      children: [
                        for (var i = 0; i < insumosBajos.length; i++) ...[
                          if (i > 0)
                            const Divider(height: 18, color: AppColors.borde),
                          _Insumo(
                            insumo: insumosBajos[i],
                            onComprar: () =>
                                onAbrirModulo?.call(ModuloAdmin.compras),
                          ),
                        ],
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 18),

          // ── Lo más pedido, para saber qué alistar ──
          const TituloSeccion(titulo: 'Lo que más se pide'),
          Aparicion(
            orden: 4,
            child: AdminCard(
              child: Column(
                children: [
                  for (var i = 0; i < masVendidos.length; i++) ...[
                    if (i > 0) const Divider(height: 16, color: AppColors.borde),
                    Row(
                      children: [
                        Text('${i + 1}',
                            style: AppTextStyles.heading(
                                size: 12, color: AppColors.mostaza)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                              masVendidos[i].producto?.name ?? 'Producto',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.body(size: 12.5)),
                        ),
                        Text('${masVendidos[i].unidades}',
                            style: AppTextStyles.heading(size: 12.5)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _saludo(String nombre) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nombre.isEmpty ? 'Hola' : 'Hola, $nombre',
                style: AppTextStyles.heading(size: 17),
              ),
              const SizedBox(height: 2),
              Text('Esto es lo que hay para hoy',
                  style:
                      AppTextStyles.body(size: 12, color: AppColors.muted)),
            ],
          ),
        ),
      ],
    );
  }
}

class _Orden extends StatelessWidget {
  final AdminRegistro orden;
  const _Orden({required this.orden});

  @override
  Widget build(BuildContext context) {
    // Lo pendiente resalta; lo que ya está en marcha se ve más tranquilo.
    final enEspera = orden.estado == 'Pendiente';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(orden.titulo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.heading(size: 12.5)),
              const SizedBox(height: 2),
              Text(orden.detalle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style:
                      AppTextStyles.body(size: 11, color: AppColors.muted)),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(
            color: (enEspera ? AppColors.mostaza : AppColors.verde)
                .withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(
            orden.estado,
            style: AppTextStyles.heading(
              size: 9.5,
              color: enEspera ? AppColors.mostaza : AppColors.verde,
            ),
          ),
        ),
      ],
    );
  }
}

class _Insumo extends StatelessWidget {
  final InsumoBajo insumo;
  final VoidCallback onComprar;

  const _Insumo({required this.insumo, required this.onComprar});

  @override
  Widget build(BuildContext context) {
    final color = insumo.esCritico ? AppColors.tomate : AppColors.ambar;

    return Row(
      children: [
        Icon(Icons.warning_amber_rounded, size: 17, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(insumo.nombre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.heading(size: 12.5)),
              const SizedBox(height: 2),
              Text(
                'Quedan ${insumo.stock} de ${insumo.minimo} ${insumo.unidad}',
                style: AppTextStyles.body(size: 11, color: AppColors.muted),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: onComprar,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.mostaza,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text('Comprar',
              style: AppTextStyles.heading(
                  size: 11, color: AppColors.mostaza)),
        ),
      ],
    );
  }
}
