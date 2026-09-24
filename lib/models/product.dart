import 'package:flutter/material.dart';

/// Una categoría del menú. El orden de [kCategorias] es el que se ve
/// en el selector de categorías de Inicio y Menú.
class Categoria {
  final String nombre;
  final IconData icono;

  const Categoria(this.nombre, this.icono);
}

const List<Categoria> kCategorias = [
  Categoria('Hamburguesas', Icons.lunch_dining),
  Categoria('Arepas', Icons.breakfast_dining),
  Categoria('Chuzos', Icons.outdoor_grill),
  Categoria('Patacones', Icons.ramen_dining),
  Categoria('Perras', Icons.local_fire_department),
  Categoria('Perros', Icons.dinner_dining),
  Categoria('Salchipapas', Icons.fastfood),
];

/// Las bebidas NO son una categoría del menú: se escogen desde el carrito.
const String kCategoriaBebidas = 'Bebidas';

/// Una opción dentro de una variante. [precio] es el precio TOTAL del
/// producto si se elige esta opción, no un recargo: así los precios del
/// menú quedan tal cual, sin sumas intermedias.
class OpcionVariante {
  final String nombre;
  final int precio;

  const OpcionVariante(this.nombre, this.precio);
}

/// Un grupo de opciones del que hay que escoger una: "Queso o tocineta",
/// "Pollo o cerdo", "Sabor"…
class Variante {
  final String titulo;
  final List<OpcionVariante> opciones;

  const Variante(this.titulo, this.opciones);

  OpcionVariante get porDefecto => opciones.first;
}

class Product {
  final String id;
  final String name;

  /// Nombre de la categoría, debe coincidir con uno de [kCategorias].
  final String category;

  /// Foto propia del negocio. Se usa primero si el archivo existe.
  final String imageAsset;

  /// Foto de respaldo mientras no exista [imageAsset]. Al poner la foto
  /// real en assets/images/ esta deja de usarse sola.
  final String imageUrl;

  /// Precio del menú. Si el producto tiene variantes con precio distinto,
  /// manda el de la opción elegida (ver [precioCon]).
  final int price;

  final String description;

  /// Lo que lleva, tal como está en el menú.
  final List<String> ingredientes;

  /// Opciones a escoger antes de agregar al carrito.
  final List<Variante> variantes;

  /// Los productos que dicen "salsas al gusto" dejan escoger salsas.
  final bool permiteSalsas;

  /// Las bebidas no llevan adiciones.
  final bool permiteAdiciones;

  /// Aparece en el carrusel "Destacadas" del Inicio.
  final bool destacado;

  /// Solo en bebidas. [marca] es la de la botella cuando el producto es de
  /// una sola ("Coca-Cola", "Hit"); si ofrece sabores de varias marcas se
  /// deja vacía y la marca sale del sabor elegido (ver [marcaDeSabor]).
  /// [tamano] es cómo se llama la presentación: "Pequeña", "1.5 L"…
  final String marca;
  final String tamano;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.imageAsset,
    required this.imageUrl,
    required this.price,
    this.description = '',
    this.ingredientes = const [],
    this.variantes = const [],
    this.permiteSalsas = true,
    this.permiteAdiciones = true,
    this.destacado = false,
    this.marca = '',
    this.tamano = '',
  });

  bool get tieneVariantes => variantes.isNotEmpty;

  /// Precio según las opciones elegidas (mapa título de variante → opción).
  int precioCon(Map<String, String> opciones) {
    for (final v in variantes) {
      final elegida = opciones[v.titulo];
      for (final o in v.opciones) {
        if (o.nombre == elegida) return o.precio;
      }
    }
    return price;
  }

  /// Lo que queda seleccionado al abrir la ficha.
  Map<String, String> get opcionesPorDefecto => {
        for (final v in variantes) v.titulo: v.porDefecto.nombre,
      };
}

// Las fotos del negocio están en assets/images/. Los productos que todavía
// no tienen la suya usan una de referencia en assets/images/menu/<id>.jpg,
// que se reemplaza borrando el archivo y poniendo la real con el mismo
// nombre. Ninguna se repite: cada producto tiene la suya.

const String _salsasAlGusto = 'Salsas al gusto';
const String _ensalada = 'Ensalada: repollo o lechuga';

