import 'package:flutter/material.dart';
import '../models/business_info.dart';
import '../models/order.dart';
import '../models/product.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_image.dart';
import '../widgets/order_progress.dart';
import '../widgets/order_status_badge.dart';
import '../models/precio.dart';

/// Detalle completo del pedido: cada producto con sus salsas, adiciones y
/// gaseosa (sabor y tamaño), más los totales, el pago y la entrega. Es la
/// información que quedó guardada al confirmar, no se recalcula.
class OrderDetailScreen extends StatelessWidget {
  final Order order;
  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.crema,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.carbon),
        title:
            Text('Pedido #${order.id}', style: AppTextStyles.heading(size: 15)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
        children: [
          Row(
            children: [
              Flexible(child: OrderStatusBadge(status: order.status)),
              const SizedBox(width: 10),
              // La hora cambia de ancho según el día ("9:05 a.m." vs
              // "12:05 p.m."), así que se deja encoger en vez de desbordar.
              Flexible(
                child: Text(
                  order.fechaTexto,
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body(size: 11.5, color: AppColors.muted),
                ),
              ),
            ],
          ),
          if (order.note != null) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: order.status.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(order.note!,
                  style: AppTextStyles.body(
                      size: 11.5, color: order.status.color)),
            ),
          ],
          const SizedBox(height: 14),
          OrderProgress(order: order),
          const SizedBox(height: 16),
          Text('Lo que pediste', style: AppTextStyles.heading(size: 13)),
          const SizedBox(height: 10),
          ...order.lineas.map((linea) => _LineaPedido(linea: linea)),
          const SizedBox(height: 6),
          _Tarjeta(
            titulo: 'Resumen de pago',
            hijos: [
              // La cuenta completa, renglón por renglón: el producto, cada
              // adición y cada salsa que cobra. Así el cliente puede
              // comprobar de dónde sale el total sin devolverse a mirar.
              for (final linea in order.lineas) ...[
                _Renglon(
                  texto: '${linea.cantidad} × ${linea.nombre}',
                  valor: formatoPesos(linea.precioBase * linea.cantidad),
                  destacado: true,
                ),
                for (final extra in [...linea.salsas, ...linea.adiciones])
                  if (!extra.esGratis)
                    _Renglon(
                      texto: '   ${linea.cantidad} × ${extra.nombre}',
                      valor: formatoPesos(extra.precio * linea.cantidad),
                    )
                  else
                    _Renglon(texto: '   ${extra.nombre}', valor: 'Sin costo'),
                for (final opcion in linea.opciones.entries)
                  _Renglon(
                      texto: '   ${opcion.key}: ${opcion.value}', valor: ''),
                const SizedBox(height: 4),
              ],
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Divider(height: 1, color: AppColors.borde),
              ),
              _Fila(
                  label: '${order.itemCount} productos',
                  value: formatoPesos(order.subtotal)),
              const SizedBox(height: 6),
              _Fila(label: 'Domicilio', value: formatoPesos(order.domicilio)),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Divider(height: 1, color: AppColors.borde),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total', style: AppTextStyles.heading(size: 13.5)),
                  Text(formatoPesos(order.total),
                      style: AppTextStyles.heading(
                          size: 15, color: AppColors.verde)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          _Tarjeta(
            titulo: 'Pago y entrega',
            hijos: [
              _Fila(label: 'N° de pedido', value: '#${order.id}'),
              const SizedBox(height: 6),
              _Fila(label: 'Estado', value: order.status.label),
              const SizedBox(height: 6),
              _Fila(label: 'Fecha y hora', value: order.fechaTexto),
              const SizedBox(height: 6),
              _Fila(label: 'Método de pago', value: order.metodoPago),
              const SizedBox(height: 6),
              _Fila(
                label: 'Entrega',
                value:
                    order.direccion ?? 'Recoger en ${BusinessInfo.nombreCorto}',
              ),
              const SizedBox(height: 6),
              const _Fila(label: 'Contacto', value: BusinessInfo.telefono),
              if (order.comprobante != null) ...[
                const SizedBox(height: 6),
                _Fila(label: 'Comprobante', value: order.comprobante!),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _LineaPedido extends StatelessWidget {
  final OrderLine linea;
  const _LineaPedido({required this.linea});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
              AppImage(
                linea.imageAsset,
                fallbackUrl: linea.imageUrl,
                placeholderIcon: iconoDeCategoria(linea.categoria),
                width: 54,
                height: 54,
                borderRadius: BorderRadius.circular(12),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${linea.cantidad} × ${linea.nombre}',
                        style: AppTextStyles.heading(size: 12.5)),
                    const SizedBox(height: 2),
                    Text(linea.categoria,
                        style: AppTextStyles.body(
                            size: 10.5, color: AppColors.muted)),
                  ],
                ),
              ),
              Text(formatoPesos(linea.total),
                  style:
                      AppTextStyles.heading(size: 13, color: AppColors.carbon)),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: AppColors.borde),
          ),

          // Desglose de lo que se cobró en esta línea.
          _Desglose(label: 'Producto', valor: formatoPesos(linea.precioBase)),
          if (linea.salsas.isNotEmpty)
            _Detalle(
              icono: Icons.water_drop_outlined,
              etiqueta: 'Salsas',
              texto: linea.salsas
                  .map((e) => e.esGratis
                      ? e.nombre
                      : '${e.nombre} +${formatoPesos(e.precio)}')
                  .join(', '),
            ),
          if (linea.adiciones.isNotEmpty)
            _Detalle(
              icono: Icons.add_circle_outline,
              etiqueta: 'Adiciones',
              texto: linea.adiciones
                  .map((e) => '${e.nombre} +${formatoPesos(e.precio)}')
                  .join(', '),
            ),
          for (final o in linea.opciones.entries)
            _Detalle(
              icono: Icons.tune_rounded,
              etiqueta: o.key,
              texto: o.value,
            ),
          if (linea.precioExtras > 0)
            _Desglose(label: 'Extras', valor: formatoPesos(linea.precioExtras)),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                'Subtotal · ${linea.cantidad} × ${formatoPesos(linea.precioUnitario)}',
                style: AppTextStyles.body(size: 11, color: AppColors.muted),
              ),
              const Spacer(),
              Text(formatoPesos(linea.total),
                  style: AppTextStyles.heading(size: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

/// Fila "etiqueta … valor" del desglose de una línea.
/// Un renglón de la cuenta: qué es a la izquierda, cuánto a la derecha.
/// El del producto va más marcado y lo suyo (adiciones, opciones) va
/// indentado debajo, como en una factura.
class _Renglon extends StatelessWidget {
  final String texto;
  final String valor;
  final bool destacado;

  const _Renglon({
    required this.texto,
    required this.valor,
    this.destacado = false,
  });

  @override
  Widget build(BuildContext context) {
    final estilo = destacado
        ? AppTextStyles.heading(size: 11.5)
        : AppTextStyles.body(size: 11, color: AppColors.muted);

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(texto,
                style: estilo, maxLines: 2, overflow: TextOverflow.ellipsis),
          ),
          if (valor.isNotEmpty) ...[
            const SizedBox(width: 10),
            Text(valor, style: estilo),
          ],
        ],
      ),
    );
  }
}

