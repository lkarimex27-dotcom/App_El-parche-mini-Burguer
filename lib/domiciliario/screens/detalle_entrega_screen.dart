import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/business_info.dart';
import '../../models/order.dart';
import '../../models/precio.dart';
import '../../services/enlaces.dart';
import '../../state/app_scope.dart';
import '../../state/orders_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/aparicion.dart';
import '../widgets/domiciliario_card.dart';
import '../widgets/estado_entrega_badge.dart';

class DetalleEntregaScreen extends StatelessWidget {
  final Order pedido;
  const DetalleEntregaScreen({super.key, required this.pedido});

  @override
  Widget build(BuildContext context) {
    final pedidos = AppScope.pedidos(context);
    return Scaffold(
      backgroundColor: AppColors.crema,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.carbon),
        title: Text('Entrega #${pedido.id}',
            style: AppTextStyles.heading(size: 16)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          Aparicion(child: _EstadoActual(pedido: pedido, pedidos: pedidos)),
          const SizedBox(height: 12),
          Aparicion(orden: 1, child: _ClienteEntrega(pedido: pedido)),
          const SizedBox(height: 12),
          Aparicion(orden: 2, child: _ProductosPedido(pedido: pedido)),
          const SizedBox(height: 12),
          Aparicion(orden: 3, child: _PagoPedido(pedido: pedido)),
          const SizedBox(height: 12),
          Aparicion(orden: 4, child: _Novedad(pedido: pedido)),
        ],
      ),
    );
  }
}

class _EstadoActual extends StatelessWidget {
  final Order pedido;
  final OrdersModel pedidos;
  const _EstadoActual({required this.pedido, required this.pedidos});

  OrderStatus? get siguiente {
    switch (pedido.status) {
      case OrderStatus.listo:
        return OrderStatus.enLocal;
      case OrderStatus.enLocal:
        return OrderStatus.enCamino;
      case OrderStatus.enCamino:
        return OrderStatus.entregado;
      case OrderStatus.pendiente:
      case OrderStatus.rechazado:
      case OrderStatus.aprobado:
      case OrderStatus.preparacion:
      case OrderStatus.entregado:
      case OrderStatus.cancelado:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final paso = siguiente;
    return DomiciliarioCard(
      borde: pedido.status.color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Estado de la entrega',
                    style: AppTextStyles.heading(size: 13.5)),
              ),
              EstadoEntregaBadge(estado: pedido.status),
            ],
          ),
          if (paso != null) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _avanzar(context, paso),
                icon: Icon(paso.icon),
                label: Text(paso.label),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.tomate,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _avanzar(BuildContext context, OrderStatus paso) async {
    if (paso != OrderStatus.entregado) {
      pedidos.cambiarEstado(pedido, paso);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pedido #${pedido.id}: ${paso.label}')),
        );
      }
      return;
    }

    final codigo = await showDialog<String>(
      context: context,
      builder: (context) => const _PinEntregaDialog(),
    );
    if (!context.mounted || codigo == null) return;

    final confirmada = pedidos.confirmarEntrega(pedido, codigo);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(confirmada
            ? 'Pedido #${pedido.id} entregado.'
            : 'Código incorrecto. Verifica con el cliente.'),
      ),
    );
  }
}

class _PinEntregaDialog extends StatefulWidget {
  const _PinEntregaDialog();

  @override
  State<_PinEntregaDialog> createState() => _PinEntregaDialogState();
}

class _PinEntregaDialogState extends State<_PinEntregaDialog> {
  late final List<TextEditingController> _controllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];
  late final List<FocusNode> _focusNodes = [
    FocusNode(),
    FocusNode(),
    FocusNode(),
    FocusNode(),
  ];

  String get _codigo =>
      _controllers.map((controller) => controller.text).join();

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Confirmar entrega', style: AppTextStyles.heading(size: 15)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Pide al cliente el PIN de 4 dígitos.',
              style: AppTextStyles.body(size: 12)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, _casilla),
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar')),
        TextButton(
          onPressed: _codigo.length == 4
              ? () => Navigator.pop(context, _codigo)
              : null,
          child: const Text('Confirmar'),
        ),
      ],
    );
  }

  Widget _casilla(int index) {
    return Padding(
      padding: EdgeInsets.only(right: index == 3 ? 0 : 8),
      child: SizedBox(
        width: 48,
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          autofocus: index == 0,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          style: AppTextStyles.heading(size: 20, color: AppColors.tomate),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(counterText: ''),
          onChanged: (valor) {
            setState(() {});
            if (valor.isNotEmpty && index < 3) {
              _focusNodes[index + 1].requestFocus();
            }
          },
        ),
      ),
    );
  }
}

class _ClienteEntrega extends StatelessWidget {
  final Order pedido;
  const _ClienteEntrega({required this.pedido});