/// Catálogo del negocio. Cuando conectes la API, esta lista es lo único
/// que hay que reemplazar: las pantallas ya leen de aquí.
const List<Product> demoProducts = [
  // ═══════════════════════ HAMBURGUESAS ═══════════════════════
  Product(
    id: 'mini_burguer',
    name: 'Mini Burguer',
    category: 'Hamburguesas',
    imageAsset: 'assets/images/hamburguesa mini.jpg',
    imageUrl: '',
    price: 12500,
    description:
        'Pequeña de tamaño, grande de sabor: carne a la plancha, ensalada fresca y ripio de papa bien crocante. La que todo el mundo pide.',
    ingredientes: ['Pan', _ensalada, 'Ripio de papa', 'Carne', _salsasAlGusto],
    variantes: [
      Variante('Queso o tocineta', [
        OpcionVariante('Sencilla', 12500),
        OpcionVariante('Con queso', 13000),
        OpcionVariante('Con tocineta', 13000),
      ]),
    ],
    destacado: true,
  ),
  Product(
    id: 'hamburguesa_sencilla',
    name: 'Hamburguesa Sencilla',
    category: 'Hamburguesas',
    imageAsset: 'assets/images/menu/hamburguesa_sencilla.jpg',
    imageUrl: '',
    price: 14500,
    description:
        'La clásica sin vueltas: carne jugosa recién hecha, ensalada fresquita y ripio de papa que cruje en cada mordisco.',
    ingredientes: ['Pan', _ensalada, 'Ripio de papa', 'Carne', _salsasAlGusto],
  ),
  Product(
    id: 'hamburguesa_tradicional_o',
    name: 'Hamburguesa Tradicional (queso o tocineta)',
    category: 'Hamburguesas',
    imageAsset: 'assets/images/tradicional.jpg',
    imageUrl: '',
    price: 15500,
    description:
        'Nuestra tradicional, como más te guste: con queso derretido o con tocineta crocante. Tú decides cuál.',
    ingredientes: [
      'Pan',
      _ensalada,
      'Ripio de papa',
      'Carne',
      'Queso o tocineta',
      _salsasAlGusto,
    ],
    variantes: [
      Variante('Elige queso o tocineta', [
        OpcionVariante('Queso', 15500),
        OpcionVariante('Tocineta', 15500),
      ]),
    ],
    destacado: true,
  ),
  Product(
    id: 'hamburguesa_tradicional_y',
    name: 'Hamburguesa Tradicional (queso y tocineta)',
    category: 'Hamburguesas',
    imageAsset: 'assets/images/burguer tradicional.jpg',
    imageUrl: '',
    price: 16000,
    description:
        '¿Para qué escoger? Queso derretido y tocineta crocante juntos sobre la carne. La consentida de la casa.',
    ingredientes: [
      'Pan',
      _ensalada,
      'Ripio de papa',
      'Carne',
      'Queso',
      'Tocineta',
      _salsasAlGusto,
    ],
  ),
  Product(
    id: 'hamburguesa_doble',
    name: 'Hamburguesa Doble',
    category: 'Hamburguesas',
    imageAsset: 'assets/images/menu/hamburguesa_doble.jpg',
    imageUrl: '',
    price: 18500,
    description:
        'Doble de todo: dos carnes, doble queso derretido y doble tocineta. Para cuando el hambre viene en serio.',
    ingredientes: [
      'Pan',
      _ensalada,
      'Ripio de papa',
      '2 carnes',
      'Doble queso',
      'Doble tocineta',
      _salsasAlGusto,
    ],
    destacado: true,
  ),
  Product(
    id: 'hamburguesa_triple',
    name: 'Hamburguesa Triple',
    category: 'Hamburguesas',
    imageAsset: 'assets/images/burguer triple.jpg',
    imageUrl: '',
    price: 20500,
    description:
        'Tres carnes, triple queso y triple tocineta. Una torre que toca agarrar con las dos manos.',
    ingredientes: [
      'Pan',
      _ensalada,
      'Ripio de papa',
      'Triple carne',
      'Triple queso',
      'Triple tocineta',
      _salsasAlGusto,
    ],
  ),
  Product(
    id: 'hamburguesa_atun_queso',
    name: 'Hamburguesa de Atún y Queso',
    category: 'Hamburguesas',
    imageAsset: 'assets/images/menu/hamburguesa_atun_queso.jpg',
    imageUrl: '',
    price: 17500,
    description:
        'Atún con queso derretido, ensalada fresca y ripio de papa. Distinta a todas y más liviana.',
    ingredientes: [
      'Pan',
      _ensalada,
      'Ripio de papa',
      'Atún',
      'Queso',
      _salsasAlGusto,
    ],
  ),
  Product(
    id: 'hamburguesa_pollo',
    name: 'Hamburguesa de Pollo',
    category: 'Hamburguesas',
    imageAsset: 'assets/images/burguer de pollo.jpg',
    imageUrl: '',
    price: 17500,
    description:
        'Pechuga de pollo dorada con queso derretido y tocineta crocante. Suave por dentro, crocante por fuera.',
    ingredientes: [
      'Pan',
      _ensalada,
      'Ripio',
      'Carne de pollo',
      'Queso',
      'Tocineta',
    ],
  ),
  Product(
    id: 'hamburguesa_mixta',
    name: 'Hamburguesa Mixta',
    category: 'Hamburguesas',
    imageAsset: 'assets/images/menu/hamburguesa_mixta.jpg',
    imageUrl: '',
    price: 20000,
    description:
        'Lo mejor de los dos mundos en un solo pan: pechuga de pollo y carne de res juntas.',
    ingredientes: [
      'Pan',
      _ensalada,
      'Pechuga',
      'Carne de hamburguesa',
      'Queso',
      'Tocineta',
      'Ripio',
      _salsasAlGusto,
      'Cebolla al gusto',
    ],
  ),
  Product(
    id: 'hamburguesa_premium_casa',
    name: 'Hamburguesa Premium Casa',
    category: 'Hamburguesas',
    imageAsset: 'assets/images/menu/hamburguesa_premium_casa.jpg',
    imageUrl: '',
    price: 21000,
    description:
        'Nuestra premium: carne artesanal con huevo entero encima. La que uno pide cuando el día lo merece.',
    ingredientes: [
      'Pan',
      _ensalada,
      'Carne artesanal',
      'Queso',
      'Tocineta',
      'Huevo entero',
      'Ripio',
      _salsasAlGusto,
      'Cebolla al gusto',
    ],
    destacado: true,
  ),

  // ═══════════════════════════ AREPAS ═══════════════════════════
  Product(
    id: 'arepa_burger_sencilla',
    name: 'Arepa Burger Sencilla',
    category: 'Arepas',
    imageAsset: 'assets/images/menu/arepa_burger_sencilla.jpg',
    imageUrl: '',
    price: 14000,
    description:
        'Arepa tela calientica en vez de pan, con carne de hamburguesa, queso derretido y tocineta crocante.',
    ingredientes: [
      'Arepa tela',
      'Queso',
      'Carne de hamburguesa',
      'Tocineta',
      _salsasAlGusto,
    ],
  ),
  Product(
    id: 'arepa_burger_especial',
    name: 'Arepa Burger Especial',
    category: 'Arepas',
    imageAsset: 'assets/images/menu/arepa_burger_especial.jpg',
    imageUrl: '',
    price: 15000,
    description:
        'La arepa burger completa: carne, queso derretido, tocineta, ensalada fresca y ripio de papa.',
    ingredientes: [
      'Arepa',
      'Queso',
      'Carne de hamburguesa',
      'Tocineta',
      'Ensalada',
      'Ripio',
      _salsasAlGusto,
    ],
  ),
  Product(
    id: 'arepa_desmechada',
    name: 'Arepa Desmechada',
    category: 'Arepas',
    imageAsset: 'assets/images/menu/arepa_desmechada.jpg',
    imageUrl: '',
    price: 18000,
    description:
        'Arepa rellena de carne desmechada de pollo, res y cerdo. Bien servida y llena de sabor.',
    ingredientes: [
      'Arepa tela',
      'Queso',
      'Carne desmechada mixta: pollo, res y cerdo',
      'Tocineta',
      _salsasAlGusto,
    ],
    destacado: true,
  ),
  Product(
    id: 'arepa_gourmet',
    name: 'Arepa Gourmet',
    category: 'Arepas',
    imageAsset: 'assets/images/menu/arepa_gourmet.jpg',
    imageUrl: '',
    price: 18000,
    description:
        'Trocitos de pollo y cerdo, jamón y maicitos dulces sobre arepa tela. La más completa de todas.',
    ingredientes: [
      'Arepa tela',
      'Queso',
      'Trocitos de pollo',
      'Cerdo',
      'Jamón',
      'Maicitos',
      _salsasAlGusto,
    ],
  ),
  Product(
    id: 'arepa_mixta_rellena',
    name: 'Arepa Mixta (Rellena)',
    category: 'Arepas',
    imageAsset: 'assets/images/arepa rellena.jpg',
    imageUrl: '',
    price: 18000,
    description:
        'Arepa rellena hasta el borde de carne mixta desmechada. Se come con tenedor y sin pena.',
    ingredientes: [
      'Arepa rellena',
      'Carne mixta desmechada de pollo, res y cerdo',
      'Queso',
      'Tocineta',
      _salsasAlGusto,
    ],
  ),

  // ═══════════════════════════ CHUZOS ═══════════════════════════
  Product(
    id: 'chuzo_pollo_cerdo',
    name: 'Chuzo de Pollo o Cerdo',
    category: 'Chuzos',
    imageAsset: 'assets/images/chuzo de pollo.jpg',
    imageUrl: '',
    price: 19000,
    description:
        'Chuzo a la parrilla de pollo o de cerdo, con papas a la francesa, ensalada y arepa con queso. Plato completo.',
    ingredientes: [
      'Ensalada',
      'Porción de papas a la francesa',
      'Arepa con queso',
      _salsasAlGusto,
    ],
    variantes: [
      Variante('Elige tu opción', [
        OpcionVariante('Pollo', 19000),
        OpcionVariante('Cerdo', 19000),
      ]),
    ],
    destacado: true,
  ),

  // ══════════════════════════ PATACONES ═════════════════════════
  Product(
    id: 'patacon_mixto',
    name: 'Patacón Mixto',
    category: 'Patacones',
    imageAsset: 'assets/images/patacon.jpg',
    imageUrl: '',
    price: 18000,
    description:
        'Patacón crocante coronado con pollo, cerdo y res, más tocineta y queso derretido encima.',
    ingredientes: [
      'Pollo',
      'Cerdo',
      'Res',
      'Tocineta',
      'Queso',
      _salsasAlGusto,
    ],
  ),
  Product(
    id: 'patacon_ranchero',
    name: 'Patacón Ranchero',
    category: 'Patacones',
    imageAsset: 'assets/images/patacon ranchero.jpg',
    imageUrl: '',
    price: 18000,
    description:
        'Patacón crocante con pollo, cerdo, res y salchicha ranchera. Bien servido y bien sabroso.',
    ingredientes: [
      'Pollo',
      'Cerdo',
      'Res',
      'Salchicha ranchera',
      'Queso',
      _salsasAlGusto,
    ],
  ),

  // ═══════════════════════════ PERRAS ═══════════════════════════
  Product(
    id: 'perra_pequena',
    name: 'Perra Pequeña',
    category: 'Perras',
    imageAsset: 'assets/images/perra.jpg',
    imageUrl: '',
    price: 14500,
    description:
        'La perra de entrada: queso derretido, tocineta, ensalada fresca y ripio de papa crocante.',
    ingredientes: [
      'Pan',
      'Queso',
      'Tocineta',
      'Ensalada',
      'Ripio',
      _salsasAlGusto,
    ],
  ),
  Product(
    id: 'gran_perra',
    name: 'Gran Perra',
    category: 'Perras',
    imageAsset: 'assets/images/menu/gran_perra.jpg',
    imageUrl: '',
    price: 15500,
    description:
        'Más grande y con todo encima: queso derretido, tocineta crocante, ensalada y ripio de papa.',
    ingredientes: [
      'Pan',
      'Queso',
      'Tocineta',
      'Ensalada',
      'Ripio',
      _salsasAlGusto,
    ],
  ),
  Product(
    id: 'super_perra',
    name: 'Súper Perra',
    category: 'Perras',
    imageAsset: 'assets/images/menu/super_perra.jpg',
    imageUrl: '',
    price: 17500,
    description:
        'La más cargada de la casa: doble tocineta crocante sobre queso derretido. Para los que no se miden.',
    ingredientes: [
      'Pan',
      'Queso',
      'Doble tocineta',
      'Ensalada',
      'Ripio',
      _salsasAlGusto,
    ],
    destacado: true,
  ),

  // ═══════════════════════════ PERROS ═══════════════════════════
  Product(
    id: 'mini_perrito_y',
    name: 'Mini Perrito (queso y tocineta)',
    category: 'Perros',
    imageAsset: 'assets/images/perro.jpg',
    imageUrl: '',
    price: 13000,
    description:
        'El mini con todo: queso derretido y tocineta crocante. El tamaño perfecto para acompañar.',
    ingredientes: [
      'Pan para perro',
      'Salchicha',
      'Queso',
      'Ensalada',
      'Tocineta',
      _salsasAlGusto,
    ],
  ),
  Product(
    id: 'mini_perrito_o',
    name: 'Mini Perrito (queso o tocineta)',
    category: 'Perros',
    imageAsset: 'assets/images/menu/mini_perrito_o.jpg',
    imageUrl: '',
    price: 12500,
    description:
        'El mini como lo prefieras: con queso derretido o con tocineta crocante, y las salsas que quieras.',
    variantes: [
      Variante('Elige queso o tocineta', [
        OpcionVariante('Queso', 12500),
        OpcionVariante('Tocineta', 12500),
      ]),
    ],
  ),
  Product(
    id: 'perro_mediano_y',
    name: 'Perro Mediano (queso y tocineta)',
    category: 'Perros',
    imageAsset: 'assets/images/menu/perro_mediano_y.jpg',
    imageUrl: '',
    price: 14500,
    description:
        'Tamaño mediano con queso derretido y tocineta crocante, más todas las salsas que le quieras poner.',
  ),
  Product(
    id: 'perro_mediano_o',
    name: 'Perro Mediano (queso o tocineta)',
    category: 'Perros',
    imageAsset: 'assets/images/menu/perro_mediano_o.jpg',
    imageUrl: '',
    price: 14000,
    description:
        'Mediano y a tu gusto: con queso derretido o con tocineta crocante, y salsas al gusto.',
    variantes: [
      Variante('Elige queso o tocineta', [
        OpcionVariante('Queso', 14000),
        OpcionVariante('Tocineta', 14000),
      ]),
    ],
  ),
  Product(
    id: 'gran_perro_y',
    name: 'Gran Perro (queso y tocineta)',
    category: 'Perros',
    imageAsset: 'assets/images/menu/gran_perro_y.jpg',
    imageUrl: '',
    price: 15500,
    description:
        'Grande de verdad, con queso derretido y tocineta crocante. De los que llenan.',
    destacado: true,
  ),
  Product(
    id: 'gran_perro_o',
    name: 'Gran Perro (queso o tocineta)',
    category: 'Perros',
    imageAsset: 'assets/images/menu/gran_perro_o.jpg',
    imageUrl: '',
    price: 15000,
    description:
        'El grande como te guste: con queso derretido o con tocineta, y las salsas que pidas.',
    variantes: [
      Variante('Elige queso o tocineta', [
        OpcionVariante('Queso', 15000),
        OpcionVariante('Tocineta', 15000),
      ]),
    ],
  ),
  Product(
    id: 'super_perro_y',
    name: 'Súper Perro (queso y tocineta)',
    category: 'Perros',
    imageAsset: 'assets/images/menu/super_perro_y.jpg',
    imageUrl: '',
    price: 17500,
    description:
        'El más grande de todos, con queso derretido y tocineta crocante. Para el hambre grande.',
  ),

  // ════════════════════════ SALCHIPAPAS ═════════════════════════
  Product(
    id: 'salchipapa_mega_tradicional',
    name: 'Mega Tradicional',
    category: 'Salchipapas',
    imageAsset: 'assets/images/megatradicional.jpg',
    imageUrl: '',
    price: 20000,
    description:
        'Papas crocantes con carne de hamburguesa picada y nuggets de pollo. Para compartir… o no.',
    ingredientes: [
      'Papas',
      'Salchicha',
      '3 huevos de codorniz',
      '1 nugget de pollo',
      'Queso',
      'Tocineta',
      '1 carne de hamburguesa picada',
    ],
    destacado: true,
  ),
  Product(
    id: 'salchipapa_especial',
    name: 'Especial',
    category: 'Salchipapas',
    imageAsset: 'assets/images/salchipapas especial.png',
    imageUrl: '',
    price: 16000,
    description:
        'Papas doradas con queso derretido, tocineta crocante y nuggets de pollo por encima.',
    ingredientes: [
      'Papas',
      'Salchicha',
      '2 huevos de codorniz',
      '1 nugget de pollo',
      'Queso',
      'Tocineta',
    ],
  ),
  Product(
    id: 'salchipapa_sencilla',
    name: 'Sencilla',
    category: 'Salchipapas',
    imageAsset: 'assets/images/menu/salchipapa_sencilla.jpg',
    imageUrl: '',
    price: 13000,
    description:
        'Papas crocantes con salchicha, huevitos de codorniz y nuggets de pollo. La de toda la vida.',
    ingredientes: [
      'Papas',
      'Salchicha',
      '1 huevo de codorniz',
      '1 nugget de pollo',
    ],
  ),
  Product(
    id: 'salchipapa_especial_gourmet',
    name: 'Especial Gourmet',
    category: 'Salchipapas',
    imageAsset: 'assets/images/especial gourmet.png',
    imageUrl: '',
    price: 20500,
    description:
        'La gourmet en tamaño personal, con queso derretido o con tocineta crocante. Tú eliges.',
    ingredientes: [
      'Papas',
      'Salchicha',
      '2 huevos de codorniz',
      'Trocitos de pollo',
      'Cerdo',
      'Jamón',
      'Maicitos',
      'Queso o tocineta',
    ],
    variantes: [
      Variante('Elige queso o tocineta', [
        OpcionVariante('Queso', 20500),
        OpcionVariante('Tocineta', 20500),
      ]),
    ],
  ),
  Product(
    id: 'salchipapa_mega_gourmet',
    name: 'Mega Gourmet',
    category: 'Salchipapas',
    imageAsset: 'assets/images/menu/salchipapa_mega_gourmet.jpg',
    imageUrl: '',
    price: 23000,
    description:
        'La gourmet en tamaño grande, con queso derretido o con tocineta. Alcanza para dos.',
    ingredientes: [
      'Papas',
      'Salchicha',
      '3 huevos de codorniz',
      'Trocitos de pollo',
      'Cerdo',
      'Jamón',
      'Maicitos',
      'Queso o tocineta',
    ],
    variantes: [
      Variante('Elige queso o tocineta', [
        OpcionVariante('Queso', 23000),
        OpcionVariante('Tocineta', 23000),
      ]),
    ],
  ),
  Product(
    id: 'salchipapa_mega_gourmet_qy',
    name: 'Mega Gourmet (queso y tocineta)',
    category: 'Salchipapas',
    imageAsset: 'assets/images/menu/salchipapa_mega_gourmet_qy.jpg',
    imageUrl: '',
    price: 27000,
    description:
        'La mega gourmet sin tener que escoger: queso derretido y tocineta crocante al tiempo.',
    ingredientes: [
      'Papas',
      'Salchicha',
      '3 huevos de codorniz',
      'Pollo',
      'Cerdo',
      'Jamón',
      'Maicitos',
      'Queso',
      'Tocineta',
    ],
  ),
  Product(
    id: 'salchipapa_super_gourmet',
    name: 'Súper Gourmet',
    category: 'Salchipapas',
    imageAsset: 'assets/images/super gourmet.jpg',
    imageUrl: '',
    price: 33000,
    description:
        'La más grande de la carta: toda la mega gourmet más carne desmechada mixta encima.',
    ingredientes: [
      'Mega Gourmet',
      'Queso',
      'Tocineta',
      'Porción de carne desmechada mixta: pollo, res y cerdo',
      _salsasAlGusto,
    ],
  ),

  // ═══════════════════════════ BEBIDAS ══════════════════════════
  Product(
    id: 'gaseosa_pequena',
    name: 'Gaseosa pequeña',
    category: 'Bebidas',
    imageAsset: 'assets/images/menu/gaseosa_pequena.jpg',
    imageUrl: '',
    price: 2600,
    tamano: 'Pequeña',
    description: 'Bien fría y del tamaño justo para acompañar tu pedido.',
    variantes: [
      Variante('Sabor', [
        OpcionVariante('Manzana', 2600),
        OpcionVariante('Coca-Cola', 2600),
      ]),
    ],
    permiteSalsas: false,
    permiteAdiciones: false,
  ),
  Product(
    id: 'mr_tea',
    name: 'Mr Tea',
    category: 'Bebidas',
    imageAsset: 'assets/images/mr tea.jpg',
    imageUrl: '',
    price: 3500,
    marca: 'Mr Tea',
    tamano: 'Botella',
    description: 'Té helado de limón, refrescante y no tan dulce.',
    variantes: [
      Variante('Sabor', [OpcionVariante('Limón', 3500)]),
    ],
    permiteSalsas: false,
    permiteAdiciones: false,
  ),
  Product(
    id: 'gaseosa_flexi_400',
    name: 'Gaseosa Flexi 400 ml',
    category: 'Bebidas',
    imageAsset: 'assets/images/menu/gaseosa_flexi_400.jpg',
    imageUrl: '',
    price: 4000,
    tamano: '400 ml',
    description: 'La personal de 400 ml, con la mayor variedad de sabores.',
    variantes: [
      Variante('Sabor', [
        OpcionVariante('Coca-Cola', 4000),
        OpcionVariante('Manzana', 4000),
        OpcionVariante('Cuatro', 4000),
      ]),
    ],
    permiteSalsas: false,
    permiteAdiciones: false,
  ),
  Product(
    id: 'gaseosa_postobon_1_5',
    name: 'Gaseosa Postobón 1.5 L',
    category: 'Bebidas',
    imageAsset: 'assets/images/gaseosa postobon 1.5.jpg',
    imageUrl: '',
    price: 6000,
    tamano: '1.5 L',
    description: 'Litro y medio para compartir, en los sabores de siempre.',
    variantes: [
      Variante('Sabor', [
        OpcionVariante('Manzana', 6000),
        OpcionVariante('Uva', 6000),
        OpcionVariante('Pepsi', 6000),
        OpcionVariante('Colombiana', 6000),
        OpcionVariante('Naranjada', 6000),
      ]),
    ],
    permiteSalsas: false,
    permiteAdiciones: false,
  ),
  Product(
    id: 'gaseosa_2_litros',
    name: 'Gaseosa 2 litros',
    category: 'Bebidas',
    imageAsset: 'assets/images/gaseosa 2 litros.png',
    imageUrl: '',
    price: 7500,
    tamano: '2 L',
    description: 'Dos litros: la de la mesa cuando el pedido es para todos.',
    variantes: [
      Variante('Sabor', [
        OpcionVariante('Manzana', 7500),
        OpcionVariante('Colombiana', 7500),
        OpcionVariante('Pepsi', 7500),
        OpcionVariante('Cuatro', 7500),
      ]),
    ],
    permiteSalsas: false,
    permiteAdiciones: false,
  ),
  Product(
    id: 'coca_cola_1_5',
    name: 'Coca-Cola 1.5 L',
    category: 'Bebidas',
    imageAsset: 'assets/images/menu/coca_cola_1_5.jpg',
    imageUrl: '',
    price: 7500,
    marca: 'Coca-Cola',
    tamano: '1.5 L',
    description: 'La Coca-Cola grande, para acompañar todo el pedido.',
    permiteSalsas: false,
    permiteAdiciones: false,
  ),
  Product(
    id: 'hit_litro',
    name: 'Hit de litro',
    category: 'Bebidas',
    imageAsset: 'assets/images/hit litro.jpg',
    imageUrl: '',
    price: 6000,
    marca: 'Hit',
    tamano: '1 L',
    description: 'Un litro de jugo Hit, si prefieres algo con fruta.',
    permiteSalsas: false,
    permiteAdiciones: false,
  ),
  Product(
    id: 'econolitro_postobon',
    name: 'Econolitro Postobón',
    category: 'Bebidas',
    imageAsset: 'assets/images/econolitro postobon.jpg',
    imageUrl: '',
    price: 4500,
    marca: 'Postobón',
    tamano: 'Econolitro',
    description: 'El econolitro de Postobón: rinde y es el más económico.',
    permiteSalsas: false,
    permiteAdiciones: false,
  ),
  Product(
    id: 'econolitro_coca_cola',
    name: 'Econolitro Coca-Cola',
    category: 'Bebidas',
    imageAsset: 'assets/images/econolitro coca cola.jpg',
    imageUrl: '',
    price: 6000,
    marca: 'Coca-Cola',
    tamano: 'Econolitro',
    description: 'Econolitro de Coca-Cola, el que alcanza para repetir.',
    permiteSalsas: false,
    permiteAdiciones: false,
  ),
];

