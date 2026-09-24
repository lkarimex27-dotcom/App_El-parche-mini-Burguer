import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parche_mini_burger/admin/screens/dashboard_screen.dart';
import 'package:parche_mini_burger/admin/screens/mas_screen.dart';
import 'package:parche_mini_burger/models/rol.dart';
import 'package:parche_mini_burger/state/app_scope.dart';

void main() {
  testWidgets('Dashboard muestra métricas relevantes para la empresa',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AppScope(
          child: DashboardScreen(
            onAbrirModulo: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Ticket promedio'), findsOneWidget);
    expect(find.text('Meta del día'), findsOneWidget);
  });

  testWidgets('Más muestra módulos en una grilla organizada', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AppScope(
          child: MasScreen(
            rol: Rol.administrador,
            onAbrirModulo: (_) {},
          ),
        ),
      ),
    );

    expect(find.byType(GridView), findsWidgets);
  });
}
