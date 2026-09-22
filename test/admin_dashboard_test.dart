import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parche_mini_burger/admin/data/admin_mock.dart';
import 'package:parche_mini_burger/admin/models/permisos.dart';
import 'package:parche_mini_burger/admin/screens/admin_nav_screen.dart';
import 'package:parche_mini_burger/models/rol.dart';
import 'package:parche_mini_burger/state/app_scope.dart';
import 'package:parche_mini_burger/state/orders_model.dart';
import 'package:parche_mini_burger/state/user_model.dart';

UserModel _usuario(Rol rol) => UserModel(
      nombre: 'Andrés Gómez',
      email: 'andres@correo.com',
      rol: rol,
    );

Widget _panel(Rol rol) => AppScope(
      usuarioInicial: _usuario(rol),
      pedidosInicial: OrdersModel(iniciales: pedidosDeEjemplo()),
      child: const MaterialApp(home: AdminNavScreen()),
    );

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

  testWidgets('el dashboard se dibuja sin desbordes en un celular',
      (tester) async {
    await tester.pumpWidget(_panel(Rol.administrador));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Hola, Andrés'), findsOneWidget);
    expect(find.text('Resumen de tu negocio'), findsOneWidget);

    // Bajando aparece el resto, sin que nada se desborde.
    for (final seccion in const [
      'Ventas por día',
      'Accesos rápidos',
      'Productos más vendidos',
      'Pedidos recientes',
    ]) {
      await tester.scrollUntilVisible(find.text(seccion), 250);
      await tester.pumpAndSettle();
      expect(find.text(seccion), findsOneWidget);
      expect(tester.takeException(), isNull, reason: seccion);
    }
  });

  testWidgets('los indicadores salen de los pedidos sembrados',
      (tester) async {
    final pedidos = pedidosDeEjemplo();
    final porAprobar = pedidos.where(requiereAprobacion).toList();

    await tester.pumpWidget(_panel(Rol.administrador));
    await tester.pumpAndSettle();

    // Hay un pedido caro esperando aprobación y su alerta lo dice.
    expect(porAprobar, hasLength(1));
    expect(
      find.textContaining('requiere aprobación'),
      findsOneWidget,
    );
    expect(find.text('${porAprobar.length} por aprobar'), findsOneWidget);

    // Y el pedido más reciente aparece en "Pedidos recientes".
    expect(find.textContaining('#${pedidos.first.id}'), findsOneWidget);
  });

  testWidgets('la alerta de stock bajo lleva a Inventario', (tester) async {
    await tester.pumpWidget(_panel(Rol.administrador));
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining(insumosBajos.first.nombre));
    await tester.pumpAndSettle();

    expect(find.text(ModuloAdmin.inventario.label), findsWidgets);
  });

  testWidgets('un cocinero no ve los módulos que no le tocan', (tester) async {
    await tester.pumpWidget(_panel(Rol.cocinero));
    await tester.pumpAndSettle();

    // Sí ve producción e inventario…
    expect(find.text('Producción'), findsWidgets);
    expect(find.text('Inventario'), findsWidgets);
    // …pero no pedidos, que es de vendedor/administrador.
    expect(find.text('Pedidos'), findsNothing);

    // Y en "Más" tampoco le aparecen Compras ni Ventas.
    await tester.tap(find.text('Más'));
    await tester.pumpAndSettle();

    expect(find.text('Compras'), findsNothing);
    expect(find.text('Ventas'), findsNothing);
    expect(find.text('Fichas técnicas'), findsOneWidget);
  });

  test('los permisos por rol son coherentes', () {
    // El administrador ve todo.
    for (final m in ModuloAdmin.values) {
      expect(puedeVer(Rol.administrador, m), isTrue, reason: m.label);
    }
    // El cliente no entra al panel.
    for (final m in ModuloAdmin.values) {
      expect(puedeVer(Rol.cliente, m), isFalse, reason: m.label);
    }
    expect(Rol.cliente.esDelPanel, isFalse);
    expect(Rol.vendedor.esDelPanel, isTrue);

    // Un vendedor crea pedidos pero no los elimina.
    expect(puede(Rol.vendedor, ModuloAdmin.pedidos, Permiso.crear), isTrue);
    expect(puede(Rol.vendedor, ModuloAdmin.pedidos, Permiso.eliminar), isFalse);
  });

  test('el login deduce el rol del correo mientras no hay backend', () {
    expect((UserModel()..iniciarSesionConCorreo('admin@parche.com')).rol,
        Rol.administrador);
    expect((UserModel()..iniciarSesionConCorreo('cocinero@parche.com')).rol,
        Rol.cocinero);
    expect((UserModel()..iniciarSesionConCorreo('camila@correo.com')).rol,
        Rol.cliente);
  });
}