/// Lo que se ve en el menú: todo menos las bebidas.
List<Product> get productosDelMenu =>
    demoProducts.where((p) => p.category != kCategoriaBebidas).toList();

/// Las bebidas que se ofrecen dentro del carrito.
List<Product> get bebidas => productosDeCategoria(kCategoriaBebidas);

// ───────────────────────── Bebidas por marca ─────────────────────────
//
// En el menú del negocio una bebida es una presentación ("Gaseosa Flexi
// 400 ml") que trae sabores de varias marcas. Pero el cliente no piensa
// así: piensa "quiero una Coca-Cola" y después mira de qué tamaño. Lo que
// sigue le da la vuelta a esa lista para ofrecerla por marca, sin tocar
// los productos ni los precios: cada presentación sigue siendo la misma
// del menú y al carrito se agrega igual que antes.

/// De qué marca es cada sabor del menú. Lo que no esté aquí se agrupa
/// bajo "Otras", que es mejor que dejarlo por fuera.
const Map<String, String> _marcaPorSabor = {
  'Coca-Cola': 'Coca-Cola',
  'Manzana': 'Postobón',
  'Uva': 'Postobón',
  'Colombiana': 'Postobón',
  'Naranjada': 'Postobón',
  'Cuatro': 'Postobón',
  'Pepsi': 'Pepsi',
  'Limón': 'Mr Tea',
};

