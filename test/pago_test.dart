import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parche_mini_burger/models/product.dart';
import 'package:parche_mini_burger/screens/payment_screen.dart';
import 'package:parche_mini_burger/screens/product_detail_screen.dart';
import 'package:parche_mini_burger/state/app_scope.dart';
import 'package:parche_mini_burger/widgets/primary_button.dart';
import 'package:parche_mini_burger/models/precio.dart';

void main() {
  setUp(() {
    final view = TestWidgetsFlutterBinding.ensureInitialized()
        .platformDispatcher
        .views
        .first;
    view.physicalSize = const Size(400, 900);
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

  testWidgets('el comprobante deja elegir entre galería y archivos',
      (tester) async {
    await tester.pumpWidget(const AppScope(
      child: MaterialApp(home: PaymentScreen(total: 30000)),
    ));
    await tester.pump();

    expect(find.text('Toca para subir tu comprobante'), findsOneWidget);

    await tester.tap(find.text('Toca para subir tu comprobante'));
    await tester.pumpAndSettle();

    expect(find.text('¿De dónde tomamos el comprobante?'), findsOneWidget);
    expect(find.text('Galería'), findsWidgets);
    expect(find.text('Archivos'), findsWidgets);
  });

  testWidgets('no se puede enviar sin comprobante', (tester) async {
    await tester.pumpWidget(const AppScope(
      child: MaterialApp(home: PaymentScreen(total: 30000)),
    ));
    await tester.pump();

    final boton = tester.widget<PrimaryButton>(
      find.widgetWithText(PrimaryButton, 'Enviar comprobante'),
    );
    expect(boton.onPressed, isNull);
  });

  testWidgets('el detalle ya no pide tamaño ni mitad y mitad', (tester) async {
    await tester.pumpWidget(AppScope(
      child: MaterialApp(home: ProductDetailScreen(product: demoProducts.first)),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Tamaño'), findsNothing);
    expect(find.text('Mediana'), findsNothing);
    expect(find.text('Grande'), findsNothing);
    expect(find.text('Pedir mitad y mitad'), findsNothing);

    // El precio del producto sí se ve, y el botón cobra eso.
    expect(find.text(formatoPesos(demoProducts.first.price)), findsWidgets);
    expect(
      find.text('Agregar · ${formatoPesos(demoProducts.first.price)}'),
      findsOneWidget,
    );
  });
}
