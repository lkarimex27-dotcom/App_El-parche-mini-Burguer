import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parche_mini_burger/admin/data/admin_repository.dart';
import 'package:parche_mini_burger/admin/models/permisos.dart';
import 'package:parche_mini_burger/admin/screens/admin_nav_screen.dart';
import 'package:parche_mini_burger/models/rol.dart';
import 'package:parche_mini_burger/state/app_scope.dart';
import 'package:parche_mini_burger/state/user_model.dart';

Widget _app(AdminRepository repository, Widget child) => AppScope(
      adminInicial: repository,
      usuarioInicial: UserModel(nombre: 'Admin', rol: Rol.administrador),
      child: MaterialApp(home: Scaffold(body: child)),
    );

void main() {
  // Pantalla alta para que la lista de módulos se construya entera: en
  // 800×600 los de abajo no llegan a existir.
  setUp(() {
    final view = TestWidgetsFlutterBinding.ensureInitialized()
        .platformDispatcher
        .views
        .first;
    view.physicalSize = const Size(900, 2600);
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

  test('un proveedor con compras no se puede eliminar', () {
    final repository = AdminRepository();
    final proveedor = repository.registros(ModuloAdmin.proveedores).first;

    expect(repository.eliminar(ModuloAdmin.proveedores, proveedor), isFalse);
    expect(repository.registros(ModuloAdmin.proveedores), contains(proveedor));
  });

  testWidgets('los módulos aparecen en la navegación y permiten crear',
      (tester) async {
    final repository = AdminRepository();
    await tester.pumpWidget(_app(repository, const AdminNavScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Más'));
    await tester.pumpAndSettle();
    expect(find.text('Compras'), findsOneWidget);
    expect(find.text('Proveedores'), findsOneWidget);
    // Con la pantalla alta del setUp la lista cabe entera, así que no hay
    // que desplazarla (y scrollUntilVisible falla si hay más de una).
    expect(find.text('Indicadores'), findsOneWidget);

    await tester.tap(find.text('Proveedores'));
    await tester.pumpAndSettle();
    expect(find.text('Distribuciones La 30'), findsOneWidget);
    await tester.tap(find.byTooltip('Crear'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Nuevo'), findsOneWidget);
  });
}
