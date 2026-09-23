import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parche_mini_burger/models/product.dart';
import 'package:parche_mini_burger/screens/home_screen.dart';
import 'package:parche_mini_burger/screens/menu_screen.dart';
import 'package:parche_mini_burger/state/app_scope.dart';

void main() {
  // Pantalla grande para que todo el ListView se construya de una.
  setUp(() {
    final view = TestWidgetsFlutterBinding.ensureInitialized().platformDispatcher.views.first;
    view.physicalSize = const Size(1000, 6000);
    view.devicePixelRatio = 1.0;
  });

  tearDown(() {
    final view = TestWidgetsFlutterBinding.ensureInitialized().platformDispatcher.views.first;
    view.resetPhysicalSize();
    view.resetDevicePixelRatio();
  });

  Widget envolver(Widget child) =>
      AppScope(child: MaterialApp(home: Scaffold(body: child)));

  testWidgets('Inicio muestra los productos de la categoría que se toca',
      (tester) async {
    String? categoriaPedida;

    await tester.pumpWidget(envolver(HomeScreen(
      onVerMenu: () {},
      onVerCategoria: (c) => categoriaPedida = c,
    )));
    await tester.pump();

    // Arranca en Hamburguesas: se ve una que NO es destacada,
    // o sea que viene de la grilla de la categoría y no del carrusel.
    expect(find.text('Hamburguesa Triple'), findsOneWidget);
    expect(find.text('Gran Perra'), findsNothing);

    // El cliente toca la categoría Perras en el selector de arriba.
    await tester.tap(find.text('Perras'));
    await tester.pumpAndSettle();

    expect(find.text('Gran Perra'), findsOneWidget);
    expect(find.text('Hamburguesa Triple'), findsNothing);

    // Y "Ver en el menú" avisa con la categoría seleccionada.
    await tester.tap(find.text('Ver en el menú'));
    expect(categoriaPedida, 'Perras');
  });

  testWidgets('Inicio muestra la información del negocio', (tester) async {
    await tester.pumpWidget(envolver(HomeScreen(onVerMenu: () {})));
    await tester.pump();

    expect(find.text('Sobre nosotros'), findsOneWidget);
    expect(find.text('Dónde y cómo pedir'), findsOneWidget);
    expect(find.textContaining('Cra 45'), findsOneWidget);
    expect(find.textContaining('Nequi'), findsOneWidget);
  });

  testWidgets('Inicio ya no tiene la tarjeta de saludo', (tester) async {
    await tester.pumpWidget(envolver(HomeScreen(onVerMenu: () {})));
    await tester.pump();

    expect(find.textContaining('Hola,'), findsNothing);
  });

  testWidgets('Menú abre filtrado por la categoría que pidió el Inicio',
      (tester) async {
    await tester.pumpWidget(envolver(const MenuScreen(categoriaInicial: 'Perras')));
    await tester.pump();

    expect(find.text('Perra Pequeña'), findsOneWidget);
    expect(find.text('Hamburguesa Triple'), findsNothing);
    expect(find.text('${productosDeCategoria('Perras').length} productos'),
        findsOneWidget);

    // Y con "Todos" vuelve el catálogo completo.
    await tester.tap(find.text('Todos'));
    await tester.pumpAndSettle();

    expect(find.text('${productosDelMenu.length} productos'), findsOneWidget);
  });

  test('cada producto del menú pertenece a una categoría existente', () {
    final nombres = kCategorias.map((c) => c.nombre).toSet();
    for (final p in productosDelMenu) {
      expect(nombres, contains(p.category), reason: '${p.name} sin categoría válida');
    }
  });

  test('las bebidas no son una categoría del menú', () {
    expect(kCategorias.map((c) => c.nombre), isNot(contains(kCategoriaBebidas)));
    expect(bebidas, isNotEmpty);
    expect(productosDelMenu.any((p) => p.category == kCategoriaBebidas), isFalse);
  });

  test('ninguna categoría queda vacía', () {
    for (final c in kCategorias) {
      expect(productosDeCategoria(c.nombre), isNotEmpty, reason: c.nombre);
    }
  });

  test('la foto de cada producto existe en assets', () {
    // Los nombres de archivo llevan espacios ("arepa rellena.jpg"), así que
    // un dedazo no se nota hasta que la tarjeta sale en blanco.
    for (final p in demoProducts) {
      expect(File(p.imageAsset).existsSync(), isTrue,
          reason: '${p.name} apunta a ${p.imageAsset} y no está');
    }
  });

  test('ningún producto se queda sin foto, ni siquiera las bebidas', () {
    for (final p in demoProducts) {
      expect(p.imageAsset, isNotEmpty, reason: '${p.name} sin foto');
    }
  });

  test('dos productos nunca comparten la misma foto', () {
    // Si se repiten, el menú se ve como si fuera el mismo plato varias veces.
    final vistas = <String, String>{};
    for (final p in demoProducts) {
      expect(vistas.containsKey(p.imageAsset), isFalse,
          reason: '${p.name} repite la foto de ${vistas[p.imageAsset]}');
      vistas[p.imageAsset] = p.name;
    }
  });

  test('la portada de la categoría usa una foto real si la hay', () {
    for (final c in kCategorias) {
      final portada = portadaDeCategoria(c.nombre);
      expect(portada, isNotNull, reason: c.nombre);

      final conFoto =
          productosDeCategoria(c.nombre).where((p) => p.imageAsset.isNotEmpty);
      if (conFoto.isNotEmpty) {
        expect(portada!.imageAsset, isNotEmpty,
            reason: '${c.nombre} tiene fotos pero la portada salió sin foto');
      }
    }
  });
}