class _Desglose extends StatelessWidget {
  final String label;
  final String valor;
  const _Desglose({required this.label, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(label,
              style: AppTextStyles.body(size: 11, color: AppColors.muted)),
          const Spacer(),
          Text(valor, style: AppTextStyles.body(size: 11)),
        ],
      ),
    );
  }
}

class _Detalle extends StatelessWidget {
  final IconData icono;
  final String etiqueta;
  final String texto;

  const _Detalle({
    required this.icono,
    required this.etiqueta,
    required this.texto,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, size: 13, color: AppColors.mostaza),
          const SizedBox(width: 6),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: AppTextStyles.body(size: 11, color: AppColors.muted),
                children: [
                  TextSpan(
                    text: '$etiqueta: ',
                    style: AppTextStyles.heading(
                        size: 10.5, color: AppColors.carbon),
                  ),
                  TextSpan(text: texto),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tarjeta extends StatelessWidget {
  final String titulo;
  final List<Widget> hijos;

  const _Tarjeta({required this.titulo, required this.hijos});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: AppTextStyles.heading(size: 12.5)),
          const SizedBox(height: 10),
          ...hijos,
        ],
      ),
    );
  }
}

class _Fila extends StatelessWidget {
  final String label;
  final String value;
  const _Fila({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTextStyles.body(size: 12, color: AppColors.muted)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(value,
              textAlign: TextAlign.right, style: AppTextStyles.body(size: 12)),
        ),
      ],
    );
  }
}
