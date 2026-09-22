/// Salsas y adiciones del menú.
class Extra {
  final String id;
  final String nombre;

  /// 0 = va incluida sin costo.
  final int precio;

  const Extra(this.id, this.nombre, {this.precio = 0});

  bool get esGratis => precio == 0;

  @override
  bool operator ==(Object other) => other is Extra && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

// ───────────────────────────── Salsas ─────────────────────────────
// Van sin costo: los productos que dicen "salsas al gusto" las incluyen.

const List<Extra> kSalsasCaseras = [
  Extra('tartara', 'Tártara'),
  Extra('chowy', 'Chowy'),
  Extra('ajo', 'Ajo'),
];

const List<Extra> kSalsasInstitucionales = [
  Extra('rosada', 'Rosada'),
  Extra('roja', 'Roja'),
  Extra('pina', 'Piña'),
  Extra('mostaza', 'Mostaza'),
  Extra('bbq', 'BBQ'),
  Extra('mayonesa', 'Mayonesa'),
];

/// Todas las salsas juntas, para el carrito y los pedidos.
const List<Extra> kSalsas = [...kSalsasCaseras, ...kSalsasInstitucionales];

// ──────────────────────────── Adiciones ───────────────────────────

const List<Extra> kAdiciones = [
  Extra('ad_queso', 'Queso', precio: 8000),
  Extra('ad_tocineta', 'Tocineta', precio: 8000),
  Extra('ad_carne', 'Carne de hamburguesa', precio: 8000),
  Extra('ad_salchicha_x4', 'Salchicha x4 unidades', precio: 8000),
  Extra('ad_cebolla', 'Cebolla', precio: 8000),
  Extra('ad_salchicha_grande', 'Salchicha grande', precio: 4500),
  Extra('ad_huevo_codorniz', 'Huevo de codorniz', precio: 900),
  Extra('ad_5_huevos_codorniz', '5 huevos de codorniz', precio: 4000),
  Extra('ad_desmechada_mixta', 'Carne desmechada mixta (pollo, res y cerdo)',
      precio: 12000),
  Extra('ad_gourmet', 'Adición gourmet', precio: 13000),
];

int sumaExtras(Iterable<Extra> extras) =>
    extras.fold(0, (total, e) => total + e.precio);
