import 'package:flutter/foundation.dart';
import '../models/order.dart';
import 'cart_model.dart';

/// Los pedidos del cliente. Se crean a partir del carrito cuando se
/// confirma el pago, copiando todo lo que eligió: producto, salsas,
/// adiciones, gaseosa (sabor y tamaño), cantidades y precios.
class OrdersModel extends ChangeNotifier {
  final List<Order> _pedidos = [];
  int _consecutivo = 1000;

  /// [iniciales] solo se usa para sembrar pedidos de ejemplo mientras no
  /// hay backend (ver lib/admin/data/admin_mock.dart). En producción se
  /// construye vacío y se llena con [crearDesdeCarrito].
  OrdersModel({List<Order>? iniciales}) {
    if (iniciales == null) return;
    _pedidos.addAll(iniciales);
    for (final p in iniciales) {
      final n = int.tryParse(p.id);
      if (n != null && n > _consecutivo) _consecutivo = n;
    }
  }

  /// Del más nuevo al más viejo.
  List<Order> get pedidos => List.unmodifiable(_pedidos);

  bool get estaVacio => _pedidos.isEmpty;

  Order? porId(String id) {
    for (final p in _pedidos) {
      if (p.id == id) return p;
    }
    return null;
  }

  List<Order> pedidosAsignados(String domiciliarioId) => _pedidos
      .where((pedido) => pedido.domiciliarioId == domiciliarioId)
      .toList(growable: false);

  List<Order> historialDe(String domiciliarioId) => pedidosAsignados(
        domiciliarioId,
      ).where((pedido) => pedido.status == OrderStatus.entregado).toList();

  /// Mueve el pedido a otro estado y lo anota en su historial.
  /// [nota] guarda el motivo cuando se rechaza o se cancela.
  void cambiarEstado(Order pedido, OrderStatus nuevo, {String? nota}) {
    if (pedido.status == nuevo) return;

    final motivo = nota?.trim() ?? '';
    pedido.status = nuevo;
    if (motivo.isNotEmpty) pedido.note = motivo;
    pedido.historial.add(
      OrderEvento(
        fecha: DateTime.now(),
        texto: motivo.isEmpty ? nuevo.label : '${nuevo.label} · $motivo',
        estado: nuevo,
      ),
    );
    notifyListeners();
  }

  bool confirmarEntrega(Order pedido, String codigo) {
    if (pedido.status != OrderStatus.enCamino ||
        codigo.trim() != pedido.codigoEntrega) {
      return false;
    }
    cambiarEstado(pedido, OrderStatus.entregado);
    return true;
  }

  void reportarNovedad(Order pedido, String novedad) {
    final texto = novedad.trim();
    if (texto.isEmpty) return;
    pedido.novedad = texto;
    pedido.historial.add(
      OrderEvento(fecha: DateTime.now(), texto: 'Novedad · $texto'),
    );
    notifyListeners();
  }

  /// Pasa el carrito a pedido. Devuelve el pedido creado.
  Order crearDesdeCarrito({
    required CartModel carrito,
    required String metodoPago,
    String cliente = '',
    String? direccion,
    String? comprobante,
    String? codigoEntrega,
  }) {
    final lineas = carrito.lineas
        .map(
          (l) => OrderLine(
            productId: l.product.id,
            nombre: l.product.name,
            categoria: l.product.category,
            imageAsset: l.product.imageAsset,
            imageUrl: l.product.imageUrl,
            cantidad: l.cantidad,
            precioBase: l.precioBase,
            salsas: List.unmodifiable(l.salsas.toList()),
            adiciones: List.unmodifiable(l.adiciones.toList()),
            opciones: Map.unmodifiable(l.opciones),
          ),
        )
        .toList();

    final pedido = Order(
      id: '${++_consecutivo}',
      fecha: DateTime.now(),
      // Los pedidos grandes esperan aprobación; el resto entra derecho
      // a preparación.
      status: carrito.total > kMontoAprobacion
          ? OrderStatus.pendiente
          : OrderStatus.preparacion,
      lineas: List.unmodifiable(lineas),
      subtotal: carrito.subtotal,
      domicilio: carrito.domicilio,
      metodoPago: metodoPago,
      cliente: cliente,
      direccion: direccion,
      comprobante: comprobante,
      codigoEntrega: codigoEntrega ?? _codigoTemporal(),
    );

    _pedidos.insert(0, pedido);
    notifyListeners();
    return pedido;
  }

  String _codigoTemporal() => (_consecutivo % 10000).toString().padLeft(4, '0');
}
