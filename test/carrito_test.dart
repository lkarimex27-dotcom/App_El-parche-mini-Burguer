import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parche_mini_burger/models/business_info.dart';
import 'package:parche_mini_burger/models/extras.dart';
import 'package:parche_mini_burger/models/product.dart';
import 'package:parche_mini_burger/screens/cart_screen.dart';
import 'package:parche_mini_burger/screens/main_nav_screen.dart';
import 'package:parche_mini_burger/state/app_scope.dart';
import 'package:parche_mini_burger/state/cart_model.dart';

Product get _clasica => demoProducts.firstWhere((p) => p.id == 'hamburguesa_doble');
Extra get _tocineta => kAdiciones.firstWhere((e) => e.id == 'ad_tocineta');
Extra get _bbq => kSalsas.firstWhere((e) => e.id == 'bbq');
Extra get _rosada => kSalsas.firstWhere((e) => e.id == 'rosada');

void main() {
  group('CartModel', () {
    test('el total suma producto, salsas, adiciones y cantidad', () {
      final carrito = CartModel();
      carrito.agregar(
        product: _clasica,
        salsas: {_rosada, _bbq},
        adiciones: {_tocineta},
        cantidad: 2,
      );

      // Las salsas van incluidas; solo suman las adiciones.
      final unitario = _clasica.price + _tocineta.precio;
      expect(carrito.lineas.single.precioUnitario, unitario);
      expect(carrito.subtotal, unitario * 2);
      expect(carrito.total, unitario * 2 + BusinessInfo.precioDomicilio);
      expect(carrito.cantidadTotal, 2);
    });

    test('la salsa gratis no cambia el precio', () {
      final carrito = CartModel();
      carrito.agregar(product: _clasica, salsas: {_rosada});
      expect(carrito.subtotal, _clasica.price);
    });

    test('dos veces el mismo producto igual se junta en una sola línea', () {
      final carrito = CartModel();
      carrito.agregar(product: _clasica);
      carrito.agregar(product: _clasica);

      expect(carrito.lineas.length, 1);
      expect(carrito.cantidadTotal, 2);
    });

    test('con adiciones distintas quedan líneas separadas', () {
      final carrito = CartModel();
      carrito.agregar(product: _clasica);
      carrito.agregar(product: _clasica, adiciones: {_tocineta});

      expect(carrito.lineas.length, 2);
    });

    test('bajar de 1 elimina la línea', () {
      final carrito = CartModel();
      carrito.agregar(product: _clasica);
      carrito.cambiarCantidad(carrito.lineas.first, -1);

      expect(carrito.estaVacio, isTrue);
      expect(carrito.total, 0, reason: 'sin productos no se cobra domicilio');
    });

    test('cambiar las adiciones actualiza el precio', () {
      final carrito = CartModel();
      carrito.agregar(product: _clasica);
      final antes = carrito.subtotal;

      carrito.actualizarAdiciones(carrito.lineas.first, {_tocineta});

      expect(carrito.subtotal, antes + _tocineta.precio);
    });
  });

  group('Carrito en pantalla', () {
    setUp(() {
      final view = TestWidgetsFlutterBinding.ensureInitialized()
          .platformDispatcher
          .views
          .first;
      view.physicalSize = const Size(1000, 2000);
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

    testWidgets('los botones + y − cambian la cantidad y el total',
        (tester) async {
      final carrito = CartModel()..agregar(product: _clasica);

      await tester.pumpWidget(AppScope(
        carritoInicial: carrito,
        child: const MaterialApp(home: Scaffold(body: CartScreen())),
      ));
      await tester.pump();

      expect(find.text('1'), findsOneWidget);
      expect(find.text('\$${_clasica.price}'), findsWidgets);

      await tester.tap(find.byIcon(Icons.add).first);
      await tester.pump();

      expect(carrito.cantidadTotal, 2);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('\$${_clasica.price * 2}'), findsWidgets);

      await tester.tap(find.byIcon(Icons.remove).first);
      await tester.pump();

      expect(carrito.cantidadTotal, 1);
    });

    testWidgets('el botón de la caneca elimina el producto', (tester) async {
      final carrito = CartModel()..agregar(product: _clasica);

      await tester.pumpWidget(AppScope(
        carritoInicial: carrito,
        child: const MaterialApp(home: Scaffold(body: CartScreen())),
      ));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.delete_outline_rounded));
      await tester.pump();

      expect(carrito.estaVacio, isTrue);
      expect(find.text('Tu carrito está vacío'), findsOneWidget);
    });

    testWidgets('se pueden agregar salsas desde el carrito', (tester) async {
      final carrito = CartModel()..agregar(product: _clasica);

      await tester.pumpWidget(AppScope(
        carritoInicial: carrito,
        child: const MaterialApp(home: Scaffold(body: CartScreen())),
      ));
      await tester.pump();

      await tester.tap(find.text('Salsas'));
      await tester.pumpAndSettle();

      await tester.tap(find.text(_bbq.nombre));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();

      expect(carrito.lineas.first.salsas, contains(_bbq));
      expect(carrito.subtotal, _clasica.price, reason: 'las salsas no cobran');
    });

    testWidgets('el badge del bottom nav muestra cuántos productos hay',
        (tester) async {
      final carrito = CartModel();

      await tester.pumpWidget(AppScope(
        carritoInicial: carrito,
        child: const MaterialApp(home: MainNavScreen()),
      ));
      await tester.pump();

      // Sin productos no hay globito.
      expect(find.text('3'), findsNothing);

      carrito.agregar(product: _clasica, cantidad: 3);
      await tester.pump();

      expect(find.text('3'), findsOneWidget);
    });
  });
}
