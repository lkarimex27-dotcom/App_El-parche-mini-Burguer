import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parche_mini_burger/models/product.dart';
import 'package:parche_mini_burger/screens/product_detail_screen.dart';
import 'package:parche_mini_burger/state/app_scope.dart';
import 'package:parche_mini_burger/widgets/app_image.dart';

void main() {
  test('cada sabor de 2 L tiene la foto de su propia botella', () {
    // Sin esto, escoger "Pepsi" mostraría la botella de Manzana.
    for (final sabor in ['Manzana', 'Colombiana', 'Pepsi', 'Cuatro']) {
      final foto = fotoDeBebida(tamano: '2 L', sabor: sabor);
      expect(foto, isNotNull, reason: '2 L $sabor sin foto');
      expect(File(foto!).existsSync(), isTrue, reason: foto);
    }
  });

  test('la presentación cae en la foto del producto si el sabor no tiene', () {
    final postobon =
        bebidasPorMarca().firstWhere((m) => m.nombre == 'Postobón');
    final litro1_5 =
        postobon.presentaciones.firstWhere((p) => p.tamano == '1.5 L');

    // Todavía no hay foto de "1.5 L|Uva", así que usa la del producto.
    expect(fotoDeBebida(tamano: '1.5 L', sabor: 'Uva'), isNull);
    expect(litro1_5.fotoDe('Uva'), litro1_5.producto.imageAsset);
  });

  testWidgets('la botella se muestra entera, no recortada', (tester) async {
    final bebida = bebidas.firstWhere((b) => b.id == 'gaseosa_2_litros');

    await tester.pumpWidget(AppScope(
      child: MaterialApp(home: ProductDetailScreen(product: bebida)),
    ));
    await tester.pumpAndSettle();

    // Una botella de 2 L es tres veces más alta que ancha: recortada solo
    // se vería el centro de la etiqueta.
    final foto = tester.widget<AppImage>(find.byType(AppImage).first);
    expect(foto.enVitrina, isTrue);
  });

  testWidgets('la comida sí llena el recuadro', (tester) async {
    final hamburguesa = productosDelMenu.first;

    await tester.pumpWidget(AppScope(
      child: MaterialApp(home: ProductDetailScreen(product: hamburguesa)),
    ));
    await tester.pumpAndSettle();

    final foto = tester.widget<AppImage>(find.byType(AppImage).first);
    expect(foto.enVitrina, isFalse);
  });
}
