import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parche_mini_burger/admin/data/admin_repository.dart';
import 'package:parche_mini_burger/admin/models/permisos.dart';
import 'package:parche_mini_burger/admin/screens/admin_nav_screen.dart';
import 'package:parche_mini_burger/models/rol.dart';
import 'package:parche_mini_burger/state/app_scope.dart';
import 'package:parche_mini_burger/state/user_model.dart';

void main() {
  setUp(() {
    final v = TestWidgetsFlutterBinding.ensureInitialized()
        .platformDispatcher
        .views
        .first;
    v.physicalSize = const Size(900, 2600);
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

  test('el empleado ve la operación del local y nada más', () {
    const suyos = {
      ModuloAdmin.dashboard,
      ModuloAdmin.pedidos,
      ModuloAdmin.produccion,
      ModuloAdmin.inventario,
      ModuloAdmin.fichasTecnicas,
      ModuloAdmin.productos,
      ModuloAdmin.categorias,
      ModuloAdmin.perfil,
    };

    for (final modulo in ModuloAdmin.values) {
      expect(puedeVer(Rol.empleado, modulo), suyos.contains(modulo),
          reason: 'empleado y ${modulo.label}');
    }
  });

  test('el empleado produce y mueve inventario', () {
    expect(puede(Rol.empleado, ModuloAdmin.produccion, Permiso.crear), isTrue);
    expect(
        puede(Rol.empleado, ModuloAdmin.produccion, Permiso.cambiarEstado),
        isTrue);
    expect(puede(Rol.empleado, ModuloAdmin.inventario, Permiso.crear), isTrue);
    expect(puede(Rol.empleado, ModuloAdmin.inventario, Permiso.editar), isTrue);
  });

  test('el catálogo lo consulta, no lo cambia', () {
    for (final modulo in [ModuloAdmin.productos, ModuloAdmin.categorias]) {
      expect(puede(Rol.empleado, modulo, Permiso.ver), isTrue);
      expect(puede(Rol.empleado, modulo, Permiso.crear), isFalse);
      expect(puede(Rol.empleado, modulo, Permiso.editar), isFalse);
    }
  });

  test('lo que no le toca al empleado', () {
    for (final modulo in [
      ModuloAdmin.compras,
      ModuloAdmin.proveedores,
      ModuloAdmin.ventas,
      ModuloAdmin.clientes,
      ModuloAdmin.usuarios,
      ModuloAdmin.roles,
      ModuloAdmin.devoluciones,
      ModuloAdmin.perdidas,
    ]) {
      expect(puedeVer(Rol.empleado, modulo), isFalse, reason: modulo.label);
    }
  });

  test('empleado@ entra al panel como empleado', () {
    // TEMPORAL igual que el resto: mientras no hay backend el rol sale del
    // correo con el que se inicia sesión.
    final usuario = UserModel()..iniciarSesionConCorreo('empleado@elparche.com');
    expect(usuario.rol, Rol.empleado);
    expect(usuario.rol.esDelPanel, isTrue);

    // Quien se registra desde la app es cliente, no empleado.
    final nuevo = UserModel()
      ..registrar(
        nombre: 'Luis Pérez',
        email: 'empleado@elparche.com',
        telefono: '3001112233',
      );
    expect(nuevo.rol, Rol.cliente);
  });

  testWidgets('el panel del empleado abre con sus pestañas', (tester) async {
    await tester.pumpWidget(AppScope(
      adminInicial: AdminRepository(),
      usuarioInicial: UserModel(nombre: 'Luis', rol: Rol.empleado),
      child: const MaterialApp(home: AdminNavScreen()),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Producción'), findsWidgets);
    expect(find.text('Inventario'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('en "Más" salen sus módulos y no los del administrador',
      (tester) async {
    await tester.pumpWidget(AppScope(
      adminInicial: AdminRepository(),
      usuarioInicial: UserModel(nombre: 'Luis', rol: Rol.empleado),
      child: const MaterialApp(home: AdminNavScreen()),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Más'));
    await tester.pumpAndSettle();

    // El catálogo, que consulta.
    expect(find.text('Productos'), findsOneWidget);
    expect(find.text('Categorías'), findsOneWidget);
    expect(find.text('Fichas técnicas'), findsOneWidget);

    // Lo que no le toca: ni la plata ni la administración.
    expect(find.text('Compras'), findsNothing);
    expect(find.text('Proveedores'), findsNothing);
    expect(find.text('Ventas'), findsNothing);
    expect(find.text('Usuarios'), findsNothing);
    expect(find.text('Roles y permisos'), findsNothing);
  });
}
