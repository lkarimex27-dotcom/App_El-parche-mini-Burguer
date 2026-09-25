import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parche_mini_burger/admin/data/admin_mock.dart';
import 'package:parche_mini_burger/domiciliario/models/domiciliario_model.dart';
import 'package:parche_mini_burger/domiciliario/screens/detalle_entrega_screen.dart';
import 'package:parche_mini_burger/domiciliario/screens/domiciliario_nav_screen.dart';
import 'package:parche_mini_burger/models/order.dart';
import 'package:parche_mini_burger/models/rol.dart';
import 'package:parche_mini_burger/state/app_scope.dart';
import 'package:parche_mini_burger/state/orders_model.dart';
import 'package:parche_mini_burger/state/user_model.dart';

autoDispose(WidgetTester tester) {
  addTearDown(() {
    final view = TestWidgetsFlutterBinding.ensureInitialized()
        .platformDispatcher
        .views
        .first;
    view.resetPhysicalSize();
    view.resetDevicePixelRatio();
  });
}

Widget pantalla(OrdersModel pedidos) => AppScope(
      usuarioInicial: UserModel(
        nombre: 'Luis Repartidor',
        email: 'repartidor@elparche.com',
        rol: Rol.repartidor,
      ),
      pedidosInicial: pedidos,
      domiciliarioInicial: DomiciliarioModel(vehiculo: 'Moto'),
      child: const MaterialApp(home: DomiciliarioNavScreen()),
    );

void main() {
  test('el correo temporal entra como domiciliario', () {
    final usuario = UserModel()..iniciarSesionConCorreo('repartidor@demo.com');

    expect(usuario.rol, Rol.repartidor);
    expect(usuario.rol.esDomiciliario, isTrue);
    expect(usuario.rol.esDelPanel, isFalse);
  });

  test('las fases de entrega actualizan el mismo pedido', () {
    final pedido = pedidosDeEjemplo().firstWhere((p) => p.id == '1052');
    final pedidos = OrdersModel(iniciales: [pedido]);

    expect(pedidos.pedidosAsignados('repartidor@elparche.com'), [pedido]);

    pedidos.cambiarEstado(pedido, OrderStatus.enLocal);
    pedidos.cambiarEstado(pedido, OrderStatus.enCamino);
    pedidos.cambiarEstado(pedido, OrderStatus.entregado);

    expect(pedido.status, OrderStatus.entregado);
    expect(pedido.fechaDeFase(OrderStatus.enLocal), isNotNull);
    expect(pedido.fechaDeFase(OrderStatus.enCamino), isNotNull);
    expect(pedido.estaCerrado, isTrue);
  });

  test('el código de seguridad es obligatorio para entregar', () {
    final pedido = pedidosDeEjemplo().firstWhere((p) => p.id == '1052');
    final pedidos = OrdersModel(iniciales: [pedido]);
    pedidos.cambiarEstado(pedido, OrderStatus.enLocal);
    pedidos.cambiarEstado(pedido, OrderStatus.enCamino);

    expect(pedidos.confirmarEntrega(pedido, '9999'), isFalse);
    expect(pedido.status, OrderStatus.enCamino);
    expect(pedidos.confirmarEntrega(pedido, '1052'), isTrue);
    expect(pedido.status, OrderStatus.entregado);
  });

  testWidgets('inicio muestra el pedido asignado', (tester) async {
    autoDispose(tester);
    await tester
        .pumpWidget(pantalla(OrdersModel(iniciales: pedidosDeEjemplo())));
    await tester.pumpAndSettle();

    expect(find.text('Hola, Luis'), findsOneWidget);
    expect(find.text('Pedidos asignados'), findsOneWidget);
    expect(find.text('Daniela Ortiz'), findsOneWidget);
    expect(find.text('Calle 12 #8-24, casa 3'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('el avatar superior abre el perfil', (tester) async {
    autoDispose(tester);
    await tester
        .pumpWidget(pantalla(OrdersModel(iniciales: pedidosDeEjemplo())));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(CircleAvatar).first);
    await tester.pumpAndSettle();

    expect(find.text('Mi perfil'), findsOneWidget);
    expect(find.byTooltip('Editar perfil'), findsOneWidget);
  });

  testWidgets('detalle permite recoger y poner en camino', (tester) async {
    autoDispose(tester);
    final pedido = pedidosDeEjemplo().firstWhere((p) => p.id == '1052');
    final pedidos = OrdersModel(iniciales: [pedido]);
    await tester.pumpWidget(pantalla(pedidos));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Daniela Ortiz'));
    await tester.pumpAndSettle();
    expect(find.byType(DetalleEntregaScreen), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'En el local'), findsOneWidget);

    await tester.tap(find.widgetWithText(ElevatedButton, 'En el local'));
    await tester.pumpAndSettle();

    expect(pedido.status, OrderStatus.enLocal);
    expect(find.widgetWithText(ElevatedButton, 'En camino'), findsOneWidget);
  });

  testWidgets('entrega solicita cuatro casillas para el PIN', (tester) async {
    autoDispose(tester);
    final pedido = pedidosDeEjemplo().firstWhere((p) => p.id == '1056');
    final pedidos = OrdersModel(iniciales: [pedido]);
    await tester.pumpWidget(pantalla(pedidos));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Andrés Rojas'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Entregado'));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsNWidgets(4));
    final casillas = find.byType(TextField);
    for (var i = 0; i < 4; i++) {
      await tester.enterText(casillas.at(i), '1056'[i]);
    }
    expect(find.widgetWithText(TextButton, 'Confirmar'), findsOneWidget);
    pedidos.confirmarEntrega(pedido, '1056');
    expect(pedido.status, OrderStatus.entregado);
  });

  testWidgets('historial muestra las entregas completadas', (tester) async {
    autoDispose(tester);
    await tester
        .pumpWidget(pantalla(OrdersModel(iniciales: pedidosDeEjemplo())));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Historial'));
    await tester.pumpAndSettle();

    expect(find.text('Historial de entregas'), findsOneWidget);
    expect(find.text('Julián Vélez'), findsOneWidget);
    expect(find.text('Pedido #1052'), findsNothing);
  });

  testWidgets('perfil muestra vehículo y métricas', (tester) async {
    autoDispose(tester);
    await tester
        .pumpWidget(pantalla(OrdersModel(iniciales: pedidosDeEjemplo())));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();

    expect(find.text('Mi perfil'), findsOneWidget);
    expect(find.text('Moto'), findsOneWidget);
    expect(find.text('Entregas totales'), findsOneWidget);
    expect(find.text('Entregas de hoy'), findsOneWidget);
  });
}
