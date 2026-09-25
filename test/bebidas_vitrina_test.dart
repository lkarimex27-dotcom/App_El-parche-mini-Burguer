import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parche_mini_burger/models/product.dart';
import 'package:parche_mini_burger/screens/product_detail_screen.dart';
import 'package:parche_mini_burger/state/app_scope.dart';
import 'package:parche_mini_burger/widgets/app_image.dart';

void main() {
  test('cada sabor tiene la foto de su propia botella', () {
    // Sin esto, escoger "Pepsi" mostraría la botella de Manzana.
    const porTamano = {
      '2 L': ['Manzana', 'Colombiana', 'Pepsi', 'Cuatro'],
      '1.5 L': ['Manzana', 'Uva', 'Pepsi', 'Colombiana', 'Naranjada'],
    };

    porTamano.forEach((tamano, sabores) {
      for (final sabor in sabores) {
        final foto = fotoDeBebida(tamano: tamano, sabor: sabor);
        expect(foto, isNotNull, reason: '$tamano $sabor sin foto');
        expect(File(foto!).existsSync(), isTrue, reason: foto);
      }
    });
  });

  test('el 1.5 L cambia de botella según el sabor', () {
    final postobon =
        bebidasPorMarca().firstWhere((m) => m.nombre == 'Postobón');
    final litro1_5 =
        postobon.presentaciones.firstWhere((p) => p.tamano == '1.5 L');

    // Cada sabor trae su foto, y ninguna se repite con otra.
    final vistas = <String>{};
    for (final sabor in litro1_5.sabores) {
      final foto = litro1_5.fotoDe(sabor);
      expect(foto, isNot(litro1_5.producto.imageAsset), reason: sabor);
      expect(vistas.add(foto), isTrue, reason: '$sabor repite $foto');
    }
  });

  test('ninguna fila muestra la botella de otra marca', () {
    // El 400 ml de Postobón sale del mismo producto que el de Coca-Cola.
    // Si la foto cayera en la del producto, Postobón mostraría una
    // Coca-Cola. Esta prueba es la que cazó ese fallo.
    final deOtraMarca = <String, String>{
      'assets/images/coca cola 400 ml.jpg': 'Coca-Cola',
      'assets/images/coca cola 1.5.jpg': 'Coca-Cola',
      'assets/images/coca cola pequeña.jpg': 'Coca-Cola',
      'assets/images/manzana pequeña.jpg': 'Postobón',
      'assets/images/pepsi 1.5.jpg': 'Pepsi',
    };

    for (final marca in bebidasPorMarca()) {
      for (final p in marca.presentaciones) {
        final sabores = p.sabores.isEmpty ? <String?>[null] : p.sabores;
        for (final sabor in sabores) {
          final foto = p.fotoDe(sabor);
          final duena = deOtraMarca[foto];
          expect(duena == null || duena == marca.nombre, isTrue,
              reason: '${marca.nombre} ${p.tamano} '
                  '${sabor ?? ""} muestra una foto de $duena');
        }
      }
    }
  });

  test('un sabor sin foto propia cae en la de su marca', () {
    final postobon =
        bebidasPorMarca().firstWhere((m) => m.nombre == 'Postobón');
    final flexi =
        postobon.presentaciones.firstWhere((p) => p.tamano == '400 ml');

    // Todavía no hay foto de "400 ml|Cuatro": usa la de Postobón, no la
    // del producto, que es una Coca-Cola.
    expect(fotoDeBebida(tamano: '400 ml', sabor: 'Cuatro'), isNull);
    expect(flexi.fotoDe('Cuatro'), fotoDeMarca('Postobón'));
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
