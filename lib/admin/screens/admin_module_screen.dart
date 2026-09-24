import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../state/app_scope.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../data/admin_repository.dart';
import '../models/permisos.dart';
import '../widgets/admin_card.dart';
import '../widgets/admin_search_bar.dart';
import '../widgets/admin_states.dart';
import '../../widgets/app_image.dart';

/// Pantalla base para los módulos CRUD locales del panel.
class AdminModuleScreen extends StatefulWidget {
  final ModuloAdmin modulo;
  final bool mostrarRegreso;

  const AdminModuleScreen(
      {super.key, required this.modulo, this.mostrarRegreso = false});

  @override
  State<AdminModuleScreen> createState() => _AdminModuleScreenState();
}

class _AdminModuleScreenState extends State<AdminModuleScreen> {
  final _busqueda = TextEditingController();
  String _texto = '';

  @override
  void dispose() {
    _busqueda.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repository = AppScope.admin(context);
    final registros = repository.buscar(widget.modulo, _texto);
    final puedeCrear =
        puede(AppScope.usuario(context).rol, widget.modulo, Permiso.crear);

    return Container(
      color: AppColors.crema,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (widget.mostrarRegreso)
                      IconButton(
                        tooltip: 'Volver',
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                    Icon(widget.modulo.icono, color: AppColors.mostaza),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Text(widget.modulo.label,
                            style: AppTextStyles.heading(size: 22))),
                    if (puedeCrear)
                      IconButton(
                        tooltip: 'Crear',
                        onPressed: () => _nuevo(context),
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    Text('${registros.length}',
                        style: AppTextStyles.body(
                            size: 12, color: AppColors.muted)),
                  ],
                ),
                const SizedBox(height: 12),
                AdminSearchBar(
                  hint: 'Buscar en ${widget.modulo.label.toLowerCase()}',
                  controller: _busqueda,
                  onBuscar: (value) => setState(() => _texto = value),
                ),
              ],
            ),
          ),
          Expanded(
            child: registros.isEmpty
                ? AdminEmptyState(
                    icono: widget.modulo.icono,
                    titulo: 'No hay registros',
                    detalle:
                        'Agrega el primer registro de ${widget.modulo.label.toLowerCase()}.',
                    accion: puedeCrear
                        ? FilledButton.icon(
                            onPressed: () => _nuevo(context),
                            icon: const Icon(Icons.add),
                            label: const Text('Crear'))
                        : null,
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: registros.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, index) => _RegistroCard(
                      modulo: widget.modulo,
                      registro: registros[index],
                      puedeEditar: puede(AppScope.usuario(context).rol,
                          widget.modulo, Permiso.editar),
                      puedeEliminar: puede(AppScope.usuario(context).rol,
                          widget.modulo, Permiso.eliminar),
                      puedeEstado: puede(AppScope.usuario(context).rol,
                          widget.modulo, Permiso.cambiarEstado),
                      onEstado: () => repository.cambiarEstado(registros[index]),
                      onEliminar: () => _eliminar(context, registros[index]),
                      onDetalle: () => _detalle(context, registros[index]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _detalle(BuildContext context, AdminRegistro registro) {
    final detalleExtra = <_DetalleFila>[];
    final producto = widget.modulo == ModuloAdmin.productos
        ? productoPorId(registro.id)
        : null;

    detalleExtra.add(_DetalleFila(etiqueta: 'Estado', valor: registro.estado));
    detalleExtra.add(_DetalleFila(etiqueta: 'Identificador', valor: registro.id));
    detalleExtra.add(_DetalleFila(etiqueta: 'Resumen', valor: registro.titulo));
    detalleExtra.add(_DetalleFila(etiqueta: 'Información', valor: registro.detalle));

    if (registro.cantidad != null) {
      detalleExtra.add(_DetalleFila(
        etiqueta: 'Cantidad',
        valor: '${registro.cantidad!.toStringAsFixed(registro.cantidad! % 1 == 0 ? 0 : 1)} unidades',
      ));
    }
    if (registro.valor != null) {
      detalleExtra.add(_DetalleFila(
        etiqueta: 'Valor',
        valor: '\$${registro.valor!.toStringAsFixed(0)} COP',
      ));
    }

    switch (widget.modulo) {
      case ModuloAdmin.inventario:
        detalleExtra.add(const _DetalleFila(
          etiqueta: 'Control',
          valor: 'Se recomienda revisar stock mínimo y reposición semanal.',
        ));
        break;
      case ModuloAdmin.compras:
        detalleExtra.add(const _DetalleFila(
          etiqueta: 'Seguimiento',
          valor: 'Verificar proveedor, fechas de entrega y recepción del material.',
        ));
        break;
      case ModuloAdmin.produccion:
        detalleExtra.add(const _DetalleFila(
          etiqueta: 'Despacho',
          valor: 'El tiempo incluye producción, empaque y despacho.',
        ));
        break;
      case ModuloAdmin.ventas:
        detalleExtra.add(const _DetalleFila(
          etiqueta: 'Impacto',
          valor: 'Revisar ticket promedio, método de pago y anomalías del día.',
        ));
        break;
      case ModuloAdmin.perdidas:
        detalleExtra.add(const _DetalleFila(
          etiqueta: 'Acción',
          valor: 'Se debe revisar causa raíz para evitar repetición del desecho.',
        ));
        break;
      case ModuloAdmin.fichasTecnicas:
        detalleExtra.add(const _DetalleFila(
          etiqueta: 'Versiones',
          valor: 'Vigente y anteriores disponibles.',
        ));
        break;
      case ModuloAdmin.devoluciones:
        detalleExtra.add(const _DetalleFila(
          etiqueta: 'Política',
          valor: 'Dinero solo después de 2 horas o sin reposición.',
        ));
        break;
      default:
        detalleExtra.add(_DetalleFila(
          etiqueta: 'Observación',
          valor: 'Registro activo dentro del módulo ${widget.modulo.label.toLowerCase()}.',
        ));
        break;
    }

    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Row(children: [
          Icon(widget.modulo.icono, color: AppColors.mostaza),
          const SizedBox(width: 8),
          Expanded(child: Text(registro.titulo)),
        ]),
        content: SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (producto != null)
                  ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: AppImage(
                        producto.imageAsset,
                        fallbackUrl: producto.imageUrl,
                        placeholderIcon: producto.category == 'Bebidas'
                            ? Icons.local_drink_outlined
                            : Icons.lunch_dining_outlined,
                        height: 180,
                        width: double.infinity,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _DetalleFila(
                      etiqueta: 'Ingredientes',
                      valor: producto.ingredientes.isEmpty
                          ? 'No especificados'
                          : producto.ingredientes.join(' · '),
                    ),
                  ],
                ...detalleExtra,
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'))
        ],
      ),
    );
  }

  Future<void> _nuevo(BuildContext context) async {
    final repository = AppScope.adminSinEscuchar(context);

    final nombre = TextEditingController();
    final detalle = TextEditingController();
    final extra1 = TextEditingController();
    final extra2 = TextEditingController();
    final extra3 = TextEditingController();

    final campos = switch (widget.modulo) {
      ModuloAdmin.proveedores => [
          const InputDecoration(labelText: 'Nombre del proveedor'),
          const InputDecoration(labelText: 'NIT'),
          const InputDecoration(labelText: 'Contacto principal'),
          const InputDecoration(labelText: 'Observaciones'),
        ],
      ModuloAdmin.compras => [
          const InputDecoration(labelText: 'Proveedor'),
          const InputDecoration(labelText: 'Insumos adquiridos'),
          const InputDecoration(labelText: 'Fecha de entrega'),
          const InputDecoration(labelText: 'Monto total'),
        ],
      ModuloAdmin.produccion => [
          const InputDecoration(labelText: 'Orden de producción'),
          const InputDecoration(labelText: 'Producto a elaborar'),
          const InputDecoration(labelText: 'Cantidad'),
          const InputDecoration(labelText: 'Tiempo estimado'),
        ],
      ModuloAdmin.pedidos => [
          const InputDecoration(labelText: 'Cliente'),
          const InputDecoration(labelText: 'Método de pago'),
          const InputDecoration(labelText: 'Dirección / retiro'),
          const InputDecoration(labelText: 'Detalle del pedido'),
        ],
      ModuloAdmin.devoluciones => [
          const InputDecoration(labelText: 'Pedido / venta'),
          const InputDecoration(labelText: 'Cliente'),
          const InputDecoration(labelText: 'Motivo de devolución'),
          const InputDecoration(labelText: 'Acción propuesta'),
        ],
      _ => [
          const InputDecoration(labelText: 'Nombre o referencia'),
          const InputDecoration(labelText: 'Detalle'),
          const InputDecoration(labelText: 'Información adicional'),
          const InputDecoration(labelText: 'Observación'),
        ],
    };

    final guardado = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Nuevo ${widget.modulo.label.substring(0, 1).toUpperCase()}${widget.modulo.label.substring(1)}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombre,
                decoration: campos[0],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: detalle,
                decoration: campos[1],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: extra1,
                decoration: campos[2],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: extra2,
                decoration: campos[3],
              ),
              if (widget.modulo == ModuloAdmin.pedidos ||
                  widget.modulo == ModuloAdmin.compras)
                ...[
                  const SizedBox(height: 10),
                  TextField(
                    controller: extra3,
                    decoration: const InputDecoration(labelText: 'Observaciones'),
                  ),
                ],
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () {
                if (nombre.text.trim().isNotEmpty) Navigator.pop(context, true);
              },
              child: const Text('Guardar')),
        ],
      ),
    );

    if (guardado == true && mounted) {
      final resumen = nombre.text.trim();
      final cuerpo = [
        detalle.text.trim(),
        extra1.text.trim(),
        extra2.text.trim(),
        extra3.text.trim(),
      ].where((v) => v.isNotEmpty).join(' · ');

      repository.agregar(
        widget.modulo,
        titulo: resumen,
        detalle: cuerpo.isEmpty ? 'Registro creado desde el módulo.' : cuerpo,
      );
    }

    nombre.dispose();
    detalle.dispose();
    extra1.dispose();
    extra2.dispose();
    extra3.dispose();
  }

  Future<void> _eliminar(BuildContext context, AdminRegistro registro) async {
    final eliminado =
        AppScope.adminSinEscuchar(context).eliminar(widget.modulo, registro);
    if (!eliminado && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('No se puede eliminar: tiene compras asociadas.')));
    }
  }
}

