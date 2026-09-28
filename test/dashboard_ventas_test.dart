import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parche_mini_burger/admin/data/admin_mock.dart';
import 'package:parche_mini_burger/admin/data/admin_repository.dart';
import 'package:parche_mini_burger/admin/screens/admin_module_screen.dart';
import 'package:parche_mini_burger/admin/screens/admin_nav_screen.dart';
import 'package:parche_mini_burger/models/precio.dart';
import 'package:parche_mini_burger/models/rol.dart';
import 'package:parche_mini_burger/state/app_scope.dart';
import 'package:parche_mini_burger/state/orders_model.dart';
import 'package:parche_mini_burger/state/user_model.dart';
import 'package:parche_mini_burger/widgets/app_header.dart';

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

  Widget panel() => AppScope(
        adminInicial: AdminRepository(),
        pedidosInicial: OrdersModel(iniciales: pedidosDeEjemplo()),
        usuarioInicial: UserModel(nombre: 'Ana Gómez', rol: Rol.administrador),
        child: const MaterialApp(home: AdminNavScreen()),
      );

  testWidgets('la gráfica de ventas trae los tres cortes de tiempo',
      (tester) async {
    await tester.pumpWidget(panel());
    await tester.pumpAndSettle();

    for (final corte in ['7 días', 'Mes', 'Año']) {
      expect(find.text(corte), findsOneWidget, reason: corte);
    }
    // Arranca en 7 días y el total es el de la semana.
    expect(find.text(formatoPesos(PeriodoVentas.semana.total)), findsOneWidget);
    expect(find.text('Cada barra es un día'), findsOneWidget);
  });

  testWidgets('cambiar el corte recalcula el total y las barras',
      (tester) async {
    await tester.pumpWidget(panel());
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Año'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Año'));
    await tester.pumpAndSettle();

    expect(find.text(formatoPesos(PeriodoVentas.ano.total)), findsOneWidget);
    expect(find.text('Cada barra es un mes'), findsOneWidget);
    // Doce meses, no siete días.
    expect(PeriodoVentas.ano.valores.length, 12);

    await tester.tap(find.text('Mes'));
    await tester.pumpAndSettle();
    expect(find.text(formatoPesos(PeriodoVentas.mes.total)), findsOneWidget);
    expect(find.text('Cada barra es una semana'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('abrir un módulo desde Más deja el encabezado arriba',
      (tester) async {
    await tester.pumpWidget(panel());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Más'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Proveedores'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Proveedores'));
    await tester.pumpAndSettle();

    // El módulo abrió y el logo con el perfil siguen arriba, así que el
    // título no queda pegado al borde de la pantalla.
    expect(find.byType(AdminModuleScreen), findsOneWidget);
    expect(find.byType(AppHeader), findsOneWidget);
    expect(find.text('AG'), findsOneWidget);
  });
}
