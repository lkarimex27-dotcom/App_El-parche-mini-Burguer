import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parche_mini_burger/screens/login_screen.dart';
import 'package:parche_mini_burger/screens/splash_screen.dart';
import 'package:parche_mini_burger/state/app_scope.dart';

void main() {
  // El botón "Comenzar" late para siempre: pumpAndSettle nunca terminaría,
  // así que toda la espera va por tramos con pump(Duration).
  Future<void> correrAnimacion(WidgetTester tester) async {
    await tester.pump(); // arranca la precarga
    await tester.pump(const Duration(seconds: 4)); // deja pasar el timeout
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 500));
    }
  }

  testWidgets('el splash termina mostrando el botón Comenzar', (tester) async {
    await tester.pumpWidget(
      const AppScope(child: MaterialApp(home: SplashScreen())),
    );
    await correrAnimacion(tester);

    expect(find.text('Comenzar'), findsOneWidget);
    expect(find.textContaining('desde'), findsOneWidget);
  });

  testWidgets('tocar Comenzar lleva al login', (tester) async {
    await tester.pumpWidget(
      const AppScope(child: MaterialApp(home: SplashScreen())),
    );
    await correrAnimacion(tester);

    await tester.tap(find.text('Comenzar'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(LoginScreen), findsOneWidget);
    // Y el splash quedó fuera: sus controladores se soltaron.
    expect(find.byType(SplashScreen), findsNothing);
  });
}
