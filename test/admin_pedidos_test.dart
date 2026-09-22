import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parche_mini_burger/admin/data/admin_mock.dart';
import 'package:parche_mini_burger/admin/screens/admin_pedido_detalle_screen.dart';
import 'package:parche_mini_burger/admin/screens/admin_pedidos_screen.dart';
import 'package:parche_mini_burger/models/order.dart';
import 'package:parche_mini_burger/models/product.dart';
import 'package:parche_mini_burger/models/rol.dart';
import 'package:parche_mini_burger/state/app_scope.dart';
import 'package:parche_mini_burger/state/cart_model.dart';
import 'package:parche_mini_burger/state/orders_model.dart';
import 'package:parche_mini_burger/state/user_model.dart';

/// El panel de pedidos con los pedidos sembrados.
Widget _pantalla(OrdersModel pedidos, {Rol rol = Rol.administrador}) => AppScope(
      usuarioInicial: UserModel(nombre: 'Andrés Gómez', rol: rol),
      pedidosInicial: pedidos,
      child: const MaterialApp(home: Scaffold(body: AdminPedidosScreen())),
    );

OrdersModel _conSiembra() => OrdersModel(iniciales: pedidosDeEjemplo());

void main() {
  setUp(() {
    final view = TestWidgetsFlutterBinding.ensureInitialized()
        .platformDispatcher
        .views
        .first;
    view.physicalSize = const Size(390, 1200);
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

  group('Regla de aprobación', () {
    test('un pedido grande nace pendiente y pide aprobación', () {
      final caro = demoProducts.firstWhere((p) => p.id == 'salchipapa_super_gourmet');
      final carrito = CartModel()..agregar(product: caro, cantidad: 6);
      expect(carrito.total, greaterThan(kMontoAprobacion));

      final pedido = OrdersModel()
          .crearDesdeCarrito(carrito: carrito, metodoPago: 'Nequi');

      expect(pedido.status, OrderStatus.pendiente);
      expect(pedido.requiereAprobacion, isTrue);
    });

    test('un pedido normal entra directo a preparación', () {
      final carrito = CartModel()
        ..agregar(product: demoProducts.first, cantidad: 1);

      final pedido = OrdersModel()
          .crearDesdeCarrito(carrito: carrito, metodoPago: 'Nequi');

      expect(pedido.status, OrderStatus.preparacion);
      expect(pedido.requiereAprobacion, isFalse);
    });

    test('cambiar el estado queda anotado en el historial', () {
      final pedidos = _conSiembra();
      final pedido = pedidos.pedidos.firstWhere((p) => p.requiereAprobacion);
      final pasos = pedido.historial.length;

      pedidos.cambiarEstado(pedido, OrderStatus.aprobado);

      expect(pedido.status, OrderStatus.aprobado);
      expect(pedido.historial, hasLength(pasos + 1));
      expect(pedido.historial.last.texto, contains('Aprobado'));

      // Rechazar guarda el motivo.
      pedidos.cambiarEstado(pedido, OrderStatus.rechazado,
          nota: 'Comprobante ilegible');
      expect(pedido.note, 'Comprobante ilegible');
      expect(pedido.historial.last.texto, contains('Comprobante ilegible'));
      expect(pedido.estaCerrado, isTrue);
    });
  });

  testWidgets('la lista muestra cliente, total y estado', (tester) async {
    await tester.pumpWidget(_pantalla(_conSiembra()));
    await tester.pumpAndSettle();

    expect(find.text('Laura Mejía'), findsOneWidget);
    expect(find.text('Requiere tu aprobación'), findsOneWidget);
    expect(find.text('Pendiente'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('el buscador filtra por cliente', (tester) async {
    await tester.pumpWidget(_pantalla(_conSiembra()));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'daniela');
    await tester.pumpAndSettle();

    expect(find.text('Daniela Ortiz'), findsOneWidget);
    expect(find.text('Laura Mejía'), findsNothing);
  });

  testWidgets('el filtro por estado deja solo ese estado', (tester) async {
    final pedidos = _conSiembra();
    await tester.pumpWidget(_pantalla(pedidos));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Entregado').first);
    await tester.pumpAndSettle();

    expect(find.text('Julián Vélez'), findsOneWidget);
    expect(find.text('Laura Mejía'), findsNothing);
  });

  testWidgets('aprobar el pedido caro lo saca de la cola', (tester) async {
    final pedidos = _conSiembra();
    final caro = pedidos.pedidos.firstWhere((p) => p.requiereAprobacion);

    await tester.pumpWidget(_pantalla(pedidos));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Laura Mejía'));
    await tester.pumpAndSettle();

    expect(find.byType(AdminPedidoDetalleScreen), findsOneWidget);
    // El detalle trae todo lo que el cliente eligió.
    expect(find.text('Historial'), findsOneWidget);
    expect(find.textContaining('Salsas'), findsWidgets);

    await tester.tap(find.text('Aprobar'));
    await tester.pumpAndSettle();

    expect(caro.status, OrderStatus.aprobado);
    expect(caro.requiereAprobacion, isFalse);
    // Ya no ofrece aprobar, ahora ofrece el siguiente paso.
    expect(find.text('Aprobar'), findsNothing);
    expect(find.text('Marcar como en preparación'), findsOneWidget);
  });

  testWidgets('rechazar exige un motivo', (tester) async {
    final pedidos = _conSiembra();
    final caro = pedidos.pedidos.firstWhere((p) => p.requiereAprobacion);

    await tester.pumpWidget(_pantalla(pedidos));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Laura Mejía'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Rechazar'));
    await tester.pumpAndSettle();

    // Sin escribir nada no deja rechazar.
    await tester.tap(find.widgetWithText(TextButton, 'Rechazar'));
    await tester.pumpAndSettle();
    expect(caro.status, OrderStatus.pendiente);

    await tester.enterText(find.byType(TextField).last, 'Comprobante no válido');
    await tester.tap(find.widgetWithText(TextButton, 'Rechazar'));
    await tester.pumpAndSettle();

    expect(caro.status, OrderStatus.rechazado);
    expect(caro.note, 'Comprobante no válido');
  });

  testWidgets('un cocinero no puede mover pedidos', (tester) async {
    final pedidos = _conSiembra();

    await tester.pumpWidget(_pantalla(pedidos, rol: Rol.cocinero));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Laura Mejía'));
    await tester.pumpAndSettle();

    expect(find.text('Aprobar'), findsNothing);
    expect(find.text('Tu rol no puede aprobar pedidos.'), findsOneWidget);
  });
}
