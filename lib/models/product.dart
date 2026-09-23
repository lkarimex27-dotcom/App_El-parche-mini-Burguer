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

// Fotos temporales, solo donde la imagen corresponde de verdad al
// producto. Los que no tienen foto adecuada van con imageUrl vacío: la
// tarjeta muestra el ícono de su categoría hasta que llegue la foto real
// del negocio a assets/images/<id>.jpg.
const _burgerDoble =
    'https://images.unsplash.com/photo-1572802419224-296b0aeee0d9?w=700&q=80';
const _burgerSencilla =
    'https://images.unsplash.com/photo-1571091718767-18b5b1457add?w=700&q=80';
const _miniBurgers =
    'https://images.unsplash.com/photo-1521305916504-4a1121188589?w=700&q=80';
const _papasFritas =
    'https://images.unsplash.com/photo-1541592106381-b31e9677c0e5?w=700&q=80';

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
    imageAsset: '',
    imageUrl: _miniBurgers,
    price: 12500,
    description: 'La mini de siempre. Puedes pedirla con queso o con tocineta.',
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
    imageAsset: '',
    imageUrl: _burgerSencilla,
    price: 14500,
    description: 'Pan, ensalada, ripio de papa y carne.',
    ingredientes: ['Pan', _ensalada, 'Ripio de papa', 'Carne', _salsasAlGusto],
  ),
  Product(
    id: 'hamburguesa_tradicional_o',
    name: 'Hamburguesa Tradicional (queso o tocineta)',
    category: 'Hamburguesas',
    imageAsset: 'assets/images/tradicional.jpg',
    imageUrl: '',
    price: 15500,
    description: 'La tradicional con queso o con tocineta, tú eliges.',
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
    imageAsset: 'assets/images/tradicional.jpg',
    imageUrl: '',
    price: 16000,
    description: 'La tradicional con queso y tocineta.',
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
    imageAsset: '',
    imageUrl: _burgerDoble,
    price: 18500,
    description: 'Doble carne, doble queso y doble tocineta.',
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
    imageAsset: '',
    imageUrl: '',
    price: 20500,
    description: 'Triple carne, triple queso y triple tocineta.',
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
    imageAsset: '',
    imageUrl: '',
    price: 17500,
    description: 'Con atún y queso.',
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
    description: 'Carne de pollo con queso y tocineta.',
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
    imageAsset: '',
    imageUrl: '',
    price: 20000,
    description: 'Pechuga y carne de hamburguesa juntas.',
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
    imageAsset: '',
    imageUrl: '',
    price: 21000,
    description: 'Carne artesanal con huevo entero.',
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
    imageAsset: '',
    imageUrl: '',
    price: 14000,
    description: 'Arepa tela con carne de hamburguesa, queso y tocineta.',
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
    imageAsset: '',
    imageUrl: '',
    price: 15000,
    description: 'La arepa burger con ensalada y ripio.',
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
    imageAsset: '',
    imageUrl: '',
    price: 18000,
    description: 'Carne desmechada mixta de pollo, res y cerdo.',
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
    imageAsset: '',
    imageUrl: '',
    price: 18000,
    description: 'Trocitos de pollo, cerdo, jamón y maicitos.',
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
    description: 'Arepa rellena de carne mixta desmechada.',
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
    description: 'Con ensalada, papas a la francesa y arepa con queso.',
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
    description: 'Pollo, cerdo y res con tocineta y queso.',
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
    description: 'Pollo, cerdo y res con salchicha ranchera.',
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
    description: 'Queso, tocineta, ensalada y ripio.',
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
    imageAsset: 'assets/images/perra.jpg',
    imageUrl: '',
    price: 15500,
    description: 'Queso, tocineta, ensalada y ripio.',
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
    imageAsset: 'assets/images/perra.jpg',
    imageUrl: '',
    price: 17500,
    description: 'Con doble tocineta.',
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
    description: 'Mini perrito con queso y tocineta.',
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
    imageAsset: 'assets/images/perro.jpg',
    imageUrl: '',
    price: 12500,
    description:
        'Mini perrito con queso o con tocineta. Incluye salsas al gusto.',
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
    imageAsset: 'assets/images/perro.jpg',
    imageUrl: '',
    price: 14500,
    description: 'Perro mediano con queso y tocineta. Incluye salsas al gusto.',
  ),
  Product(
    id: 'perro_mediano_o',
    name: 'Perro Mediano (queso o tocineta)',
    category: 'Perros',
    imageAsset: 'assets/images/perro.jpg',
    imageUrl: '',
    price: 14000,
    description:
        'Perro mediano con queso o con tocineta. Incluye salsas al gusto.',
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
    imageAsset: 'assets/images/perro.jpg',
    imageUrl: '',
    price: 15500,
    description: 'Gran perro con queso y tocineta. Incluye salsas al gusto.',
    destacado: true,
  ),
  Product(
    id: 'gran_perro_o',
    name: 'Gran Perro (queso o tocineta)',
    category: 'Perros',
    imageAsset: 'assets/images/perro.jpg',
    imageUrl: '',
    price: 15000,
    description:
        'Gran perro con queso o con tocineta. Incluye salsas al gusto.',
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
    imageAsset: 'assets/images/perro.jpg',
    imageUrl: '',
    price: 17500,
    description: 'Súper perro con queso y tocineta. Incluye salsas al gusto.',
  ),

  // ════════════════════════ SALCHIPAPAS ═════════════════════════
  Product(
    id: 'salchipapa_mega_tradicional',
    name: 'Mega Tradicional',
    category: 'Salchipapas',
    imageAsset: '',
    imageUrl: '',
    price: 20000,
    description: 'Con carne de hamburguesa picada y nugget de pollo.',
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
    description: 'Con queso, tocineta y nugget de pollo.',
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
    imageAsset: '',
    imageUrl: _papasFritas,
    price: 13000,
    description: 'Papas, salchicha, huevo de codorniz y nugget de pollo.',
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
    imageAsset: '',
    imageUrl: '',
    price: 20500,
    description: 'Tamaño personal. Con queso o con tocineta, tú eliges.',
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
    imageAsset: '',
    imageUrl: '',
    price: 23000,
    description: 'La gourmet grande, con queso o con tocineta.',
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
    imageAsset: '',
    imageUrl: '',
    price: 27000,
    description: 'La mega gourmet con queso y tocineta.',
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
    description: 'La Mega Gourmet más carne desmechada mixta.',
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
    imageAsset: '',
    imageUrl: '',
    price: 2600,
    description: 'Gaseosa pequeña.',
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
    imageAsset: '',
    imageUrl: '',
    price: 3500,
    description: 'Té Mr Tea.',
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
    imageAsset: '',
    imageUrl: '',
    price: 4000,
    description: 'Presentación de 400 ml.',
    variantes: [
      Variante('Sabor', [
        OpcionVariante('Coca-Cola', 4000),
        OpcionVariante('Hit mora', 4000),
        OpcionVariante('Hit mango', 4000),
        OpcionVariante('Hit tropical', 4000),
        OpcionVariante('Hit piña-naranja', 4000),
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
    imageAsset: '',
    imageUrl: '',
    price: 6000,
    description: 'Presentación de 1.5 litros.',
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
    imageAsset: '',
    imageUrl: '',
    price: 7500,
    description: 'Presentación de 2 litros.',
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
    imageAsset: '',
    imageUrl: '',
    price: 7500,
    description: 'Presentación de 1.5 litros.',
    permiteSalsas: false,
    permiteAdiciones: false,
  ),
  Product(
    id: 'hit_litro',
    name: 'Hit de litro',
    category: 'Bebidas',
    imageAsset: '',
    imageUrl: '',
    price: 6000,
    description: 'Marca Postobón.',
    permiteSalsas: false,
    permiteAdiciones: false,
  ),
  Product(
    id: 'econolitro_postobon',
    name: 'Econolitro Postobón',
    category: 'Bebidas',
    imageAsset: '',
    imageUrl: '',
    price: 4500,
    description: 'Econolitro Postobón.',
    permiteSalsas: false,
    permiteAdiciones: false,
  ),
  Product(
    id: 'econolitro_coca_cola',
    name: 'Econolitro Coca-Cola',
    category: 'Bebidas',
    imageAsset: '',
    imageUrl: '',
    price: 6000,
    description: 'Econolitro Coca-Cola.',
    permiteSalsas: false,
    permiteAdiciones: false,
  ),
];

/// Lo que se ve en el menú: todo menos las bebidas.
List<Product> get productosDelMenu =>
    demoProducts.where((p) => p.category != kCategoriaBebidas).toList();

/// Las bebidas que se ofrecen dentro del carrito.
List<Product> get bebidas => productosDeCategoria(kCategoriaBebidas);

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
