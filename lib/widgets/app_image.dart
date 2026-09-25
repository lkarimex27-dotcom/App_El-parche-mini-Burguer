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

  /// Para fotos de producto recortado sobre fondo blanco, como las botellas.
  /// Muestra la foto entera sobre un fondo claro en vez de recortarla: una
  /// gaseosa de 2 L es tres veces más alta que ancha, y con recorte solo se
  /// vería el centro de la botella, sin tapa ni base.
  final bool enVitrina;

  const AppImage(
    this.assetPath, {
    super.key,
    this.fallbackUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholderIcon = Icons.fastfood_rounded,
    this.enVitrina = false,
  });

  BoxFit get _fit => enVitrina ? BoxFit.contain : fit;

  @override
  Widget build(BuildContext context) {
    // Sin foto propia se pasa derecho al respaldo: Image.asset('') revienta.
    if (assetPath.isEmpty) return _enmarcar(_buildNetwork());

    return _enmarcar(Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: _fit,
      errorBuilder: (context, error, stackTrace) => _buildNetwork(),
    ));
  }

  /// Le pone el fondo de vitrina y las esquinas redondeadas.
  Widget _enmarcar(Widget hijo) {
    if (enVitrina) {
      hijo = Container(
        width: width,
        height: height,
        color: Colors.white,
        padding: const EdgeInsets.all(6),
        child: hijo,
      );
    }
    if (borderRadius == null) return hijo;
    return ClipRRect(borderRadius: borderRadius!, child: hijo);
  }

  Widget _buildNetwork() {
    final url = fallbackUrl;
    if (url == null || url.isEmpty) return _buildPlaceholder();

    return Image.network(
      url,
      width: width,
      height: height,
      fit: _fit,
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