/// El orden en que se muestran las marcas. Las que no estén salen después,
/// alfabéticamente, así agregar una bebida nueva nunca la deja invisible.
const List<String> _ordenMarcas = [
  'Coca-Cola',
  'Postobón',
  'Hit',
  'Pepsi',
  'Mr Tea',
];

String marcaDeSabor(String sabor) => _marcaPorSabor[sabor] ?? 'Otras';

/// Un tamaño concreto de una marca, con los sabores que esa marca tiene en
/// ese tamaño. Es una sola fila aunque haya varios sabores: el sabor se
/// escoge ahí mismo, en vez de repetir la tarjeta una vez por sabor.
class PresentacionBebida {
  final Product producto;
  final String tamano;

  /// Los sabores de esta marca en este tamaño. Vacía si el producto no da
  /// a elegir (una Coca-Cola 1.5 L es lo que es).
  final List<String> sabores;

  final int precio;

  const PresentacionBebida({
    required this.producto,
    required this.tamano,
    required this.precio,
    this.sabores = const [],
  });

  /// Solo se le pregunta al cliente cuando de verdad hay que escoger.
  bool get pideSabor => sabores.length > 1;

  /// Lo que se manda al carrito: las mismas opciones de siempre.
  Map<String, String> opcionesCon(String? sabor) {
    final elegido = sabor ?? (sabores.isEmpty ? null : sabores.first);
    return elegido == null ? const {} : {'Sabor': elegido};
  }
}

