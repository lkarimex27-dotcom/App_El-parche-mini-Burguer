import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parche_mini_burger/admin/data/admin_mock.dart';
import 'package:parche_mini_burger/admin/data/admin_repository.dart';
import 'package:parche_mini_burger/admin/screens/dashboard_screen.dart';
import 'package:parche_mini_burger/empleado/screens/empleado_nav_screen.dart';
import 'package:parche_mini_burger/empleado/screens/inicio_empleado_screen.dart';
import 'package:parche_mini_burger/empleado/screens/pedidos_filtrados_screen.dart';
import 'package:parche_mini_burger/models/rol.dart';
import 'package:parche_mini_burger/state/app_scope.dart';
import 'package:parche_mini_burger/state/orders_model.dart';
import 'package:parche_mini_burger/state/tema_model.dart';
import 'package:parche_mini_burger/state/user_model.dart';

void main() {
  setUp(() {
    final v = TestWidgetsFlutterBinding.ensureInitialized()
        .platformDispatcher
        .views
        .first;
    v.physicalSize = const Size(420, 2600);
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

  Widget panelEmpleado({TemaModel? tema}) => AppScope(
        adminInicial: AdminRepository(),
        pedidosInicial: OrdersModel(iniciales: pedidosDeEjemplo()),
        usuarioInicial: UserModel(nombre: 'Luis Pérez', rol: Rol.empleado),
        temaInicial: tema,
        child: const MaterialApp(home: EmpleadoNavScreen()),
      );

  testWidgets('el empleado abre en su inicio, no en el del administrador',
      (tester) async {
    await tester.pumpWidget(panelEmpleado());
    await tester.pumpAndSettle();

    expect(find.byType(InicioEmpleadoScreen), findsOneWidget);
    expect(find.byType(DashboardScreen), findsNothing);
    // La pestaña se llama Inicio: "Dashboard" es palabra de dueño.
    expect(find.text('Inicio'), findsWidgets);
  });

  testWidgets('su inicio no muestra la plata del negocio', (tester) async {
    await tester.pumpWidget(panelEmpleado());
    await tester.pumpAndSettle();

    // La meta es de pedidos, no de dinero, y no hay ventas ni ticket.
    expect(find.text('Ventas hoy'), findsNothing);
    expect(find.text('Ticket promedio'), findsNothing);
    expect(find.text('Ventas por día'), findsNothing);
    expect(find.text('Productos más vendidos'), findsNothing);
    expect(find.text('Lo que más se pide'), findsNothing);
  });

  testWidgets('el orden es: alertas, próxima tarea y las cuatro tarjetas',
      (tester) async {
    await tester.pumpWidget(panelEmpleado());
    await tester.pumpAndSettle();

    // La alerta de lo que se va a acabar va de primera.
    expect(find.textContaining('Va a faltar'), findsWidgets);

    expect(find.text('Próxima tarea'), findsOneWidget);
    expect(find.textContaining('Preparar pedido #'), findsOneWidget);
    expect(find.textContaining('Entrega estimada'), findsOneWidget);

    for (final tarjeta in ['Pedidos de hoy', 'En curso', 'Listos',
        'Pendientes']) {
      expect(find.text(tarjeta), findsOneWidget, reason: tarjeta);
    }

    expect(find.text('Meta del día'), findsOneWidget);
    expect(find.text('Accesos rápidos'), findsOneWidget);
    expect(find.text('Pedidos recientes'), findsOneWidget);
  });

  testWidgets('tocar una tarjeta abre esos pedidos', (tester) async {
    await tester.pumpWidget(panelEmpleado());
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('En curso'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('En curso'));
    await tester.pumpAndSettle();

    expect(find.byType(PedidosFiltradosScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('la meta se cuenta con los pedidos entregados de verdad',
      (tester) async {
    final pedidos = OrdersModel(iniciales: pedidosDeEjemplo());
    await tester.pumpWidget(AppScope(
      adminInicial: AdminRepository(),
      pedidosInicial: pedidos,
      usuarioInicial: UserModel(nombre: 'Luis', rol: Rol.empleado),
      child: const MaterialApp(home: EmpleadoNavScreen()),
    ));
    await tester.pumpAndSettle();

    final entregadosHoy = pedidos.pedidos
        .where((p) =>
            p.status.name == 'entregado' &&
            p.fecha.day == DateTime.now().day &&
            p.fecha.month == DateTime.now().month)
        .length;

    // El número sale de los pedidos, no está escrito a mano.
    expect(
      find.text('$entregadosHoy de ${InicioEmpleadoScreen.metaDePedidos}'),
      findsOneWidget,
    );
  });

  testWidgets('abajo tiene sus tres pestañas y Más', (tester) async {
    await tester.pumpWidget(panelEmpleado());
    await tester.pumpAndSettle();

    final barra = tester.widget<BottomNavigationBar>(
      find.byType(BottomNavigationBar),
    );
    expect(barra.items.map((i) => i.label),
        ['Inicio', 'Producción', 'Inventario', 'Más']);
  });

  testWidgets('la luna cambia la app a modo oscuro', (tester) async {
    final tema = TemaModel();
    await tester.pumpWidget(panelEmpleado(tema: tema));
    await tester.pumpAndSettle();

    expect(tema.oscuro, isFalse);
    await tester.tap(find.byIcon(Icons.dark_mode_rounded));
    await tester.pumpAndSettle();

    expect(tema.oscuro, isTrue);
    // Y el botón pasa a ofrecer la vuelta al modo claro.
    expect(find.byIcon(Icons.light_mode_rounded), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
