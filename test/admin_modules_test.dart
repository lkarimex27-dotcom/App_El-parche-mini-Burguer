import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parche_mini_burger/admin/data/admin_repository.dart';
import 'package:parche_mini_burger/admin/models/permisos.dart';
import 'package:parche_mini_burger/admin/screens/admin_module_screen.dart';
import 'package:parche_mini_burger/admin/screens/admin_nav_screen.dart';
import 'package:parche_mini_burger/admin/screens/mas_screen.dart';
import 'package:parche_mini_burger/models/rol.dart';
import 'package:parche_mini_burger/state/app_scope.dart';
import 'package:parche_mini_burger/state/user_model.dart';

Widget _app(AdminRepository repository, Widget child) => AppScope(
      adminInicial: repository,
      usuarioInicial: UserModel(nombre: 'Admin', rol: Rol.administrador),
      child: MaterialApp(home: Scaffold(body: child)),
    );

void main() {
  test('un proveedor con compras no se puede eliminar', () {
    final repository = AdminRepository();
    final proveedor = repository.registros(ModuloAdmin.proveedores).first;

    expect(repository.eliminar(ModuloAdmin.proveedores, proveedor), isFalse);
    expect(repository.registros(ModuloAdmin.proveedores), contains(proveedor));
  });

  test('un proveedor se anula, pero nunca se elimina', () {
    final repository = AdminRepository();
    final proveedor = repository.registros(ModuloAdmin.proveedores).last;

    expect(repository.eliminar(ModuloAdmin.proveedores, proveedor), isFalse);
    expect(repository.anular(proveedor), isTrue);
    expect(proveedor.estado, 'Inactivo');
    expect(repository.registros(ModuloAdmin.proveedores), contains(proveedor));
  });

  test('solo el registro Administrador queda protegido en Roles', () {
    final repository = AdminRepository();
    final roles = repository.registros(ModuloAdmin.roles);
    expect(
        roles.map((r) => r.titulo),
        containsAll([
          'Administrador',
          'Repartidor',
          'Empleado',
          'Cliente',
        ]));
    final administrador = roles.firstWhere((r) => r.titulo == 'Administrador');
    final repartidor = roles.firstWhere((r) => r.titulo == 'Repartidor');

    repository.establecerEstado(administrador, 'Inactivo');
    expect(administrador.estado, 'Activo');

    repository.establecerEstado(repartidor, 'Inactivo');
    expect(repartidor.estado, 'Inactivo');
  });

  testWidgets('en Roles solo Administrador queda sin cambio de estado',
      (tester) async {
    final repository = AdminRepository();
    await tester.pumpWidget(
      _app(
        repository,
        const AdminModuleScreen(modulo: ModuloAdmin.roles),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Cambiar estado'), findsNWidgets(2));
    expect(
        repository.puedeCambiarEstado(
          repository.registros(ModuloAdmin.roles).first,
        ),
        isFalse);
    expect(
      repository.puedeCambiarEstado(
        repository.registros(ModuloAdmin.roles).last,
      ),
      isTrue,
    );
  });

  testWidgets('el proveedor muestra Anular y no muestra Eliminar',
      (tester) async {
    final repository = AdminRepository();
    await tester.pumpWidget(
      _app(
        repository,
        const AdminModuleScreen(modulo: ModuloAdmin.proveedores),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byTooltip('Eliminar'), findsNothing);
    expect(find.text('Anular'), findsNWidgets(2));

    await tester.tap(find.text('Anular').first);
    await tester.pumpAndSettle();
    expect(find.text('¿Anular proveedor?'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Anular'));
    await tester.pumpAndSettle();
    expect(
      repository.registros(ModuloAdmin.proveedores).first.estado,
      'Inactivo',
    );
  });

  testWidgets('los módulos aparecen en la navegación y permiten crear',
      (tester) async {
    final repository = AdminRepository();
    await tester.pumpWidget(_app(repository, const AdminNavScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Más'));
    await tester.pumpAndSettle();
    final listaMas = find
        .descendant(
          of: find.byType(MasScreen),
          matching: find.byType(Scrollable),
        )
        .first;
    await tester.scrollUntilVisible(
      find.text('Compras'),
      300,
      scrollable: listaMas,
    );
    expect(find.text('Compras'), findsOneWidget);
    expect(find.text('Proveedores'), findsOneWidget);
    expect(find.text('Indicadores'), findsNothing);

    await tester.scrollUntilVisible(
      find.text('Proveedores'),
      -300,
      scrollable: listaMas,
    );
    await tester.tap(find.text('Proveedores'));
    await tester.pumpAndSettle();
    expect(find.text('Distribuciones La 30'), findsOneWidget);
    await tester.tap(find.byTooltip('Crear'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Nuevo'), findsOneWidget);
  });
}
