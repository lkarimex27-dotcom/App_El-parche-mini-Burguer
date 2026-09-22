import 'package:flutter/material.dart';
import '../state/app_scope.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/product_card.dart';
import 'product_detail_screen.dart';

/// "Favoritos": los productos que el cliente marcó con el corazón.
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favoritos = AppScope.usuario(context).productosFavoritos;

    return Scaffold(
      backgroundColor: AppColors.crema,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.carbon),
        title: Text('Favoritos', style: AppTextStyles.heading(size: 16)),
      ),
      body: favoritos.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.favorite_border, size: 44, color: AppColors.borde),
                    const SizedBox(height: 12),
                    Text('Aún no tienes favoritos',
                        style: AppTextStyles.heading(size: 14)),
                    const SizedBox(height: 4),
                    Text(
                      'Toca el corazón de un producto para\nguardarlo aquí',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body(size: 12, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(14),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.72,
              ),
              itemCount: favoritos.length,
              itemBuilder: (context, index) {
                final product = favoritos[index];
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
    );
  }
}
