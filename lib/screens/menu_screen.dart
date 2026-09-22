import 'package:flutter/material.dart';
import '../models/product.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/category_selector.dart';
import '../widgets/product_card.dart';
import 'product_detail_screen.dart';

class MenuScreen extends StatefulWidget {
  /// Categoría con la que abre el menú. `null` = mostrar todo.
  /// La manda el Inicio cuando el cliente toca una categoría.
  final String? categoriaInicial;

  /// Cambia cada vez que el Inicio pide abrir el menú, incluso si es la
  /// misma categoría de la vez pasada. Así el filtro se vuelve a aplicar.
  final int solicitud;

  const MenuScreen({super.key, this.categoriaInicial, this.solicitud = 0});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  /// `null` significa "Todos".
  String? _categoria;

  @override
  void initState() {
    super.initState();
    _categoria = widget.categoriaInicial;
  }

  @override
  void didUpdateWidget(covariant MenuScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // El Inicio pidió abrir el menú en una categoría.
    if (widget.solicitud != oldWidget.solicitud ||
        widget.categoriaInicial != oldWidget.categoriaInicial) {
      setState(() => _categoria = widget.categoriaInicial);
    }
  }

  List<Product> get _productos =>
      _categoria == null ? productosDelMenu : productosDeCategoria(_categoria!);

  @override
  Widget build(BuildContext context) {
    final productos = _productos;

    return Container(
      color: AppColors.crema,
      child: Column(
        children: [
          // ── Categorías arriba, siempre visibles ──
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(child: Text('Menú', style: AppTextStyles.heading(size: 19))),
                      Text(
                        '${productos.length} productos',
                        style: AppTextStyles.body(size: 11.5, color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                CategorySelector(
                  seleccionada: _categoria,
                  incluirTodos: true,
                  onSeleccionar: (nombre) => setState(() => _categoria = nombre),
                ),
              ],
            ),
          ),
          Expanded(
            child: productos.isEmpty
                ? _sinProductos()
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 20),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.72,
                    ),
                    itemCount: productos.length,
                    itemBuilder: (context, index) {
                      final product = productos[index];
                      return ProductCard(
                        product: product,
                        width: double.infinity,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ProductDetailScreen(product: product),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _sinProductos() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.no_meals_outlined, size: 40, color: AppColors.borde),
          const SizedBox(height: 10),
          Text(
            'Todavía no hay productos en\n${_categoria ?? "el menú"}',
            textAlign: TextAlign.center,
            style: AppTextStyles.body(size: 12.5, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}
