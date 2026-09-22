import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Botón de "continuar con" una cuenta externa, con el logo de la marca.
class SocialButton extends StatelessWidget {
  final FaIconData logo;
  final String label;

  /// Color del logo de la marca.
  final Color colorLogo;
  final VoidCallback? onPressed;

  const SocialButton({
    super.key,
    required this.logo,
    required this.label,
    required this.onPressed,
    this.colorLogo = AppColors.carbon,
  });

  /// Continuar con Google.
  factory SocialButton.google({VoidCallback? onPressed}) => SocialButton(
        logo: FontAwesomeIcons.google,
        label: 'Google',
        colorLogo: const Color(0xFFDB4437),
        onPressed: onPressed,
      );

  /// Continuar con Apple.
  factory SocialButton.apple({VoidCallback? onPressed}) => SocialButton(
        logo: FontAwesomeIcons.apple,
        label: 'Apple',
        colorLogo: Colors.black,
        onPressed: onPressed,
      );

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        minimumSize: const Size.fromHeight(44),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        side: const BorderSide(color: AppColors.borde),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(logo, size: 16, color: colorLogo),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.heading(size: 12.5, color: AppColors.carbon),
            ),
          ),
        ],
      ),
    );
  }
}
