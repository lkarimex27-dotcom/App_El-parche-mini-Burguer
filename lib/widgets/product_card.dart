import 'package:flutter/material.dart';
import '../models/product.dart';
import '../state/app_scope.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'app_image.dart';

/// Tarjeta de producto con la foto como protagonista.
/// Se adapta al alto que le dé el padre (carrusel del Inicio o grilla del Menú).
///
/// El botón "+" lo agrega directo al carrito; las salsas, adiciones y
/// bebidas se escogen allá.
class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final double width;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.width = 158,
  });

  void _agregar(BuildContext context) {
    AppScope.carritoSinEscuchar(context).agregar(product: product);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: AppColors.verde,
          duration: const Duration(seconds: 2),
          content: Text(
            '${product.name} se agregó al carrito',
            style: AppTextStyles.body(size: 12.5, color: Colors.white),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final usuario = AppScope.usuario(context);
    final esFavorito = usuario.esFavorito(product);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.carbon.withAlpha(15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  AppImage(
                    product.imageAsset,
                    fallbackUrl: product.imageUrl,
                    placeholderIcon: iconoDeCategoria(product.category),
                    width: double.infinity,
                  ),
                  if (product.destacado)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.tomate,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          'Top',
                          style: AppTextStyles.heading(size: 9.5, color: Colors.white),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => usuario.alternarFavorito(product),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(220),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          esFavorito ? Icons.favorite : Icons.favorite_border,
                          size: 15,
                          color: esFavorito ? AppColors.tomate : AppColors.muted,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: AppTextStyles.heading(size: 12.5, weight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.description,
                    style: AppTextStyles.body(size: 10, color: AppColors.muted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          '\$${product.price}',
                          style: AppTextStyles.heading(size: 12, color: AppColors.tomate),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      InkWell(
                        onTap: () => _agregar(context),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppColors.mostaza,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.add, color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
