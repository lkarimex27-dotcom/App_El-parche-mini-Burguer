import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parche_mini_burger/models/extras.dart';
import 'package:parche_mini_burger/models/product.dart';
import 'package:parche_mini_burger/screens/cart_screen.dart';
import 'package:parche_mini_burger/screens/order_detail_screen.dart';
import 'package:parche_mini_burger/screens/orders_screen.dart';
import 'package:parche_mini_burger/screens/product_detail_screen.dart';
import 'package:parche_mini_burger/state/app_scope.dart';
import 'package:parche_mini_burger/state/cart_model.dart';
import 'package:parche_mini_burger/state/orders_model.dart';
import 'package:parche_mini_burger/state/user_model.dart';
import 'package:parche_mini_burger/models/precio.dart';

Product get _clasica => demoProducts.firstWhere((p) => p.id == 'hamburguesa_doble');
Extra get _tocineta => kAdiciones.firstWhere((e) => e.id == 'ad_tocineta');
Extra get _bbq => kSalsas.firstWhere((e) => e.id == 'bbq');
Product get _bebida =>
    demoProducts.firstWhere((p) => p.id == 'gaseosa_flexi_400');
Product get _chuzo => demoProducts.firstWhere((p) => p.id == 'chuzo_pollo_cerdo');

