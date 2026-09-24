import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parche_mini_burger/admin/data/admin_repository.dart';
import 'package:parche_mini_burger/admin/screens/admin_nav_screen.dart';
import 'package:parche_mini_burger/admin/screens/mas_screen.dart';
import 'package:parche_mini_burger/models/product.dart';
import 'package:parche_mini_burger/models/rol.dart';
import 'package:parche_mini_burger/state/app_scope.dart';
import 'package:parche_mini_burger/state/user_model.dart';

void main() {
  setUp(() {
    final view = TestWidgetsFlutterBinding.ensureInitialized()
        .platformDispatcher
        .views
        .first;
    view.physicalSize = const Size(360, 480);
    view.devicePixelRatio = 1;
  });

  tearDown(() {
    final view = TestWidgetsFlutterBinding.ensureInitialized()
        .platformDispatcher
        .views
        .first;
    view.resetPhysicalSize();
    view.resetDevicePixelRatio();
  });

  testWidgets('el modal de detalle de producto no desborda', (tester) async {
    await tester.pumpWidget(
      AppScope(
        adminInicial: AdminRepository(),
        usuarioInicial: UserModel(nombre: 'Admin', rol: Rol.administrador),
        child: const MaterialApp(home: AdminNavScreen()),
      ),
    );
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
      find.text('Productos'),
      300,
      scrollable: listaMas,
    );
    await tester.tap(find.text('Productos'));
    await tester.pumpAndSettle();

    await tester.tap(find.text(demoProducts.first.name).first);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
