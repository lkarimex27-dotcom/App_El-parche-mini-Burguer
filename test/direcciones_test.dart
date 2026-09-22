import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parche_mini_burger/screens/addresses_screen.dart';
import 'package:parche_mini_burger/state/app_scope.dart';
import 'package:parche_mini_burger/state/user_model.dart';

void main() {
  testWidgets('guardar una dirección nueva no debe romper', (tester) async {
    final usuario = UserModel();

    await tester.pumpWidget(AppScope(
      usuarioInicial: usuario,
      child: const MaterialApp(home: AddressesScreen()),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Agregar'));
    await tester.pumpAndSettle();

    final campos = find.byType(TextField);
    await tester.enterText(campos.at(0), 'Oficina');
    await tester.enterText(campos.at(1), 'Calle 10 #5-20');
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(usuario.direcciones.any((d) => d.alias == 'Oficina'), isTrue);
    expect(find.text('Oficina'), findsOneWidget);
  });
}