/// Una marca con todas sus presentaciones, de la más barata a la más cara.
class MarcaBebida {
  final String nombre;
  final List<PresentacionBebida> presentaciones;

  const MarcaBebida({required this.nombre, required this.presentaciones});

  int get desde => presentaciones.first.precio;

  /// La foto de la presentación más grande: es la que mejor muestra la marca.
  String get imageAsset => presentaciones.last.producto.imageAsset;
}

/// Las bebidas agrupadas por marca, listas para la hoja del carrito.
List<MarcaBebida> bebidasPorMarca() {
  final porMarca = <String, List<PresentacionBebida>>{};

  for (final bebida in bebidas) {
    final sabores = bebida.variantes
        .where((v) => v.titulo == 'Sabor')
        .expand((v) => v.opciones)
        .toList();

    if (sabores.isEmpty) {
      // Sin sabores a elegir: la marca la trae el producto.
      final marca = bebida.marca.isEmpty ? 'Otras' : bebida.marca;
      porMarca.putIfAbsent(marca, () => []).add(PresentacionBebida(
            producto: bebida,
            tamano: bebida.tamano,
            precio: bebida.price,
          ));
      continue;
    }

    // Los sabores de un mismo tamaño se juntan por marca: queda una fila
    // por marca y tamaño, con sus sabores adentro, en vez de repetir la
    // misma tarjeta una vez por sabor.
    final saboresPorMarca = <String, List<OpcionVariante>>{};
    for (final sabor in sabores) {
      // Si el producto declara marca, manda esa; si no, la dice el sabor.
      final marca =
          bebida.marca.isNotEmpty ? bebida.marca : marcaDeSabor(sabor.nombre);
      saboresPorMarca.putIfAbsent(marca, () => []).add(sabor);
    }

    saboresPorMarca.forEach((marca, suyos) {
      porMarca.putIfAbsent(marca, () => []).add(PresentacionBebida(
            producto: bebida,
            tamano: bebida.tamano,
            sabores: suyos.map((s) => s.nombre).toList(),
            // En este menú todos los sabores de un tamaño valen igual; si
            // algún día no, manda el más barato y el resto se ve al elegir.
            precio: suyos.map((s) => s.precio).reduce((a, b) => a < b ? a : b),
          ));
    });
  }

  final marcas = porMarca.entries
      .map((e) => MarcaBebida(
            nombre: e.key,
            presentaciones: e.value..sort((a, b) => a.precio - b.precio),
          ))
      .toList();

  marcas.sort((a, b) {
    final ia = _ordenMarcas.indexOf(a.nombre);
    final ib = _ordenMarcas.indexOf(b.nombre);
    if (ia >= 0 && ib >= 0) return ia - ib;
    if (ia >= 0) return -1;
    if (ib >= 0) return 1;
    return a.nombre.compareTo(b.nombre);
  });
  return marcas;
}

