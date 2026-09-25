import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parche_mini_burger/screens/main_nav_screen.dart';
import 'package:parche_mini_burger/screens/profile_screen.dart';
import 'package:parche_mini_burger/state/app_scope.dart';
import 'package:parche_mini_burger/state/user_model.dart';

void main() {
  setUp(() {
    final view = TestWidgetsFlutterBinding.ensureInitialized()
        .platformDispatcher
        .views
        .first;
    view.physicalSize = const Size(420, 1400);
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

  Widget app() => AppScope(
        usuarioInicial: UserModel()
          ..registrar(
            nombre: 'Andrés Gómez',
            email: 'andres@correo.com',
            telefono: '3001234567',
          ),
        child: const MaterialApp(home: MainNavScreen()),
      );

  testWidgets('el cliente llega a su perfil desde la pestaña de abajo',
      (tester) async {
    await tester.pumpWidget(app());
    await tester.pump();

    expect(find.text('Perfil'), findsOneWidget);
    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();

    expect(find.byType(ProfileScreen), findsOneWidget);
  });

  testWidgets('y también desde el círculo con sus iniciales del encabezado',
      (tester) async {
    await tester.pumpWidget(app());
    await tester.pump();

    // El círculo lleva las iniciales de quien inició sesión.
    expect(find.text('AG'), findsOneWidget);
    await tester.tap(find.text('AG'));
    await tester.pumpAndSettle();

    expect(find.byType(ProfileScreen), findsOneWidget);
  });
}
