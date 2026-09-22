import 'package:flutter/foundation.dart';
import '../models/business_info.dart';
import '../models/extras.dart';
import '../models/product.dart';

/// Un producto tal como quedó en el carrito: con sus opciones elegidas,
/// sus salsas, sus adiciones y su cantidad. El precio se calcula siempre a partir
/// de esto, nunca se guarda "cocinado".
class CartLine {
  final String id;
  final Product product;
  final Set<Extra> salsas;
  final Set<Extra> adiciones;

  /// Opciones elegidas: título de la variante → opción (queso/tocineta,
  /// pollo/cerdo, sabor de la bebida…).
  final Map<String, String> opciones;

  int cantidad;

  CartLine({
    required this.id,
    required this.product,
    Set<Extra>? salsas,
    Set<Extra>? adiciones,
    Map<String, String>? opciones,
    this.cantidad = 1,
  })  : salsas = salsas ?? <Extra>{},
        adiciones = adiciones ?? <Extra>{},
        opciones = opciones ?? <String, String>{};

  int get precioBase => product.precioCon(opciones);
  int get precioSalsas => sumaExtras(salsas);
  int get precioAdiciones => sumaExtras(adiciones);

  /// Lo que vale una unidad con todo lo que le pusieron.
  int get precioUnitario => precioBase + precioSalsas + precioAdiciones;

  int get total => precioUnitario * cantidad;

  /// Texto corto para mostrar debajo del nombre en el carrito: lo que
  /// eligió, o la categoría si el producto no tiene opciones.
  String get resumen =>
      opciones.isEmpty ? product.category : opciones.values.join(' · ');

  /// Dos líneas con la misma configuración se juntan en una sola.
  bool mismaConfiguracion(CartLine otra) =>
      product.id == otra.product.id &&
      mapEquals(opciones, otra.opciones) &&
      setEquals(salsas, otra.salsas) &&
      setEquals(adiciones, otra.adiciones);
}

/// El carrito de la app. Avisa a quien lo escuche cada vez que cambia,
/// para que el badge del bottom nav y el total se actualicen solos.
class CartModel extends ChangeNotifier {
  final List<CartLine> _lineas = [];
  int _contadorId = 0;

  List<CartLine> get lineas => List.unmodifiable(_lineas);

  bool get estaVacio => _lineas.isEmpty;

  /// Lo que muestra el globito sobre el ícono del carrito.
  int get cantidadTotal =>
      _lineas.fold(0, (total, linea) => total + linea.cantidad);

  int get subtotal => _lineas.fold(0, (total, linea) => total + linea.total);

  int get domicilio => _lineas.isEmpty ? 0 : BusinessInfo.precioDomicilio;

  int get total => subtotal + domicilio;

  void agregar({
    required Product product,
    Set<Extra>? salsas,
    Set<Extra>? adiciones,
    Map<String, String>? opciones,
    int cantidad = 1,
  }) {
    final nueva = CartLine(
      id: 'l${_contadorId++}',
      product: product,
      salsas: {...?salsas},
      adiciones: {...?adiciones},
      opciones: {...?opciones},
      cantidad: cantidad,
    );

    for (final linea in _lineas) {
      if (linea.mismaConfiguracion(nueva)) {
        linea.cantidad += cantidad;
        notifyListeners();
        return;
      }
    }

    _lineas.add(nueva);
    notifyListeners();
  }

  /// Suma o resta unidades. Si baja de 1, la línea se elimina.
  void cambiarCantidad(CartLine linea, int delta) {
    final nueva = linea.cantidad + delta;
    if (nueva < 1) {
      eliminar(linea);
      return;
    }
    linea.cantidad = nueva;
    notifyListeners();
  }

  void eliminar(CartLine linea) {
    _lineas.removeWhere((l) => l.id == linea.id);
    notifyListeners();
  }

  void actualizarSalsas(CartLine linea, Set<Extra> salsas) {
    linea.salsas
      ..clear()
      ..addAll(salsas);
    notifyListeners();
  }

  /// Cambia una opción de la línea (queso/tocineta, sabor…).
  void actualizarOpcion(CartLine linea, String variante, String opcion) {
    linea.opciones[variante] = opcion;
    notifyListeners();
  }

  void actualizarAdiciones(CartLine linea, Set<Extra> adiciones) {
    linea.adiciones
      ..clear()
      ..addAll(adiciones);
    notifyListeners();
  }

  void vaciar() {
    _lineas.clear();
    notifyListeners();
  }
}
