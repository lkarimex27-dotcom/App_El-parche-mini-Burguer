import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parche_mini_burger/admin/screens/admin_nav_screen.dart';
import 'package:parche_mini_burger/domiciliario/screens/domiciliario_nav_screen.dart';
import 'package:parche_mini_burger/empleado/screens/empleado_nav_screen.dart';
import 'package:parche_mini_burger/models/claves_panel.dart';
import 'package:parche_mini_burger/models/rol.dart';
import 'package:parche_mini_burger/screens/login_screen.dart';
import 'package:parche_mini_burger/screens/main_nav_screen.dart';
import 'package:parche_mini_burger/state/app_scope.dart';
import 'package:parche_mini_burger/state/user_model.dart';

void main() {
  setUp(() {
    final v = TestWidgetsFlutterBinding.ensureInitialized()
        .platformDispatcher
        .views
        .first;
    v.physicalSize = const Size(420, 2200);
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

  Future<UserModel> entrar(
    WidgetTester tester, {
    required String correo,
    required String clave,
  }) async {
    final usuario = UserModel();
    await tester.pumpWidget(AppScope(
      usuarioInicial: usuario,
      child: const MaterialApp(home: LoginScreen()),
    ));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, correo);
    await tester.enterText(find.byType(TextFormField).at(1), clave);
    await tester.tap(find.text('Iniciar sesión'));
    await tester.pumpAndSettle();
    return usuario;
  }

  test('cada panel pide su clave; el cliente no', () {
    expect(pideClave(Rol.administrador), isTrue);
    expect(pideClave(Rol.empleado), isTrue);
    expect(pideClave(Rol.repartidor), isTrue);
    expect(pideClave(Rol.cliente), isFalse);
  });

  test('las claves son las entregadas, con sus símbolos', () {
    expect(claveCorrecta(Rol.administrador, 'Admin@Parche26'), isTrue);
    expect(claveCorrecta(Rol.empleado, 'Empleado#26P'), isTrue);
    expect(claveCorrecta(Rol.repartidor, r'Repartidor$26'), isTrue);
  });

  test('las mayúsculas y los símbolos cuentan', () {
    expect(claveCorrecta(Rol.administrador, 'admin@parche26'), isFalse);
    expect(claveCorrecta(Rol.administrador, 'Admin@Parche25'), isFalse);
    expect(claveCorrecta(Rol.empleado, 'Empleado26P'), isFalse);
    expect(claveCorrecta(Rol.repartidor, 'Repartidor26'), isFalse);
  });

  test('la clave de un panel no abre otro', () {
    expect(claveCorrecta(Rol.empleado, 'Admin@Parche26'), isFalse);
    expect(claveCorrecta(Rol.repartidor, 'Empleado#26P'), isFalse);
    expect(claveCorrecta(Rol.administrador, r'Repartidor$26'), isFalse);
  });

  testWidgets('con la clave buena, el administrador entra a su panel',
      (tester) async {
    final usuario = await entrar(tester,
        correo: 'admin@elparche.com', clave: 'Admin@Parche26');

    expect(usuario.rol, Rol.administrador);
    expect(find.byType(AdminNavScreen), findsOneWidget);
  });

  testWidgets('con la clave buena, el empleado entra a su panel',
      (tester) async {
    final usuario = await entrar(tester,
        correo: 'empleado@elparche.com', clave: 'Empleado#26P');

    expect(usuario.rol, Rol.empleado);
    expect(find.byType(EmpleadoNavScreen), findsOneWidget);
  });

  testWidgets('con la clave buena, el repartidor entra a sus entregas',
      (tester) async {
    final usuario = await entrar(tester,
        correo: 'repartidor@elparche.com', clave: r'Repartidor$26');

    expect(usuario.rol, Rol.repartidor);
    expect(find.byType(DomiciliarioNavScreen), findsOneWidget);
  });

  testWidgets('con la clave mala no entra, y tampoco se cuela como cliente',
      (tester) async {
    final usuario =
        await entrar(tester, correo: 'admin@elparche.com', clave: 'loquesea');

    // Se queda en el login, con el aviso.
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(AdminNavScreen), findsNothing);
    expect(find.byType(MainNavScreen), findsNothing);
    expect(find.textContaining('Contraseña incorrecta'), findsOneWidget);
    // Y la sesión queda cerrada, no a medio abrir.
    expect(usuario.rol, Rol.cliente);
    expect(usuario.email, isEmpty);
  });

  testWidgets('la clave de otro panel tampoco sirve', (tester) async {
    await entrar(tester,
        correo: 'empleado@elparche.com', clave: 'Admin@Parche26');

    expect(find.byType(EmpleadoNavScreen), findsNothing);
    expect(find.textContaining('Contraseña incorrecta'), findsOneWidget);
  });

  testWidgets('un cliente entra con cualquier contraseña', (tester) async {
    final usuario = await entrar(tester,
        correo: 'laura@correo.com', clave: 'la que sea');

    expect(usuario.rol, Rol.cliente);
    expect(find.byType(MainNavScreen), findsOneWidget);
  });
}
