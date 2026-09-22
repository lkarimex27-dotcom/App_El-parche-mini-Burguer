import 'package:flutter/material.dart';
import '../models/business_info.dart';
import '../models/product.dart';
import '../state/app_scope.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/aparicion.dart';
import '../widgets/app_image.dart';
import '../widgets/category_selector.dart';
import '../widgets/product_card.dart';
import 'product_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onVerMenu;

  /// Abre la pestaña Menú ya filtrada por esa categoría.
  final ValueChanged<String>? onVerCategoria;

  const HomeScreen({
    super.key,
    required this.onVerMenu,
    this.onVerCategoria,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _categoriaSeleccionada = 0;

  Categoria get _categoria => kCategorias[_categoriaSeleccionada];

  void _abrirProducto(Product product) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final destacados = productosDestacados;
    final deCategoria = productosDeCategoria(_categoria.nombre);

    return Container(
      color: AppColors.crema,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          // ── Bienvenida al cliente ──
          Aparicion(orden: 0, child: _bienvenida(context)),

          // ── Categorías: siempre arriba de los productos ──
          Aparicion(
            orden: 1,
            child: Column(
              children: [
                _tituloSeccion('Categorías',
                    subtitulo: 'Toca una para ver sus productos'),
                const SizedBox(height: 12),
                CategorySelector(
                  seleccionada: _categoria.nombre,
                  onSeleccionar: (nombre) => setState(() {
                    _categoriaSeleccionada =
                        kCategorias.indexWhere((c) => c.nombre == nombre);
                  }),
                ),
              ],
            ),
          ),

          // ── Productos de la categoría elegida ──
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${_categoria.nombre} · ${deCategoria.length} '
                    '${deCategoria.length == 1 ? "opción" : "opciones"}',
                    style: AppTextStyles.heading(size: 14),
                  ),
                ),
                GestureDetector(
                  onTap: () => widget.onVerCategoria?.call(_categoria.nombre),
                  child: Row(
                    children: [
                      Text('Ver en el menú',
                          style: AppTextStyles.body(size: 11.5, color: AppColors.mostaza)),
                      const Icon(Icons.chevron_right, size: 16, color: AppColors.mostaza),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (deCategoria.isEmpty)
            _sinProductos()
          else
            Aparicion(
              orden: 2,
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.72,
                ),
                itemCount: deCategoria.length,
                itemBuilder: (context, index) {
                  final product = deCategoria[index];
                  return ProductCard(
                    product: product,
                    width: double.infinity,
                    onTap: () => _abrirProducto(product),
                  );
                },
              ),
            ),

          // ── Destacadas ──
          Aparicion(
            orden: 3,
            child: Column(
              children: [
                _tituloSeccion('Destacadas',
                    accion: 'Ver todas', onAccion: widget.onVerMenu),
                SizedBox(
                  height: 215,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
                    scrollDirection: Axis.horizontal,
                    itemCount: destacados.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final product = destacados[index];
                      return ProductCard(
                        product: product,
                        onTap: () => _abrirProducto(product),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // ── Información del negocio ──
          const SizedBox(height: 22),
          Aparicion(
            orden: 4,
            child: Column(
              children: [
                _datosRapidos(),
                _tituloSeccion('Sobre nosotros'),
                _sobreNosotros(),
                _contacto(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────── Secciones ───────────────────────────

  /// Lo primero que ve el cliente al entrar: una foto grande con el
  /// saludo de bienvenida. Debajo van las categorías y los productos.
  Widget _bienvenida(BuildContext context) {
    final usuario = AppScope.usuario(context);
    // Si todavía no hay nombre (por ejemplo, entró con una cuenta externa
    // sin correo), se saluda sin nombre en vez de inventar uno.
    final saludo = usuario.primerNombre.isEmpty
        ? 'Te damos la bienvenida 👋'
        : 'Te damos la bienvenida, ${usuario.primerNombre} 👋';

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        // El texto es el que manda el alto; la foto y el velo se estiran
        // detrás, así nunca se desborda aunque el nombre sea largo.
        child: Stack(
          children: [
            const Positioned.fill(
              child: AppImage(
                'assets/images/bienvenida.jpg',
                fallbackUrl: BusinessInfo.fotoBienvenida,
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.carbon.withValues(alpha: 0.25),
                      AppColors.carbon.withValues(alpha: 0.82),
                    ],
                  ),
                ),
              ),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 180),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.ambar,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text('Abierto · ${BusinessInfo.tiempoEntrega}',
                          style: AppTextStyles.heading(size: 9.5, color: Colors.white)),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      saludo,
                      style: AppTextStyles.heading(size: 17, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${BusinessInfo.tagline}. Elige una categoría y pide en minutos.',
                      style: AppTextStyles.body(size: 11.5, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Tres datos de la empresa que el cliente quiere saber de una: cuánto
  /// demora, cuánto vale el domicilio y qué tan bien la califican.
  Widget _datosRapidos() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borde),
        ),
        child: const Row(
          children: [
            _DatoRapido(
              icon: Icons.delivery_dining,
              valor: BusinessInfo.tiempoEntrega,
              etiqueta: 'Entrega',
            ),
            _Separador(),
            _DatoRapido(
              icon: Icons.two_wheeler,
              valor: '\$${BusinessInfo.precioDomicilio}',
              etiqueta: 'Domicilio',
            ),
            _Separador(),
            _DatoRapido(
              icon: Icons.star_rounded,
              valor: '${BusinessInfo.calificacion}',
              etiqueta: '${BusinessInfo.resenas} reseñas',
            ),
          ],
        ),
      ),
    );
  }

  Widget _sobreNosotros() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borde),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(BusinessInfo.nombre, style: AppTextStyles.heading(size: 14)),
            const SizedBox(height: 8),
            Text(
              BusinessInfo.historia,
              style: AppTextStyles.body(size: 12, color: AppColors.muted),
            ),
            const SizedBox(height: 14),
            ...BusinessInfo.promesas.map(
              (p) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle, size: 16, color: AppColors.verde),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(p, style: AppTextStyles.body(size: 12)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _contacto() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.carbon,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dónde y cómo pedir',
                style: AppTextStyles.heading(size: 13, color: Colors.white)),
            const SizedBox(height: 12),
            const _InfoRow(icon: Icons.access_time_rounded, text: BusinessInfo.horario),
            const SizedBox(height: 10),
            const _InfoRow(icon: Icons.location_on_outlined, text: BusinessInfo.direccion),
            const SizedBox(height: 10),
            const _InfoRow(icon: Icons.phone_outlined, text: BusinessInfo.telefono),
            const SizedBox(height: 10),
            const _InfoRow(icon: Icons.moped_outlined, text: BusinessInfo.zonasDomicilio),
            const SizedBox(height: 10),
            const _InfoRow(icon: Icons.payments_outlined, text: BusinessInfo.metodosPago),
            const SizedBox(height: 10),
            const _InfoRow(icon: Icons.camera_alt_outlined, text: BusinessInfo.instagram),
          ],
        ),
      ),
    );
  }

  Widget _sinProductos() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 26),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borde),
        ),
        child: Text(
          'Pronto tendremos algo rico en esta categoría',
          style: AppTextStyles.body(size: 12, color: AppColors.muted),
        ),
      ),
    );
  }

  Widget _tituloSeccion(String titulo,
      {String? subtitulo, String? accion, VoidCallback? onAccion}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: AppTextStyles.heading(size: 15)),
                if (subtitulo != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitulo, style: AppTextStyles.body(size: 11, color: AppColors.muted)),
                ],
              ],
            ),
          ),
          if (accion != null)
            GestureDetector(
              onTap: onAccion,
              child: Text(accion,
                  style: AppTextStyles.body(size: 11.5, color: AppColors.mostaza)),
            ),
        ],
      ),
    );
  }
}

class _DatoRapido extends StatelessWidget {
  final IconData icon;
  final String valor;
  final String etiqueta;

  const _DatoRapido({required this.icon, required this.valor, required this.etiqueta});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 18, color: AppColors.mostaza),
          const SizedBox(height: 4),
          Text(valor, style: AppTextStyles.heading(size: 12)),
          const SizedBox(height: 1),
          Text(
            etiqueta,
            style: AppTextStyles.body(size: 10, color: AppColors.muted),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _Separador extends StatelessWidget {
  const _Separador();

  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 34, color: AppColors.borde);
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.ambar),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text, style: AppTextStyles.body(size: 12, color: Colors.white)),
        ),
      ],
    );
  }
}
