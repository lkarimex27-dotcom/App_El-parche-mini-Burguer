import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parche_mini_burger/admin/screens/dashboard_screen.dart';
import 'package:parche_mini_burger/admin/screens/mas_screen.dart';
import 'package:parche_mini_burger/admin/widgets/metric_card.dart';
import 'package:parche_mini_burger/models/rol.dart';
import 'package:parche_mini_burger/state/app_scope.dart';

/// Busca una tarjeta de indicador por su etiqueta, sin depender de cómo la
/// escriba en pantalla (MetricCard la pone en mayúsculas).
Finder _metrica(String etiqueta) => find.byWidgetPredicate(
      (w) => w is MetricCard && w.etiqueta == etiqueta,
      description: 'MetricCard "$etiqueta"',
    );

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

    expect(_metrica('Ticket promedio'), findsOneWidget);
    expect(_metrica('Meta del día'), findsOneWidget);
    expect(_metrica('Ventas hoy'), findsOneWidget);
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
