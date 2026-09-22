import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Muestra una foto con tres niveles de respaldo, en este orden:
///
/// 1. [assetPath] — la foto propia del negocio en assets/images/.
/// 2. [fallbackUrl] — una foto de internet, mientras no exista la propia.
/// 3. [placeholderIcon] — un ícono, si no hay ninguna de las dos
///    (por ejemplo, sin internet).
///
/// Así las tarjetas muestran siempre una imagen, y el día que agregues
/// tus fotos reales a assets/images/ pasan a mandar ellas sin tocar código.
class AppImage extends StatelessWidget {
  final String assetPath;
  final String? fallbackUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final IconData placeholderIcon;

  const AppImage(
    this.assetPath, {
    super.key,
    this.fallbackUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholderIcon = Icons.fastfood_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final Widget image = Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => _buildNetwork(),
    );

    if (borderRadius == null) return image;
    return ClipRRect(borderRadius: borderRadius!, child: image);
  }

  Widget _buildNetwork() {
    final url = fallbackUrl;
    if (url == null || url.isEmpty) return _buildPlaceholder();

    return Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return _buildPlaceholder(loading: true);
      },
      errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder({bool loading = false}) {
    return Container(
      width: width,
      height: height,
      color: AppColors.crema2,
      alignment: Alignment.center,
      child: loading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(AppColors.ambar),
              ),
            )
          : Icon(placeholderIcon, color: AppColors.mostaza, size: 28),
    );
  }
}
