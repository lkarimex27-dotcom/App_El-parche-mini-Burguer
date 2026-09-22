import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'extras.dart';

enum OrderStatus { pendiente, rechazado, aprobado, preparacion, listo, entregado, cancelado }

extension OrderStatusUi on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.pendiente:
        return 'Pendiente';
      case OrderStatus.rechazado:
        return 'Rechazado';
      case OrderStatus.aprobado:
        return 'Aprobado';
      case OrderStatus.preparacion:
        return 'En preparación';
      case OrderStatus.listo:
        return 'Listo para recoger';
      case OrderStatus.entregado:
        return 'Entregado';
      case OrderStatus.cancelado:
        return 'Cancelado';
    }
  }

  IconData get icon {
    switch (this) {
      case OrderStatus.pendiente:
        return Icons.pending_actions_rounded;
      case OrderStatus.rechazado:
        return Icons.close_rounded;
      case OrderStatus.aprobado:
        return Icons.check_rounded;
      case OrderStatus.preparacion:
        return Icons.access_time_rounded;
      case OrderStatus.listo:
        return Icons.shopping_bag_rounded;
      case OrderStatus.entregado:
        return Icons.done_all_rounded;
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
      case OrderStatus.entregado:
        return AppColors.verde;
      case OrderStatus.pendiente:
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
      case OrderStatus.entregado:
        return const Color(0xFFE1EEE9);
      case OrderStatus.pendiente:
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

/// Un paso en la vida del pedido: quedó pendiente, lo aprobaron, salió…
/// Sirve para mostrar el historial en el panel administrativo.
class OrderEvento {
  final DateTime fecha;
  final String texto;
  final OrderStatus? estado;

  const OrderEvento({required this.fecha, required this.texto, this.estado});
}

/// Monto desde el cual un pedido necesita que el administrador lo apruebe
/// antes de pasar a producción.
const int kMontoAprobacion = 150000;

class Order {
  final String id;
  final DateTime fecha;

  /// Cambia cuando el negocio avanza el pedido (por eso no es final).
  OrderStatus status;

  final List<OrderLine> lineas;
  final int subtotal;
  final int domicilio;

  /// Nombre de quien hizo el pedido.
  final String cliente;

  /// 'Nequi' o 'Bancolombia'.
  final String metodoPago;

  /// A dónde va el domicilio (o null si es para recoger).
  final String? direccion;

  /// Nombre del archivo del comprobante que subió el cliente.
  final String? comprobante;

  /// Motivo cuando el pedido fue rechazado o cancelado.
  String? note;

  /// Lo que le ha pasado al pedido, del más viejo al más nuevo.
  final List<OrderEvento> historial;

  Order({
    required this.id,
    required this.fecha,
    required this.status,
    required this.lineas,
    required this.subtotal,
    required this.domicilio,
    required this.metodoPago,
    this.cliente = '',
    this.direccion,
    this.comprobante,
    this.note,
    List<OrderEvento>? historial,
  }) : historial = historial ??
            [
              OrderEvento(
                fecha: fecha,
                texto: 'Pedido recibido',
                estado: status,
              ),
            ];

  int get total => subtotal + domicilio;

  /// Los pedidos grandes esperan el visto bueno del administrador antes
  /// de generar la orden de producción.
  bool get requiereAprobacion =>
      status == OrderStatus.pendiente && total > kMontoAprobacion;

  /// Un pedido que ya se cerró (bien o mal) no admite más cambios.
  bool get estaCerrado =>
      status == OrderStatus.entregado ||
      status == OrderStatus.rechazado ||
      status == OrderStatus.cancelado;

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
