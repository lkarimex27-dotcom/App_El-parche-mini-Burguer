import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/order.dart';
import '../models/extras.dart';
import 'cart_model.dart';

/// Los pedidos del cliente. Se crean a partir del carrito cuando se
/// confirma el pago, copiando todo lo que eligió: producto, salsas,
/// adiciones, gaseosa (sabor y tamaño), cantidades y precios.
class OrdersModel extends ChangeNotifier {
  static const _clavePedidos = 'pedidos_guardados';
  final List<Order> _pedidos = [];
  final bool _persistir;
  int _consecutivo = 1000;

  /// [iniciales] solo se usa para sembrar pedidos de ejemplo mientras no
  /// hay backend (ver lib/admin/data/admin_mock.dart). En producción se
  /// construye vacío y se llena con [crearDesdeCarrito].
  OrdersModel({List<Order>? iniciales, bool persistir = false})
      : _persistir = persistir {
    if (iniciales == null) return;
    _pedidos.addAll(iniciales);
    for (final p in iniciales) {
      final n = int.tryParse(p.id);
      if (n != null && n > _consecutivo) _consecutivo = n;
    }
  }

  /// Carga los pedidos reales guardados en este dispositivo al arrancar.
  /// Las pruebas y las siembras demo no activan persistencia.
  Future<void> cargarGuardados() async {
    if (!_persistir) return;
    final preferencias = await SharedPreferences.getInstance();
    final texto = preferencias.getString(_clavePedidos);
    if (texto == null || texto.isEmpty) return;

    try {
      final datos = jsonDecode(texto) as List<dynamic>;
      _pedidos
        ..clear()
        ..addAll(datos.map((dato) =>
            _pedidoDesdeJson(Map<String, dynamic>.from(dato as Map))));
      _actualizarConsecutivo();
      notifyListeners();
    } on FormatException {
      // Un valor incompleto no debe impedir que la app arranque.
    } on TypeError {
      // Ignora datos antiguos o corruptos y conserva la lista vacía.
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
    unawaited(_guardar());
  }

  /// Pasa el carrito a pedido. Devuelve el pedido creado.
  Order crearDesdeCarrito({
    required CartModel carrito,
    required String metodoPago,
    String cliente = '',
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
    );

    _pedidos.insert(0, pedido);
    notifyListeners();
    unawaited(_guardar());
    return pedido;
  }

  void _actualizarConsecutivo() {
    for (final pedido in _pedidos) {
      final numero = int.tryParse(pedido.id);
      if (numero != null && numero > _consecutivo) _consecutivo = numero;
    }
  }

  Future<void> _guardar() async {
    if (!_persistir) return;
    final preferencias = await SharedPreferences.getInstance();
    await preferencias.setString(
      _clavePedidos,
      jsonEncode(_pedidos.map(_pedidoAJson).toList()),
    );
  }

  Map<String, dynamic> _pedidoAJson(Order pedido) => {
        'id': pedido.id,
        'fecha': pedido.fecha.toIso8601String(),
        'status': pedido.status.name,
        'lineas': pedido.lineas
            .map((linea) => {
                  'productId': linea.productId,
                  'nombre': linea.nombre,
                  'categoria': linea.categoria,
                  'imageAsset': linea.imageAsset,
                  'imageUrl': linea.imageUrl,
                  'cantidad': linea.cantidad,
                  'precioBase': linea.precioBase,
                  'salsas': linea.salsas.map(_extraAJson).toList(),
                  'adiciones': linea.adiciones.map(_extraAJson).toList(),
                  'opciones': linea.opciones,
                })
            .toList(),
        'subtotal': pedido.subtotal,
        'domicilio': pedido.domicilio,
        'metodoPago': pedido.metodoPago,
        'cliente': pedido.cliente,
        'direccion': pedido.direccion,
        'comprobante': pedido.comprobante,
        'note': pedido.note,
        'historial': pedido.historial
            .map((evento) => {
                  'fecha': evento.fecha.toIso8601String(),
                  'texto': evento.texto,
                  'estado': evento.estado?.name,
                })
            .toList(),
      };

  Order _pedidoDesdeJson(Map<String, dynamic> dato) {
    final lineas = (dato['lineas'] as List<dynamic>).map((valor) {
      final linea = Map<String, dynamic>.from(valor as Map);
      return OrderLine(
        productId: linea['productId'] as String,
        nombre: linea['nombre'] as String,
        categoria: linea['categoria'] as String,
        imageAsset: linea['imageAsset'] as String,
        imageUrl: linea['imageUrl'] as String,
        cantidad: linea['cantidad'] as int,
        precioBase: linea['precioBase'] as int,
        salsas: _extrasDesdeJson(linea['salsas']),
        adiciones: _extrasDesdeJson(linea['adiciones']),
        opciones: Map<String, String>.from(linea['opciones'] as Map),
      );
    }).toList();
    final historial = (dato['historial'] as List<dynamic>).map((valor) {
      final evento = Map<String, dynamic>.from(valor as Map);
      return OrderEvento(
        fecha: DateTime.parse(evento['fecha'] as String),
        texto: evento['texto'] as String,
        estado: _estadoDesdeJson(evento['estado']),
      );
    }).toList();

    return Order(
      id: dato['id'] as String,
      fecha: DateTime.parse(dato['fecha'] as String),
      status: _estadoDesdeJson(dato['status'])!,
      lineas: List.unmodifiable(lineas),
      subtotal: dato['subtotal'] as int,
      domicilio: dato['domicilio'] as int,
      metodoPago: dato['metodoPago'] as String,
      cliente: dato['cliente'] as String? ?? '',
      direccion: dato['direccion'] as String?,
      comprobante: dato['comprobante'] as String?,
      note: dato['note'] as String?,
      historial: List.unmodifiable(historial),
    );
  }

  static Map<String, dynamic> _extraAJson(Extra extra) => {
        'id': extra.id,
        'nombre': extra.nombre,
        'precio': extra.precio,
      };

  static List<Extra> _extrasDesdeJson(dynamic dato) =>
      (dato as List<dynamic>).map((valor) {
        final extra = Map<String, dynamic>.from(valor as Map);
        return Extra(extra['id'] as String, extra['nombre'] as String,
            precio: extra['precio'] as int);
      }).toList();

  static OrderStatus? _estadoDesdeJson(dynamic valor) => valor == null
      ? null
      : OrderStatus.values.firstWhere((estado) => estado.name == valor);
}
