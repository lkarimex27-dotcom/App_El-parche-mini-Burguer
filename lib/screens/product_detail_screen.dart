import 'package:flutter/material.dart';
import '../models/extras.dart';
import '../models/precio.dart';
import '../models/product.dart';
import '../state/app_scope.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_form_field.dart';
import '../widgets/app_image.dart';
import '../widgets/seccion_opciones.dart';

/// Ficha del producto: foto grande arriba, y debajo las secciones de lo que
/// se le puede agregar, cada una plegable. La cantidad y el botón de agregar
/// viven en una barra fija abajo, para que el precio total esté siempre a la
/// vista por más que se baje la lista.
class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _cantidad = 1;

  /// Las adiciones que lleva este producto. Se escogen aquí, con la foto
  /// del plato a la vista, que es cuando dan ganas de agregarlas.
  final Set<Extra> _adiciones = {};

  /// La opción elegida de cada variante ("Queso o tocineta"…).
  late final Map<String, String> _opciones = widget.product.opcionesPorDefecto;

  /// El precio depende de la variante: "Con queso" cuesta distinto que
  /// "Sencilla", y el menú da el precio total de cada una.
  int get _precioUnitario =>
      widget.product.precioCon(_opciones) + sumaExtras(_adiciones);

  int get _total => _precioUnitario * _cantidad;

  void _agregarAlCarrito() {
    final messenger = ScaffoldMessenger.of(context);

    AppScope.carritoSinEscuchar(context).agregar(
      product: widget.product,
      opciones: _opciones,
      adiciones: _adiciones,
      cantidad: _cantidad,
    );

    Navigator.of(context).pop();
    avisarExitoEn(messenger, '$_cantidad × ${widget.product.name} al carrito');
  }

  @override
  Widget build(BuildContext context) {
    final producto = widget.product;
    final usuario = AppScope.usuario(context);
    final esFavorito = usuario.esFavorito(producto);
    // Las botellas se muestran enteras; la comida llena el recuadro.
    final esBebida = producto.category == kCategoriaBebidas;

    return Scaffold(
      backgroundColor: AppColors.crema,
      body: Column(
        children: [
          Stack(
            children: [
              AppImage(
                producto.imageAsset,
                fallbackUrl: producto.imageUrl,
                placeholderIcon: iconoDeCategoria(producto.category),
                height: 230,
                width: double.infinity,
                enVitrina: esBebida,
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      _CircleButton(
                        icon: Icons.close_rounded,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      const Spacer(),
                      _CircleButton(
                        icon:
                            esFavorito ? Icons.favorite : Icons.favorite_border,
                        color: esFavorito ? AppColors.tomate : AppColors.carbon,
                        onTap: () => usuario.alternarFavorito(producto),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              children: [
                Text(producto.name, style: AppTextStyles.heading(size: 18)),
                const SizedBox(height: 6),
                Text(
                  formatoPesos(producto.price),
                  style:
                      AppTextStyles.heading(size: 20, color: AppColors.verde),
                ),
                if (producto.description.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    producto.description,
                    style: AppTextStyles.body(size: 13, color: AppColors.muted),
                  ),
                ],
                const SizedBox(height: 18),

                // ── Una sección por variante: se escoge una sola ──
                for (final variante in producto.variantes)
                  SeccionOpciones(
                    titulo: variante.titulo,
                    ayuda: 'Escoge 1',
                    obligatoria: true,
                    opciones: [
                      for (final o in variante.opciones)
                        OpcionSeleccionable(
                          nombre: o.nombre,
                          // Solo se anuncia lo que cuesta de más respecto a
                          // la opción más barata: si todas valen igual, no
                          // se enseña ningún precio.
                          recargo: o.precio - variante.opciones
                              .map((x) => x.precio)
                              .reduce((a, b) => a < b ? a : b),
                          elegida: _opciones[variante.titulo] == o.nombre,
                        ),
                    ],
                    unaSola: true,
                    onAlternar: (nombre) => setState(
                      () => _opciones[variante.titulo] = nombre,
                    ),
                  ),

                // ── Adiciones: las que quiera, cada una suma ──
                if (producto.permiteAdiciones)
                  SeccionOpciones(
                    titulo: 'Adiciones',
                    ayuda: 'Opcional · las que quieras',
                    opciones: [
                      for (final extra in kAdiciones)
                        OpcionSeleccionable(
                          nombre: extra.nombre,
                          recargo: extra.precio,
                          elegida: _adiciones.contains(extra),
                        ),
                    ],
                    onAlternar: (nombre) => setState(() {
                      final extra =
                          kAdiciones.firstWhere((e) => e.nombre == nombre);
                      _adiciones.contains(extra)
                          ? _adiciones.remove(extra)
                          : _adiciones.add(extra);
                    }),
                  ),

                if (producto.permiteSalsas) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Las salsas y las bebidas las eliges en el carrito',
                    textAlign: TextAlign.center,
                    style:
                        AppTextStyles.body(size: 10.5, color: AppColors.muted),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _BarraAgregar(
        cantidad: _cantidad,
        total: _total,
        onMenos: () => setState(() => _cantidad = (_cantidad - 1).clamp(1, 20)),
        onMas: () => setState(() => _cantidad = (_cantidad + 1).clamp(1, 20)),
        onAgregar: _agregarAlCarrito,
      ),
    );
  }
}

/// La barra de abajo, siempre a la vista: cantidad a la izquierda y el
/// botón de agregar con el total a la derecha.
class _BarraAgregar extends StatelessWidget {
  final int cantidad;
  final int total;
  final VoidCallback onMenos;
  final VoidCallback onMas;
  final VoidCallback onAgregar;

  const _BarraAgregar({
    required this.cantidad,
    required this.total,
    required this.onMenos,
    required this.onMas,
    required this.onAgregar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            _MiniBoton(
              icon: Icons.remove,
              // A partir de uno no se puede bajar más: para quitarlo del
              // todo está el botón de cerrar.
              onTap: cantidad > 1 ? onMenos : null,
            ),
            SizedBox(
              width: 44,
              child: Text(
                '$cantidad',
                textAlign: TextAlign.center,
                style: AppTextStyles.heading(size: 15),
              ),
            ),
            _MiniBoton(icon: Icons.add, onTap: onMas),
            const SizedBox(width: 14),
            Expanded(
              child: SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: onAgregar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mostaza,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Agregar · ${formatoPesos(total)}',
                      style: AppTextStyles.heading(
                          size: 14, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CircleButton({
    required this.icon,
    required this.onTap,
    this.color = AppColors.carbon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}

class _MiniBoton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _MiniBoton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final apagado = onTap == null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        width: 34,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.crema2,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.borde),
        ),
        child: Icon(
          icon,
          size: 18,
          color: apagado ? AppColors.borde : AppColors.carbon,
        ),
      ),
    );
  }
}
