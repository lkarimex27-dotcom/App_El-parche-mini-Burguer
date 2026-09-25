import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parche_mini_burger/models/product.dart';
import 'package:parche_mini_burger/screens/cart_screen.dart';
import 'package:parche_mini_burger/state/app_scope.dart';
import 'package:parche_mini_burger/state/cart_model.dart';
import 'package:parche_mini_burger/state/user_model.dart';

void main() {
  // Un celular angosto: es donde la fila de bebidas se desbordaba.
  setUp(() {
    final v = TestWidgetsFlutterBinding.ensureInitialized()
        .platformDispatcher
        .views
        .first;
    v.physicalSize = const Size(320, 640);
    v.devicePixelRatio = 1.0;
  });

  tearDown(() {
    final v = TestWidgetsFlutterBinding.ensureInitialized()
        .platformDispatcher
        .views
        .first;
    v.resetPhysicalSize();
    v.resetDevicePixelRatio();
  });

  Future<void> abrirPostobon(WidgetTester tester) async {
    final carrito = CartModel()..agregar(product: demoProducts.first);
    await tester.pumpWidget(AppScope(
      carritoInicial: carrito,
      usuarioInicial: UserModel(),
      child: const MaterialApp(home: Scaffold(body: CartScreen())),
    ));
    await tester.pump();
    await tester.tap(find.text('Bebidas'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Postobón'));
    await tester.pumpAndSettle();
  }

  testWidgets('la lista de tamaños no desborda en un celular angosto',
      (tester) async {
    await abrirPostobon(tester);
    expect(tester.takeException(), isNull);
  });

  testWidgets('los sabores se escogen tocando su ficha', (tester) async {
    await abrirPostobon(tester);

    // Uva existe como ficha, no escondida dentro de un desplegable.
    expect(find.text('Uva'), findsOneWidget);
    await tester.ensureVisible(find.text('Uva'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Uva'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  test('las bebidas ya no incluyen econolitros', () {
    expect(bebidas.any((b) => b.id.contains('econolitro')), isFalse);
    for (final marca in bebidasPorMarca()) {
      expect(marca.presentaciones.map((p) => p.tamano),
          isNot(contains('Econolitro')));
    }
  });
}
