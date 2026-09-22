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

  /// Pasa el carrito a pedido. Devuelve el pedido creado.
  Order crearDesdeCarrito({
    required CartModel carrito,
    required String metodoPago,
    String? direccion,
    String? comprobante,
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
      // Entra en revisión: el negocio confirma el comprobante.
      status: OrderStatus.preparacion,
      lineas: List.unmodifiable(lineas),
      subtotal: carrito.subtotal,
      domicilio: carrito.domicilio,
      metodoPago: metodoPago,
      direccion: direccion,
      comprobante: comprobante,
    );

    _pedidos.insert(0, pedido);
    notifyListeners();
    return pedido;
  }
}
