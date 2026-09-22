import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parche_mini_burger/screens/forgot_password_screen.dart';
import 'package:parche_mini_burger/screens/home_screen.dart';
import 'package:parche_mini_burger/state/app_scope.dart';

/// Saca el código de 6 dígitos del mensaje que aparece al enviarlo.
String _codigoDelMensaje(WidgetTester tester) {
  final textos = tester
      .widgetList<Text>(find.byType(Text))
      .map((t) => t.data ?? '')
      .toList();
  final mensaje = textos.firstWhere((t) => t.contains('Código enviado'));
  return RegExp(r'\d{6}').firstMatch(mensaje)!.group(0)!;
}

void main() {
  setUp(() {
    final view = TestWidgetsFlutterBinding.ensureInitialized()
        .platformDispatcher
        .views
        .first;
    view.physicalSize = const Size(400, 900);
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

  testWidgets('pide correo, manda el código y deja cambiar la contraseña',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ForgotPasswordScreen()));
    await tester.pump();

    // Paso 1: un correo mal escrito no pasa.
    await tester.enterText(find.byType(TextField).first, 'esto-no-es-correo');
    await tester.tap(find.text('Enviar código'));
    await tester.pump();
    expect(find.text('Escribe un correo válido'), findsOneWidget);

    // Con un correo válido sí manda el código.
    await tester.enterText(find.byType(TextField).first, 'camila@correo.com');
    await tester.tap(find.text('Enviar código'));
    await tester.pump();

    expect(find.text('Revisa tu correo'), findsOneWidget);
    final codigo = _codigoDelMensaje(tester);

    // Paso 2: un código equivocado da error.
    await tester.enterText(find.byType(TextField).first, '000000');
    await tester.tap(find.text('Verificar código'));
    await tester.pump();
    expect(find.text('El código no coincide, revísalo'), findsOneWidget);

    // El código correcto sí pasa.
    await tester.enterText(find.byType(TextField).first, codigo);
    await tester.tap(find.text('Verificar código'));
    await tester.pump();
    expect(find.text('Crea tu contraseña nueva'), findsOneWidget);

    // Paso 3: las contraseñas tienen que coincidir.
    final campos = find.byType(TextField);
    await tester.enterText(campos.at(0), 'miclave123');
    await tester.enterText(campos.at(1), 'otracosa');
    await tester.tap(find.text('Guardar contraseña'));
    await tester.pump();
    expect(find.text('Las dos contraseñas no son iguales'), findsOneWidget);

    await tester.enterText(campos.at(1), 'miclave123');
    await tester.tap(find.text('Guardar contraseña'));
    await tester.pumpAndSettle();

    // Al terminar vuelve atrás (la pantalla ya no está).
    expect(find.text('Crea tu contraseña nueva'), findsNothing);
  });

  testWidgets('el Inicio abre con la bienvenida antes de las categorías',
      (tester) async {
    await tester.pumpWidget(AppScope(
      child: MaterialApp(home: Scaffold(body: HomeScreen(onVerMenu: () {}))),
    ));
    await tester.pump();

    expect(find.textContaining('Te damos la bienvenida'), findsOneWidget);

    // La bienvenida va por encima de las categorías en la pantalla.
    final yBienvenida =
        tester.getTopLeft(find.textContaining('Te damos la bienvenida')).dy;
    final yCategorias = tester.getTopLeft(find.text('Categorías')).dy;
    expect(yBienvenida, lessThan(yCategorias));
  });
}