/// El ícono de una categoría, para el placeholder cuando no hay foto.
IconData iconoDeCategoria(String categoria) {
  for (final c in kCategorias) {
    if (c.nombre == categoria) return c.icono;
  }
  return categoria == kCategoriaBebidas ? Icons.local_drink : Icons.fastfood;
}

/// Productos de una categoría, en el orden del catálogo.
List<Product> productosDeCategoria(String categoria) =>
    demoProducts.where((p) => p.category == categoria).toList();

/// Los que se muestran en el carrusel "Destacadas" del Inicio.
List<Product> get productosDestacados =>
    productosDelMenu.where((p) => p.destacado).toList();

/// Primer producto de una categoría — se usa como foto de portada de la
/// categoría en el selector, así no hay que cargar imágenes aparte.
Product? portadaDeCategoria(String categoria) {
  final deLaCategoria = productosDeCategoria(categoria);
  if (deLaCategoria.isEmpty) return null;
  // Primero uno con foto propia del negocio; si ninguno tiene, el primero.
  for (final p in deLaCategoria) {
    if (p.imageAsset.isNotEmpty) return p;
  }
  return deLaCategoria.first;
}

/// Busca un producto por id (útil para el carrito y los pedidos).
Product? productoPorId(String id) {
  for (final p in demoProducts) {
    if (p.id == id) return p;
  }
  return null;
}
