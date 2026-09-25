import 'package:flutter/material.dart';
import '../models/extras.dart';
import '../models/precio.dart';
import '../models/product.dart';
import '../state/app_scope.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_form_field.dart';
import '../widgets/app_image.dart';
import '../widgets/extras_picker.dart';
import '../widgets/primary_button.dart';

/// Ficha del producto: foto, nombre, precio, descripción, las adiciones que
/// le quiera poner, cantidad y agregar. Las bebidas se escogen después, ya
/// en el carrito.
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

  int get _precioUnitario => widget.product.price + sumaExtras(_adiciones);

  int get _total => _precioUnitario * _cantidad;

  void _agregarAlCarrito() {
    final messenger = ScaffoldMessenger.of(context);

    AppScope.carritoSinEscuchar(context).agregar(
      product: widget.product,
      // Las opciones arrancan en su valor por defecto y se cambian en el
      // carrito; las salsas también se escogen allá.
      opciones: widget.product.opcionesPorDefecto,
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
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      _CircleButton(
                        icon: Icons.arrow_back,
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(producto.name, style: AppTextStyles.heading(size: 18)),
                  const SizedBox(height: 6),
                  Text(
                    formatoPesos(producto.price),
                    style: AppTextStyles.heading(
                        size: 20, color: AppColors.verde),
                  ),
                  if (producto.description.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      producto.description,
                      style:
                          AppTextStyles.body(size: 13, color: AppColors.muted),
                    ),
                  ],
                  if (producto.permiteAdiciones) ...[
                    const SizedBox(height: 22),
                    Text('Adiciones',
                        style: AppTextStyles.heading(size: 13)),
                    const SizedBox(height: 2),
                    Text(
                      'Opcional. Se suman al precio.',
                      style:
                          AppTextStyles.body(size: 11, color: AppColors.muted),
                    ),
                    const SizedBox(height: 10),
                    ExtrasWrap(
                      catalogo: kAdiciones,
                      seleccionados: _adiciones,
                      onAlternar: (extra) => setState(() {
                        _adiciones.contains(extra)
                            ? _adiciones.remove(extra)
                            : _adiciones.add(extra);
                      }),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Text('Cantidad', style: AppTextStyles.heading(size: 13)),
                      const Spacer(),
                      _StepperCantidad(
                        cantidad: _cantidad,
                        onMenos: () => setState(
                            () => _cantidad = (_cantidad - 1).clamp(1, 20)),
                        onMas: () => setState(
                            () => _cantidad = (_cantidad + 1).clamp(1, 20)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  PrimaryButton(
                    label: 'Agregar al carrito · ${formatoPesos(_total)}',
                    onPressed: _agregarAlCarrito,
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      'Las salsas y las bebidas las eliges en el carrito',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body(
                          size: 10.5, color: AppColors.muted),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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

class _StepperCantidad extends StatelessWidget {
  final int cantidad;
  final VoidCallback onMenos;
  final VoidCallback onMas;

  const _StepperCantidad({
    required this.cantidad,
    required this.onMenos,
    required this.onMas,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColors.borde),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _MiniBoton(icon: Icons.remove, onTap: onMenos),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text('$cantidad', style: AppTextStyles.heading(size: 13)),
          ),
          _MiniBoton(icon: Icons.add, onTap: onMas),
        ],
      ),
    );
  }
}

class _MiniBoton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _MiniBoton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        width: 26,
        height: 26,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: AppColors.crema2,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 15, color: AppColors.carbon),
      ),
    );
  }
}