class _RegistroCard extends StatelessWidget {
  final ModuloAdmin modulo;
  final AdminRegistro registro;
  final bool puedeEditar;
  final bool puedeEliminar;
  final bool puedeEstado;
  final VoidCallback onEstado;
  final VoidCallback onEliminar;
  final VoidCallback onDetalle;

  const _RegistroCard(
      {required this.modulo,
      required this.registro,
      required this.puedeEditar,
      required this.puedeEliminar,
      required this.puedeEstado,
      required this.onEstado,
      required this.onEliminar,
      required this.onDetalle});

  @override
  Widget build(BuildContext context) {
    return AdminCard(
      onTap: onDetalle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
                child: Text(registro.titulo,
                    style: AppTextStyles.heading(size: 14))),
            _Estado(texto: registro.estado),
          ]),
          const SizedBox(height: 7),
          Text(registro.detalle,
              style: AppTextStyles.body(size: 12, color: AppColors.muted)),
          if (registro.valor != null) ...[
            const SizedBox(height: 6),
            Text('\$${registro.valor!.toStringAsFixed(0)} COP',
                style:
                    AppTextStyles.heading(size: 13, color: AppColors.tomate)),
          ],
          if (puedeEditar || puedeEliminar || puedeEstado) ...[
            const Divider(height: 22),
            Row(children: [
              if (puedeEstado)
                TextButton.icon(
                    onPressed: onEstado,
                    icon: const Icon(Icons.sync, size: 17),
                    label: const Text('Cambiar estado')),
              const Spacer(),
              if (puedeEliminar)
                IconButton(
                    tooltip: 'Eliminar',
                    onPressed: onEliminar,
                    icon: const Icon(Icons.delete_outline)),
            ]),
          ],
        ],
      ),
    );
  }
}

class _DetalleFila extends StatelessWidget {
  final String etiqueta;
  final String valor;
  const _DetalleFila({required this.etiqueta, required this.valor});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(etiqueta.toUpperCase(),
              style: AppTextStyles.body(size: 10, color: AppColors.muted)),
          const SizedBox(height: 3),
          Text(valor,
              style: AppTextStyles.body(size: 13, weight: FontWeight.w600)),
        ]),
      );
}

class _Estado extends StatelessWidget {
  final String texto;
  const _Estado({required this.texto});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
            color: AppColors.crema2, borderRadius: BorderRadius.circular(20)),
        child: Text(texto,
            style: AppTextStyles.body(size: 10, weight: FontWeight.w700)),
      );
}
