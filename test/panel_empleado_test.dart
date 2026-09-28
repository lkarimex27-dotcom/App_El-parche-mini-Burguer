import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parche_mini_burger/admin/data/admin_repository.dart';
import 'package:parche_mini_burger/admin/screens/dashboard_screen.dart';
import 'package:parche_mini_burger/empleado/screens/empleado_nav_screen.dart';
import 'package:parche_mini_burger/empleado/screens/inicio_empleado_screen.dart';
import 'package:parche_mini_burger/models/rol.dart';
import 'package:parche_mini_burger/state/app_scope.dart';
import 'package:parche_mini_burger/state/orders_model.dart';
import 'package:parche_mini_burger/state/user_model.dart';
import 'package:parche_mini_burger/admin/data/admin_mock.dart';

void main() {
  setUp(() {
    final v = TestWidgetsFlutterBinding.ensureInitialized()
        .platformDispatcher
        .views
        .first;
    v.physicalSize = const Size(420, 2400);
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

  Widget panelEmpleado() => AppScope(
        adminInicial: AdminRepository(),
        pedidosInicial: OrdersModel(iniciales: pedidosDeEjemplo()),
        usuarioInicial: UserModel(nombre: 'Luis Pérez', rol: Rol.empleado),
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

    // Nada de ventas del día, ticket promedio ni metas: eso es del dueño.
    expect(find.text('Ventas hoy'), findsNothing);
    expect(find.text('Ticket promedio'), findsNothing);
    expect(find.text('Meta del día'), findsNothing);
    expect(find.textContaining('Cumplimiento de meta'), findsNothing);
    expect(find.text('Ventas por día'), findsNothing);
  });

  testWidgets('su inicio muestra lo que tiene que hacer hoy', (tester) async {
    await tester.pumpWidget(panelEmpleado());
    await tester.pumpAndSettle();

    expect(find.text('En producción'), findsOneWidget);
    expect(find.text('Se está acabando'), findsOneWidget);
    expect(find.textContaining('Órdenes por hacer'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('desde un insumo bajo entra a Compras', (tester) async {
    await tester.pumpWidget(panelEmpleado());
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Comprar').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Comprar').first);
    await tester.pumpAndSettle();

    expect(find.text('Compras'), findsWidgets);
    expect(tester.takeException(), isNull);
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
}
