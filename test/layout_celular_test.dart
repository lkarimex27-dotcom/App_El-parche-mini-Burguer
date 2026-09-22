import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parche_mini_burger/models/extras.dart';
import 'package:parche_mini_burger/models/product.dart';
import 'package:parche_mini_burger/screens/login_screen.dart';
import 'package:parche_mini_burger/screens/main_nav_screen.dart';
import 'package:parche_mini_burger/screens/register_screen.dart';
import 'package:parche_mini_burger/screens/product_detail_screen.dart';
import 'package:parche_mini_burger/state/app_scope.dart';
import 'package:parche_mini_burger/state/cart_model.dart';

/// Las pantallas se arman a 360x800 (un celular común) para que cualquier
/// desborde de layout haga fallar la prueba.
void main() {
  setUp(() {
    final view = TestWidgetsFlutterBinding.ensureInitialized()
        .platformDispatcher
        .views
        .first;
    view.physicalSize = const Size(360, 800);
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

  testWidgets('las 5 pestañas se dibujan sin desbordes', (tester) async {
    final carrito = CartModel()
      ..agregar(
        product: demoProducts.first,
        salsas: {kSalsas.first, kSalsas.last},
        adiciones: {kAdiciones.first},
        opciones: demoProducts.first.opcionesPorDefecto,
        cantidad: 2,
      );

    await tester.pumpWidget(AppScope(
      carritoInicial: carrito,
      child: const MaterialApp(home: MainNavScreen()),
    ));
    await tester.pump();

    for (var tab = 0; tab < 5; tab++) {
      await tester.tap(find.byType(BottomNavigationBar).first.evaluate().isEmpty
          ? find.byIcon(Icons.home_rounded)
          : find.byIcon(_iconos[tab]));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'pestaña $tab');
    }
  });

  testWidgets('el registro cabe y hace scroll en un celular', (tester) async {
    await tester.pumpWidget(const AppScope(
      child: MaterialApp(home: RegisterScreen()),
    ));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);

    // Se puede bajar hasta el botón sin que nada quede cortado.
    await tester.dragUntilVisible(
      find.text('Crear cuenta').last,
      find.byType(SingleChildScrollView).first,
      const Offset(0, -120),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Crear cuenta'), findsWidgets);
  });

  testWidgets('el login muestra Google y Apple sin desbordes', (tester) async {
    await tester.pumpWidget(const AppScope(
      child: MaterialApp(home: LoginScreen()),
    ));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Google'), findsOneWidget);
    expect(find.text('Apple'), findsOneWidget);
    expect(find.text('¿Olvidaste tu contraseña?'), findsOneWidget);
  });

  testWidgets('el detalle del producto se dibuja sin desbordes', (tester) async {
    await tester.pumpWidget(AppScope(
      child: MaterialApp(
        home: ProductDetailScreen(product: demoProducts.first),
      ),
    ));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    // La ficha quedó simple: sin salsas, adiciones ni personalización.
    expect(find.text('Salsas'), findsNothing);
    expect(find.text('Adiciones'), findsNothing);
  });
}

const _iconos = [
  Icons.home_rounded,
  Icons.restaurant_menu_rounded,
  Icons.shopping_cart_rounded,
  Icons.receipt_long_rounded,
  Icons.person_rounded,
];
