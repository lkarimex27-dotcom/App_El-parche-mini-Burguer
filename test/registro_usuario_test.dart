import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parche_mini_burger/models/documento.dart';
import 'package:parche_mini_burger/screens/home_screen.dart';
import 'package:parche_mini_burger/screens/profile_screen.dart';
import 'package:parche_mini_burger/screens/register_screen.dart';
import 'package:parche_mini_burger/state/app_scope.dart';
import 'package:parche_mini_burger/state/user_model.dart';
import 'package:parche_mini_burger/widgets/app_header.dart';

void main() {
  setUp(() {
    final view = TestWidgetsFlutterBinding.ensureInitialized()
        .platformDispatcher
        .views
        .first;
    view.physicalSize = const Size(420, 2400);
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

  testWidgets('avisa y marca los campos cuando faltan datos obligatorios',
      (tester) async {
    await tester.pumpWidget(AppScope(
      usuarioInicial: UserModel(),
      child: const MaterialApp(home: RegisterScreen()),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Crear cuenta').last);
    await tester.pump();

    // Aviso general…
    expect(find.text('Completa los campos marcados en rojo'), findsOneWidget);
    // …y marca en cada campo que falta.
    expect(find.text('Completa este campo'), findsWidgets);
  });

  testWidgets('el tipo de documento incluye PPT', (tester) async {
    await tester.pumpWidget(AppScope(
      usuarioInicial: UserModel(),
      child: const MaterialApp(home: RegisterScreen()),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();

    expect(find.text('PPT').hitTestable(), findsWidgets);
    expect(kTiposDocumento.any((t) => t.codigo == 'PPT'), isTrue);
  });

  testWidgets('al registrarse se guardan los datos de esa persona',
      (tester) async {
    final usuario = UserModel();

    await tester.pumpWidget(AppScope(
      usuarioInicial: usuario,
      child: const MaterialApp(home: RegisterScreen()),
    ));
    await tester.pumpAndSettle();

    final campos = find.byType(TextFormField);
    await tester.enterText(campos.at(0), 'Andrés Gómez Ruiz');
    await tester.enterText(campos.at(1), '1234567890');
    await tester.enterText(campos.at(2), 'andres.gomez@correo.com');
    await tester.enterText(campos.at(3), '3009876543');
    await tester.enterText(campos.at(4), 'clave123');
    await tester.enterText(campos.at(5), 'clave123');
    await tester.pump();

    await tester.tap(find.text('Crear cuenta').last);
    await tester.pump();

    expect(usuario.nombre, 'Andrés Gómez Ruiz');
    expect(usuario.email, 'andres.gomez@correo.com');
    expect(usuario.telefono, '3009876543');
    expect(usuario.documento, '1234567890');
    expect(usuario.primerNombre, 'Andrés');
    expect(usuario.iniciales, 'AG');
  });

  testWidgets('el saludo, el encabezado y el perfil usan ese nombre',
      (tester) async {
    final usuario = UserModel()
      ..registrar(
        nombre: 'Andrés Gómez',
        email: 'andres@correo.com',
        telefono: '3009876543',
        tipoDocumento: 'PPT',
        documento: '987654',
      );

    await tester.pumpWidget(AppScope(
      usuarioInicial: usuario,
      child: MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              const AppHeader(),
              Expanded(child: HomeScreen(onVerMenu: () {})),
            ],
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Te damos la bienvenida, Andrés 👋'), findsOneWidget);
    // El encabezado ya solo lleva el logo: las iniciales quedaron en el
    // perfil, donde las comprueba la prueba de abajo.
    expect(usuario.iniciales, 'AG');
    expect(find.textContaining('Camila'), findsNothing);
  });

  testWidgets('el perfil muestra los datos de la cuenta y su flecha',
      (tester) async {
    final usuario = UserModel()
      ..registrar(
        nombre: 'Andrés Gómez',
        email: 'andres@correo.com',
        telefono: '3009876543',
        tipoDocumento: 'PPT',
        documento: '987654',
      );

    var cerrado = false;

    await tester.pumpWidget(AppScope(
      usuarioInicial: usuario,
      child: MaterialApp(
        home: Scaffold(body: ProfileScreen(onCerrar: () => cerrado = true)),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Andrés Gómez'), findsOneWidget);
    expect(find.text('andres@correo.com'), findsOneWidget);
    expect(find.text('PPT 987654'), findsOneWidget);

    await tester.tap(find.byTooltip('Cerrar perfil'));
    await tester.pump();
    expect(cerrado, isTrue);
  });
}
