import 'package:flutter/material.dart';
import '../models/product.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'app_image.dart';

/// Fila de categorías con foto, arriba de los productos.
/// Al tocar una, el padre filtra la lista de productos.
class CategorySelector extends StatelessWidget {
  /// Categoría activa. `null` = "Todos".
  final String? seleccionada;
  final ValueChanged<String?> onSeleccionar;

  /// Agrega el círculo "Todos" al principio.
  final bool incluirTodos;

  const CategorySelector({
    super.key,
    required this.seleccionada,
    required this.onSeleccionar,
    this.incluirTodos = false,
  });

  @override
  Widget build(BuildContext context) {
    final extra = incluirTodos ? 1 : 0;

    return SizedBox(
      height: 106,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        itemCount: kCategorias.length + extra,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          if (incluirTodos && index == 0) {
            return _CategoriaCircle(
              label: 'Todos',
              selected: seleccionada == null,
              onTap: () => onSeleccionar(null),
            );
          }

          final categoria = kCategorias[index - extra];
          final portada = portadaDeCategoria(categoria.nombre);

          return _CategoriaCircle(
            label: categoria.nombre,
            icono: categoria.icono,
            imageAsset: portada?.imageAsset,
            imageUrl: portada?.imageUrl,
            selected: seleccionada == categoria.nombre,
            onTap: () => onSeleccionar(categoria.nombre),
          );
        },
      ),
    );
  }
}

class _CategoriaCircle extends StatelessWidget {
  final String label;
  final IconData? icono;
  final String? imageAsset;
  final String? imageUrl;
  final bool selected;
  final VoidCallback onTap;

  const _CategoriaCircle({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icono,
    this.imageAsset,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    const double diametro = 66;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 76,
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: diametro,
              height: diametro,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(
                  color: selected ? AppColors.mostaza : AppColors.borde,
                  width: selected ? 2.4 : 1.2,
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: AppColors.mostaza.withAlpha(60),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: ClipOval(
                child: imageAsset == null
                    ? Container(
                        color: AppColors.crema2,
                        alignment: Alignment.center,
                        child: Icon(
                          icono ?? Icons.grid_view_rounded,
                          size: 24,
                          color: selected ? AppColors.mostaza : AppColors.muted,
                        ),
                      )
                    : AppImage(
                        imageAsset!,
                        fallbackUrl: imageUrl,
                        placeholderIcon: icono ?? Icons.fastfood_rounded,
                        width: diametro,
                        height: diametro,
                      ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.heading(
                size: 10.5,
                weight: selected ? FontWeight.w800 : FontWeight.w600,
                color: selected ? AppColors.carbon : AppColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