  @override
  Widget build(BuildContext context) {
    return DomiciliarioCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Cliente y dirección', style: AppTextStyles.heading(size: 13.5)),
          const SizedBox(height: 12),
          Text(pedido.cliente.isEmpty ? 'Cliente sin nombre' : pedido.cliente,
              style: AppTextStyles.body(size: 13, weight: FontWeight.w600)),
          if (pedido.telefonoCliente != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(pedido.telefonoCliente!,
                      style: AppTextStyles.body(
                          size: 11.5, color: AppColors.muted)),
                ),
                OutlinedButton.icon(
                  onPressed: () =>
                      Enlaces.llamarNumero(context, pedido.telefonoCliente!),
                  icon: const Icon(Icons.call_outlined, size: 16),
                  label: const Text('Llamar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.verde,
                    side: const BorderSide(color: AppColors.verde),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
          ],
          const Divider(height: 22, color: AppColors.borde),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.storefront_outlined, color: AppColors.mostaza),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                    'Recoger en ${BusinessInfo.nombreCorto}: ${BusinessInfo.direccion}',
                    style:
                        AppTextStyles.body(size: 11, color: AppColors.muted)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_outlined, color: AppColors.tomate),
              const SizedBox(width: 8),
              Expanded(
                child: Text(pedido.direccion ?? 'Sin dirección registrada',
                    style: AppTextStyles.body(size: 12)),
              ),
              if (pedido.direccion != null)
                IconButton(
                  tooltip: 'Abrir en Maps',
                  onPressed: () =>
                      Enlaces.abrirMaps(context, pedido.direccion!),
                  icon:
                      const Icon(Icons.map_outlined, color: AppColors.mostaza),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProductosPedido extends StatelessWidget {
  final Order pedido;
  const _ProductosPedido({required this.pedido});

  @override
  Widget build(BuildContext context) {
    return DomiciliarioCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Productos (${pedido.itemCount})',
              style: AppTextStyles.heading(size: 13.5)),
          const SizedBox(height: 10),
          ...pedido.lineas.map((linea) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text('${linea.cantidad} x ${linea.nombre}',
                              style: AppTextStyles.body(
                                  size: 12.5, weight: FontWeight.w600)),
                        ),
                        Text(formatoPesos(linea.total),
                            style: AppTextStyles.heading(
                                size: 11.5, color: AppColors.tomate)),
                      ],
                    ),
                    if (linea.opciones.isNotEmpty)
                      Text(
                          linea.opciones.entries
                              .map((e) => '${e.key}: ${e.value}')
                              .join(' | '),
                          style: AppTextStyles.body(
                              size: 10.5, color: AppColors.muted)),
                    if (linea.salsas.isNotEmpty)
                      Text(
                          'Salsas: ${linea.salsas.map((e) => e.nombre).join(', ')}',
                          style: AppTextStyles.body(
                              size: 10.5, color: AppColors.muted)),
                    if (linea.adiciones.isNotEmpty)
                      Text(
                          'Adiciones: ${linea.adiciones.map((e) => e.nombre).join(', ')}',
                          style: AppTextStyles.body(
                              size: 10.5, color: AppColors.muted)),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _PagoPedido extends StatelessWidget {
  final Order pedido;
  const _PagoPedido({required this.pedido});

  @override
  Widget build(BuildContext context) {
    final contraentrega = pedido.metodoPago.toLowerCase().contains('contra');
    return DomiciliarioCard(
      borde: contraentrega ? AppColors.tomate : null,
      child: Column(
        children: [
          Row(
            children: [
              Text('Total', style: AppTextStyles.heading(size: 14)),
              const Spacer(),
              Text(formatoPesos(pedido.total),
                  style:
                      AppTextStyles.heading(size: 17, color: AppColors.tomate)),
            ],
          ),
          const Divider(height: 20, color: AppColors.borde),
          Row(
            children: [
              Expanded(
                  child: Text('Método de pago',
                      style: AppTextStyles.body(
                          size: 12, color: AppColors.muted))),
              Text(pedido.metodoPago,
                  style: AppTextStyles.heading(
                      size: 12.5,
                      color:
                          contraentrega ? AppColors.tomate : AppColors.carbon)),
            ],
          ),
          if (contraentrega) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Cobrar al entregar',
                  style: AppTextStyles.heading(
                      size: 11.5, color: AppColors.tomate)),
            ),
          ],
        ],
      ),
    );
  }
}

class _Novedad extends StatelessWidget {
  final Order pedido;
  const _Novedad({required this.pedido});

  @override
  Widget build(BuildContext context) {
    return DomiciliarioCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Novedad', style: AppTextStyles.heading(size: 13.5)),
          if (pedido.novedad != null) ...[
            const SizedBox(height: 8),
            Text(pedido.novedad!,
                style: AppTextStyles.body(size: 12, color: AppColors.tomate)),
          ],
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => _reportar(context),
            icon: const Icon(Icons.report_problem_outlined, size: 18),
            label: const Text('Reportar novedad'),
            style: TextButton.styleFrom(foregroundColor: AppColors.tomate),
          ),
        ],
      ),
    );
  }

  Future<void> _reportar(BuildContext context) async {
    final novedad = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reportar novedad', style: AppTextStyles.heading(size: 15)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final opcion in const [
              'Cliente no contesta',
              'Dirección incorrecta',
              'Pedido no recibido',
              'Otra novedad',
            ])
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(opcion, style: AppTextStyles.body(size: 12)),
                onTap: () => Navigator.pop(context, opcion),
              ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
        ],
      ),
    );
    if (!context.mounted || novedad == null) return;
    AppScope.pedidosSinEscuchar(context).reportarNovedad(pedido, novedad);
    await Enlaces.llamar(context);
  }
}
