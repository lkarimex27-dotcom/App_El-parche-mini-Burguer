import '../../models/extras.dart';
import '../../models/order.dart';
import '../../models/product.dart';

/// ─────────────────────────────────────────────────────────────────
/// DATOS DE EJEMPLO DEL PANEL — TEMPORALES
///
/// Todo lo de este archivo es para poder ver la interfaz mientras no hay
/// backend. Cuando exista la API, se reemplaza el contenido de aquí y las
/// pantallas no cambian: todas leen solo de estas funciones.
/// ─────────────────────────────────────────────────────────────────

/// Un pedido por encima de este monto necesita que el administrador lo
/// apruebe antes de generar la orden de producción.
const int kMontoAprobacion = 150000;

/// Mientras no exista el estado "pendiente", un pedido caro que todavía
/// está en preparación es el que espera aprobación.
bool requiereAprobacion(Order pedido) =>
    pedido.total > kMontoAprobacion && pedido.status == OrderStatus.preparacion;

// ───────────────────────────── Ventas ─────────────────────────────

/// Ventas de los últimos 7 días, de lunes a domingo.
const List<int> ventasPorDia = [
  380000,
  420000,
  350000,
  460000,
  520000,
  610000,
  420000,
];

const List<String> diasSemana = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

int get ventasHoy => ventasPorDia.last;

int get ventasSemana => ventasPorDia.fold(0, (t, v) => t + v);

// ──────────────────────────── Inventario ───────────────────────────

/// Insumos bajo el mínimo. En la etapa de Inventario esto sale del
/// modelo real de insumos; por ahora alimenta la alerta del dashboard.
class InsumoBajo {
  final String nombre;
  final String unidad;
  final double stock;
  final double minimo;

  const InsumoBajo(this.nombre, this.unidad, this.stock, this.minimo);

  bool get esCritico => stock <= minimo / 2;
}

const List<InsumoBajo> insumosBajos = [
  InsumoBajo('Queso cheddar', 'kg', 1.5, 5),
  InsumoBajo('Tocineta', 'kg', 3, 4),
];

// ───────────────────────── Más vendidos ──────────────────────────

class ProductoVendido {
  final String productId;
  final int unidades;

  const ProductoVendido(this.productId, this.unidades);

  Product? get producto => productoPorId(productId);
}

const List<ProductoVendido> masVendidos = [
  ProductoVendido('hamburguesa_doble', 38),
  ProductoVendido('salchipapa_mega_tradicional', 31),
  ProductoVendido('mini_burguer', 27),
  ProductoVendido('gran_perro_y', 22),
  ProductoVendido('chuzo_pollo_cerdo', 15),
];

// ──────────────────── Pedidos sembrados (demo) ────────────────────

/// Arma una línea de pedido a partir de un producto real del catálogo.
OrderLine _linea(
  String productId,
  int cantidad, {
  List<String> salsas = const [],
  List<String> adiciones = const [],
  Map<String, String> opciones = const {},
}) {
  final p = productoPorId(productId)!;
  return OrderLine(
    productId: p.id,
    nombre: p.name,
    categoria: p.category,
    imageAsset: p.imageAsset,
    imageUrl: p.imageUrl,
    cantidad: cantidad,
    precioBase: p.precioCon(opciones),
    salsas: kSalsas.where((e) => salsas.contains(e.id)).toList(),
    adiciones: kAdiciones.where((e) => adiciones.contains(e.id)).toList(),
    opciones: opciones,
  );
}

Order _pedido({
  required String id,
  required List<OrderLine> lineas,
  required OrderStatus status,
  required Duration hace,
  String metodoPago = 'Nequi',
  String? direccion,
  String? comprobante,
  String? note,
}) {
  final subtotal = lineas.fold(0, (t, l) => t + l.total);
  return Order(
    id: id,
    fecha: DateTime.now().subtract(hace),
    status: status,
    lineas: lineas,
    subtotal: subtotal,
    domicilio: direccion == null ? 0 : 4000,
    metodoPago: metodoPago,
    direccion: direccion,
    comprobante: comprobante,
    note: note,
  );
}

/// Pedidos de ejemplo para ver el panel con datos.
/// BORRAR cuando el backend entregue pedidos reales: basta con dejar de
/// pasárselos a OrdersModel en lib/main.dart.
List<Order> pedidosDeEjemplo() => [
      // Caro y en preparación: es el que pide aprobación del administrador.
      _pedido(
        id: '1054',
        status: OrderStatus.preparacion,
        hace: const Duration(minutes: 12),
        direccion: 'Cra 45 #12-30, apto 302',
        comprobante: 'comprobante_1054.jpg',
        lineas: [
          _linea('hamburguesa_doble', 4, salsas: ['bbq', 'ajo']),
          _linea('salchipapa_super_gourmet', 3),
        ],
      ),
      _pedido(
        id: '1053',
        status: OrderStatus.preparacion,
        hace: const Duration(minutes: 28),
        direccion: 'Calle 10 #5-20',
        lineas: [
          _linea('mini_burguer', 2,
              opciones: {'Queso o tocineta': 'Con queso'},
              salsas: ['rosada']),
          _linea('gaseosa_flexi_400', 2, opciones: {'Sabor': 'Hit mora'}),
        ],
      ),
      _pedido(
        id: '1052',
        status: OrderStatus.listo,
        hace: const Duration(hours: 1, minutes: 5),
        metodoPago: 'Bancolombia',
        lineas: [
          _linea('chuzo_pollo_cerdo', 1, opciones: {'Elige tu opción': 'Cerdo'}),
          _linea('salchipapa_especial', 1, adiciones: ['ad_tocineta']),
        ],
      ),
      _pedido(
        id: '1051',
        status: OrderStatus.aprobado,
        hace: const Duration(hours: 3),
        direccion: 'Cra 38 #22-14',
        lineas: [
          _linea('gran_perro_y', 3, salsas: ['tartara', 'pina']),
          _linea('coca_cola_1_5', 1),
        ],
      ),
      _pedido(
        id: '1050',
        status: OrderStatus.rechazado,
        hace: const Duration(days: 1, hours: 2),
        metodoPago: 'Nequi',
        note: 'Comprobante no válido',
        lineas: [_linea('arepa_desmechada', 2)],
      ),
    ];
