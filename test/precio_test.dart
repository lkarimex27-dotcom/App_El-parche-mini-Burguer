import 'package:flutter_test/flutter_test.dart';
import 'package:parche_mini_burger/models/precio.dart';
import 'package:parche_mini_burger/models/product.dart';

void main() {
  test('el precio lleva punto de miles', () {
    expect(formatoPesos(2600), r'$2.600');
    expect(formatoPesos(12500), r'$12.500');
    expect(formatoPesos(150000), r'$150.000');
    expect(formatoPesos(1250000), r'$1.250.000');
  });

  test('los precios cortos y el cero no llevan punto', () {
    expect(formatoPesos(0), r'$0');
    expect(formatoPesos(900), r'$900');
  });

  test('un descuento se ve como negativo, no como basura', () {
    expect(formatoPesos(-4000), r'-$4.000');
  });

  test('las bebidas son exactamente las del menú del negocio', () {
    // El menú manda: si alguien agrega un sabor que no existe, esto falla.
    final sabores = {
      for (final b in bebidas)
        b.id: b.variantes
            .where((v) => v.titulo == 'Sabor')
            .expand((v) => v.opciones.map((o) => o.nombre))
            .toList(),
    };

    expect(sabores['gaseosa_pequena'], ['Manzana', 'Coca-Cola']);
    expect(sabores['mr_tea'], ['Limón']);
    expect(sabores['gaseosa_flexi_400'], ['Coca-Cola', 'Manzana', 'Cuatro']);
    expect(sabores['gaseosa_postobon_1_5'],
        ['Manzana', 'Uva', 'Pepsi', 'Colombiana', 'Naranjada']);
    expect(sabores['gaseosa_2_litros'],
        ['Manzana', 'Colombiana', 'Pepsi', 'Cuatro']);
    // Estas se piden tal cual, sin escoger sabor.
    for (final id in ['coca_cola_1_5', 'hit_litro', 'econolitro_postobon',
        'econolitro_coca_cola']) {
      expect(sabores[id], isEmpty, reason: id);
    }
  });

  test('un tamaño con varios sabores es una sola fila con selector', () {
    final postobon =
        bebidasPorMarca().firstWhere((m) => m.nombre == 'Postobón');

    // El 1.5 L de Postobón tiene 4 sabores, pero es una sola presentación.
    final litro1_5 = postobon.presentaciones.where((p) => p.tamano == '1.5 L');
    expect(litro1_5.length, 1);
    expect(litro1_5.single.pideSabor, isTrue);
    expect(litro1_5.single.sabores,
        ['Manzana', 'Uva', 'Colombiana', 'Naranjada']);

    // El econolitro no tiene nada que escoger.
    final econo =
        postobon.presentaciones.firstWhere((p) => p.tamano == 'Econolitro');
    expect(econo.pideSabor, isFalse);
  });
}
