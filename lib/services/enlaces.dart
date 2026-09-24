import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/business_info.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Abre apps externas desde la pantalla "Contactar".
/// Los números y usuarios salen de [BusinessInfo], no se escriben aquí.
class Enlaces {
  Enlaces._();

  /// Abre el chat de WhatsApp del negocio con un mensaje listo.
  /// El enlace wa.me abre la app si está instalada y, si no, el navegador.
  static Future<void> whatsApp(BuildContext context) async {
    final abierto = await _abrir(BusinessInfo.whatsappUrl);
    if (!abierto && context.mounted) {
      _avisarNoSePudo(context, 'WhatsApp', BusinessInfo.whatsapp);
    }
  }

  /// Abre el perfil de Instagram: primero intenta la app y, si no la tiene,
  /// lo lleva al perfil desde el navegador.
  static Future<void> instagram(BuildContext context) async {
    final enApp = await _abrir(BusinessInfo.instagramApp);
    if (enApp) return;

    final enWeb = await _abrir(BusinessInfo.instagramWeb);
    if (!enWeb && context.mounted) {
      _avisarNoSePudo(context, 'Instagram', BusinessInfo.instagram);
    }
  }

  /// Marca el teléfono del negocio.
  static Future<void> llamar(BuildContext context) async {
    await llamarNumero(context, BusinessInfo.telefono);
  }

  static Future<void> llamarNumero(
      BuildContext context, String telefono) async {
    final limpio = telefono.replaceAll(RegExp(r'[^0-9+]'), '');
    final abierto = await _abrir('tel:$limpio');
    if (!abierto && context.mounted) {
      _avisarNoSePudo(context, 'el teléfono', telefono);
    }
  }

  static Future<void> abrirMaps(BuildContext context, String direccion) async {
    final uri = Uri.https('www.google.com', '/maps/search/', {
      'api': '1',
      'query': direccion,
    });
    final abierto = await _abrir(uri.toString());
    if (!abierto && context.mounted) {
      _avisarNoSePudo(context, 'Maps', direccion);
    }
  }

  static Future<bool> _abrir(String url) async {
    try {
      return await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      // Sin la app instalada (o sin navegador) lanza excepción: se responde
      // false para que quien llama muestre el respaldo.
      return false;
    }
  }

  static void _avisarNoSePudo(BuildContext context, String que, String dato) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: AppColors.tomate,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Text(
            'No pudimos abrir $que. Escríbenos a $dato',
            style: AppTextStyles.body(size: 12.5, color: Colors.white),
          ),
        ),
      );
  }
}
