import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'extras.dart';

enum OrderStatus { rechazado, aprobado, preparacion, listo, cancelado }

extension OrderStatusUi on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.rechazado:
        return 'Rechazado';
      case OrderStatus.aprobado:
        return 'Aprobado';
      case OrderStatus.preparacion:
        return 'En preparación';
      case OrderStatus.listo:
        return 'Listo para recoger';
      case OrderStatus.cancelado:
        return 'Cancelado';
    }
  }

  IconData get icon {
    switch (this) {
      case OrderStatus.rechazado:
        return Icons.close_rounded;
      case OrderStatus.aprobado:
        return Icons.check_rounded;
      case OrderStatus.preparacion:
        return Icons.access_time_rounded;
      case OrderStatus.listo:
        return Icons.shopping_bag_rounded;
      case OrderStatus.cancelado:
        return Icons.block_rounded;
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.rechazado:
      case OrderStatus.cancelado:
        return AppColors.tomate;
      case OrderStatus.aprobado:
      case OrderStatus.listo:
        return AppColors.verde;
      case OrderStatus.preparacion:
        return const Color(0xFFB96A1E);
    }
  }

  Color get background {
    switch (this) {
      case OrderStatus.rechazado:
      case OrderStatus.cancelado:
        return const Color(0xFFF7E2DE);
      case OrderStatus.aprobado:
      case OrderStatus.listo:
        return const Color(0xFFE1EEE9);
      case OrderStatus.preparacion:
        return const Color(0xFFFBEBD8);
    }
  }
}

/// Un producto dentro de un pedido, con todo lo que el cliente eligió.
/// Se copia del carrito al confirmar, para que el pedido no cambie
/// aunque después se modifique el catálogo o el carrito.
class OrderLine {
  final String productId;
  final String nombre;
  final String categoria;
  final String imageAsset;
  final String imageUrl;
  final int cantidad;

  /// Precio del producto solo, sin extras.
  final int precioBase;

  final List<Extra> salsas;
  final List<Extra> adiciones;

  /// Opciones elegidas (queso/tocineta, pollo/cerdo, sabor…).
  final Map<String, String> opciones;

  const OrderLine({
    required this.productId,
    required this.nombre,
    required this.categoria,
    required this.imageAsset,
    required this.imageUrl,
    required this.cantidad,
    required this.precioBase,
    this.salsas = const [],
    this.adiciones = const [],
    this.opciones = const {},
  });

  int get precioExtras => sumaExtras(salsas) + sumaExtras(adiciones);

  int get precioUnitario => precioBase + precioExtras;

  int get total => precioUnitario * cantidad;
}

class Order {
  final String id;
  final DateTime fecha;
  final OrderStatus status;
  final List<OrderLine> lineas;
  final int subtotal;
  final int domicilio;

  /// 'Nequi' o 'Bancolombia'.
  final String metodoPago;

  /// A dónde va el domicilio (o null si es para recoger).
  final String? direccion;

  /// Nombre del archivo del comprobante que subió el cliente.
  final String? comprobante;

  /// Motivo cuando el pedido fue rechazado o cancelado.
  final String? note;

  const Order({
    required this.id,
    required this.fecha,
    required this.status,
    required this.lineas,
    required this.subtotal,
    required this.domicilio,
    required this.metodoPago,
    this.direccion,
    this.comprobante,
    this.note,
  });

  int get total => subtotal + domicilio;

  /// Cuántos productos lleva el pedido en total.
  int get itemCount => lineas.fold(0, (suma, l) => suma + l.cantidad);

  /// El producto que representa al pedido en la lista "Mis pedidos":
  /// el de mayor cantidad y, si empatan, el más caro.
  OrderLine? get lineaPrincipal {
    if (lineas.isEmpty) return null;
    return lineas.reduce((a, b) {
      if (b.cantidad != a.cantidad) return b.cantidad > a.cantidad ? b : a;
      return b.total > a.total ? b : a;
    });
  }

  /// Fecha en palabras: "Hoy, 7:40 p.m." / "Ayer, 8:12 p.m." / "12/09, 6:30 p.m.".
  String get fechaTexto {
    final ahora = DateTime.now();
    final hoy = DateTime(ahora.year, ahora.month, ahora.day);
    final dia = DateTime(fecha.year, fecha.month, fecha.day);
    final diferencia = hoy.difference(dia).inDays;

    final String cuando;
    if (diferencia == 0) {
      cuando = 'Hoy';
    } else if (diferencia == 1) {
      cuando = 'Ayer';
    } else {
      cuando = '${fecha.day.toString().padLeft(2, '0')}/'
          '${fecha.month.toString().padLeft(2, '0')}';
    }

    final h24 = fecha.hour;
    final h12 = h24 % 12 == 0 ? 12 : h24 % 12;
    final minutos = fecha.minute.toString().padLeft(2, '0');
    final franja = h24 < 12 ? 'a.m.' : 'p.m.';

    return '$cuando, $h12:$minutos $franja';
  }
}
