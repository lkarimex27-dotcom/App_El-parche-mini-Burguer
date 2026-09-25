import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parche_mini_burger/admin/data/admin_repository.dart';
import 'package:parche_mini_burger/admin/screens/admin_nav_screen.dart';
import 'package:parche_mini_burger/admin/screens/admin_profile_screen.dart';
import 'package:parche_mini_burger/admin/screens/mas_screen.dart';
import 'package:parche_mini_burger/admin/widgets/metric_card.dart';
import 'package:parche_mini_burger/models/rol.dart';
import 'package:parche_mini_burger/state/app_scope.dart';
import 'package:parche_mini_burger/state/user_model.dart';

void main() {
  Widget panel() => AppScope(
        adminInicial: AdminRepository(),
        usuarioInicial: UserModel(nombre: 'Ana Gómez', rol: Rol.administrador),
        child: const MaterialApp(home: AdminNavScreen()),
      );

  testWidgets('el admin llega a su perfil desde el círculo del encabezado',
      (tester) async {
    await tester.pumpWidget(panel());
    await tester.pump();

    // El círculo lleva las iniciales de quien entró.
    expect(find.text('AG'), findsOneWidget);
    await tester.tap(find.text('AG'));
    await tester.pumpAndSettle();

    expect(find.byType(AdminProfileScreen), findsOneWidget);
  });

  testWidgets('los módulos de nombre largo no desbordan en un celular angosto',
      (tester) async {
    final vista = TestWidgetsFlutterBinding.ensureInitialized()
        .platformDispatcher
        .views
        .first;
    vista.physicalSize = const Size(300, 1800);
    vista.devicePixelRatio = 1.0;
    addTearDown(() {
      vista.resetPhysicalSize();
      vista.resetDevicePixelRatio();
    });

    await tester.pumpWidget(AppScope(
      adminInicial: AdminRepository(),
      usuarioInicial: UserModel(nombre: 'Ana', rol: Rol.administrador),
      child: MaterialApp(
        home: Scaffold(
          body: MasScreen(rol: Rol.administrador, onAbrirModulo: (_) {}),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    // "Proveedores", "Fichas técnicas", "Devoluciones" y "Roles y permisos"
    // ocupan dos líneas y desbordaban la celda.
    expect(tester.takeException(), isNull);
  });

  testWidgets('las cifras del dashboard no gritan', (tester) async {
    await tester.pumpWidget(panel());
    await tester.pump();

    final tarjetas = tester.widgetList<MetricCard>(find.byType(MetricCard));
    expect(tarjetas, isNotEmpty);

    // Cuatro cifras enormes juntas en la primera pantalla cansan más de lo
    // que informan: se busca el Text de cada valor y se mira su tamaño.
    for (final tarjeta in tarjetas) {
      final numero = tester.widget<Text>(
        find.descendant(
          of: find.byWidgetPredicate(
              (w) => w is MetricCard && w.etiqueta == tarjeta.etiqueta),
          matching: find.text(tarjeta.valor),
        ),
      );
      expect(numero.style!.fontSize, lessThan(20),
          reason: '${tarjeta.etiqueta} sale en '
              '${numero.style!.fontSize} puntos');
    }
  });
}