void main() {
  setUp(() {
    final view = TestWidgetsFlutterBinding.ensureInitialized()
        .platformDispatcher
        .views
        .first;
    view.physicalSize = const Size(420, 2400);
    view.devicePixelRatio = 1.0;
  });

  tearDown(() {
    final view = TestWidgetsFlutterBinding.ensureInitialized()
        .platformDispatcher
        .views
        .first;
    view.resetPhysicalSize();
    view.resetDevicePixelRatio();
  });

  test('el pedido guarda producto, salsas, adiciones y opciones', () {
    final carrito = CartModel()
      ..agregar(
        product: _clasica,
        salsas: {_bbq},
        adiciones: {_tocineta},
        opciones: const {'Elige tu opción': 'Cerdo'},
        cantidad: 2,
      );

    final pedidos = OrdersModel();
    final pedido = pedidos.crearDesdeCarrito(
      carrito: carrito,
      metodoPago: 'Nequi',
      direccion: 'Cra 45 #12-30',
      comprobante: 'comprobante.jpg',
    );

    final linea = pedido.lineas.single;
    expect(linea.nombre, _clasica.name);
    expect(linea.cantidad, 2);
    expect(linea.salsas.single, _bbq);
    expect(linea.adiciones.single, _tocineta);
    expect(linea.opciones['Elige tu opción'], 'Cerdo');

    final unitario = _clasica.price + _tocineta.precio;
    expect(linea.precioUnitario, unitario);
    expect(pedido.subtotal, unitario * 2);
    expect(pedido.total, pedido.subtotal + pedido.domicilio);
    expect(pedido.metodoPago, 'Nequi');
    expect(pedido.direccion, 'Cra 45 #12-30');
    expect(pedido.comprobante, 'comprobante.jpg');
  });

  test('el pedido no cambia aunque después se modifique el carrito', () {
    final carrito = CartModel()..agregar(product: _clasica, cantidad: 1);
    final pedidos = OrdersModel();
    final pedido =
        pedidos.crearDesdeCarrito(carrito: carrito, metodoPago: 'Nequi');

    carrito.cambiarCantidad(carrito.lineas.first, 4);
    carrito.actualizarAdiciones(carrito.lineas.first, {_tocineta});

    expect(pedido.lineas.single.cantidad, 1);
    expect(pedido.lineas.single.adiciones, isEmpty);
  });

  testWidgets('el detalle del pedido muestra todo lo que se eligió',
      (tester) async {
    final carrito = CartModel()
      ..agregar(
        product: _clasica,
        salsas: {_bbq},
        adiciones: {_tocineta},
        opciones: const {'Elige tu opción': 'Cerdo'},
        cantidad: 2,
      );
    final pedidos = OrdersModel();
    final pedido = pedidos.crearDesdeCarrito(
      carrito: carrito,
      metodoPago: 'Bancolombia',
      direccion: 'Cra 45 #12-30',
    );

    await tester.pumpWidget(AppScope(
      pedidosInicial: pedidos,
      child: MaterialApp(home: OrderDetailScreen(order: pedido)),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Pedido #${pedido.id}'), findsOneWidget);
    // Sale dos veces: en la lista de productos y en el desglose de la cuenta.
    expect(find.text('2 × ${_clasica.name}'), findsNWidgets(2));
    expect(find.textContaining(_bbq.nombre, findRichText: true), findsNWidgets(2));
    expect(find.textContaining(_tocineta.nombre, findRichText: true),
        findsNWidgets(2));
    expect(find.textContaining('Cerdo', findRichText: true), findsWidgets);
    expect(find.text('Bancolombia'), findsOneWidget);
    expect(find.text('Cra 45 #12-30'), findsOneWidget);
    expect(find.text(formatoPesos(pedido.total)), findsOneWidget);
  });

  testWidgets('sin pedidos, la pestaña lo dice en vez de mostrar ejemplos',
      (tester) async {
    await tester.pumpWidget(const AppScope(
      child: MaterialApp(home: Scaffold(body: OrdersScreen())),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Todavía no tienes pedidos'), findsOneWidget);
  });

  testWidgets('la ficha del producto es solo lo básico', (tester) async {
    final carrito = CartModel();

    await tester.pumpWidget(AppScope(
      carritoInicial: carrito,
      usuarioInicial: UserModel(),
      child: MaterialApp(home: ProductDetailScreen(product: _clasica)),
    ));
    await tester.pumpAndSettle();

    // Lo que sí debe estar.
    expect(find.text(_clasica.name), findsOneWidget);
    expect(find.text(formatoPesos(_clasica.price)), findsOneWidget);
    expect(find.text(_clasica.description), findsOneWidget);
    expect(find.text('Cantidad'), findsOneWidget);
    expect(find.text('Agregar al carrito · ${formatoPesos(_clasica.price)}'), findsOneWidget);

    // Lo que NO: personalización ni ingredientes.
    expect(find.text('Salsas'), findsNothing);
    expect(find.text('Adiciones'), findsNothing);
    expect(find.text('Ingredientes'), findsNothing);
    expect(find.text('Bebidas'), findsNothing);
    for (final ingrediente in _clasica.ingredientes) {
      expect(find.text(ingrediente), findsNothing);
    }
  });

  testWidgets('las bebidas se agregan desde el carrito, con su sabor',
      (tester) async {
    final carrito = CartModel()..agregar(product: _clasica);

    await tester.pumpWidget(AppScope(
      carritoInicial: carrito,
      usuarioInicial: UserModel(),
      child: const MaterialApp(home: Scaffold(body: CartScreen())),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Bebidas'));
    await tester.pumpAndSettle();

    // Primero se escogen marcas, no presentaciones sueltas.
    expect(find.text('Coca-Cola'), findsOneWidget);
    expect(find.text('Hit'), findsOneWidget);

    await tester.tap(find.text('Postobón'));
    await tester.pumpAndSettle();

    // Dentro de la marca salen los tamaños, y el de 400 ml tiene varios
    // sabores, así que trae su seleccionador en vez de repetir la fila.
    expect(find.text('400 ml'), findsOneWidget);
    expect(find.byType(DropdownButton<String>), findsWidgets);

    // Se cambia el sabor y se agrega esa fila.
    final fila = find
        .ancestor(of: find.text('400 ml'), matching: find.byType(Row))
        .last;
    await tester.tap(
        find.descendant(of: fila, matching: find.byType(DropdownButton<String>)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cuatro').last);
    await tester.pumpAndSettle();

    await tester.tap(find.descendant(of: fila, matching: find.text('Agregar')));
    await tester.pumpAndSettle();

    final bebidaEnCarrito =
        carrito.lineas.firstWhere((l) => l.product.id == _bebida.id);
    expect(bebidaEnCarrito.opciones['Sabor'], 'Cuatro');
    expect(carrito.subtotal, _clasica.price + _bebida.price);
  });

  testWidgets('las bebidas se agrupan por marca y cada marca trae sus tamaños',
      (tester) async {
    final marcas = bebidasPorMarca();
    final coca = marcas.firstWhere((m) => m.nombre == 'Coca-Cola');

    // Coca-Cola se arma con presentaciones que estaban repartidas entre
    // varios productos del menú, y van de la más barata a la más cara.
    expect(coca.presentaciones.map((p) => p.tamano),
        containsAll(<String>['Pequeña', '400 ml', 'Econolitro', '1.5 L']));
    expect(coca.desde, 2600);
    final precios = coca.presentaciones.map((p) => p.precio).toList();
    expect(precios, orderedEquals(List.of(precios)..sort()));

    // Ninguna bebida se queda sin marca: todas aparecen en algún grupo.
    final enGrupos = marcas
        .expand((m) => m.presentaciones)
        .map((p) => p.producto.id)
        .toSet();
    expect(enGrupos, bebidas.map((b) => b.id).toSet());
  });

  test('la variante con recargo cambia el precio del producto', () {
    final mini = demoProducts.firstWhere((p) => p.id == 'mini_burguer');
    final carrito = CartModel()
      ..agregar(product: mini, opciones: mini.opcionesPorDefecto);
    final linea = carrito.lineas.single;

    expect(linea.precioUnitario, 12500);

    carrito.actualizarOpcion(linea, 'Queso o tocineta', 'Con queso');
    expect(linea.precioUnitario, 13000);
    expect(carrito.subtotal, 13000);
  });

  test('el chuzo deja escoger pollo o cerdo sin cambiar el precio', () {
    final carrito = CartModel()
      ..agregar(product: _chuzo, opciones: const {'Elige tu opción': 'Pollo'})
      ..agregar(product: _chuzo, opciones: const {'Elige tu opción': 'Cerdo'});

    // Configuraciones distintas → líneas distintas.
    expect(carrito.lineas.length, 2);
    expect(carrito.subtotal, _chuzo.price * 2);
  });
}
