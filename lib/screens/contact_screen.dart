import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/business_info.dart';
import '../services/enlaces.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_logo.dart';
import '../widgets/mapa_negocio.dart';
import '../widgets/primary_button.dart';

/// "Contactar al negocio". Usa la misma paleta, tipografía, tarjetas y
/// botones que el resto de la app, para que no parezca otra aplicación.
class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  void _copiar(BuildContext context, String texto, String que) {
    Clipboard.setData(ClipboardData(text: texto));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: AppColors.verde,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Text('$que copiado',
              style: AppTextStyles.body(size: 12.5, color: Colors.white)),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.crema,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.carbon),
        title: Text('Contactar', style: AppTextStyles.heading(size: 15)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
        children: [
          // Cabecera con la identidad del negocio, igual que en el resto.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: AppColors.ambarMostaza,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                const AppLogo(height: 56, mostrarNombre: false),
                const SizedBox(height: 10),
                Text(BusinessInfo.nombre,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.heading(size: 14, color: Colors.white)),
                const SizedBox(height: 2),
                Text('Escríbenos, te respondemos en el horario de atención',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body(size: 11, color: Colors.white)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Text('Canales de atención', style: AppTextStyles.heading(size: 13)),
          const SizedBox(height: 10),
          _TarjetaContacto(
            icon: Icons.chat_outlined,
            colorIcono: const Color(0xFF25D366),
            titulo: 'WhatsApp',
            detalle: '${BusinessInfo.whatsapp} · escríbenos directo',
            accion: 'Abrir',
            onTap: () => Enlaces.whatsApp(context),
            onMantener: () => _copiar(context, BusinessInfo.whatsapp, 'WhatsApp'),
          ),
          const SizedBox(height: 10),
          _TarjetaContacto(
            icon: Icons.phone_outlined,
            titulo: 'Llamar',
            detalle: BusinessInfo.telefono,
            accion: 'Marcar',
            onTap: () => Enlaces.llamar(context),
            onMantener: () => _copiar(context, BusinessInfo.telefono, 'Teléfono'),
          ),
          const SizedBox(height: 10),
          _TarjetaContacto(
            icon: Icons.camera_alt_outlined,
            colorIcono: const Color(0xFFC13584),
            titulo: 'Instagram',
            detalle: BusinessInfo.instagram,
            accion: 'Abrir',
            onTap: () => Enlaces.instagram(context),
            onMantener: () => _copiar(context, BusinessInfo.instagram, 'Instagram'),
          ),

          const SizedBox(height: 18),
          Text('Dónde estamos', style: AppTextStyles.heading(size: 13)),
          const SizedBox(height: 10),
          const MapaNegocio(),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.carbon,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FilaOscura(
                    icon: Icons.location_on_outlined, texto: BusinessInfo.direccion),
                SizedBox(height: 10),
                _FilaOscura(
                    icon: Icons.access_time_rounded, texto: BusinessInfo.horario),
                SizedBox(height: 10),
                _FilaOscura(
                    icon: Icons.moped_outlined, texto: BusinessInfo.zonasDomicilio),
                SizedBox(height: 10),
                _FilaOscura(
                    icon: Icons.payments_outlined, texto: BusinessInfo.metodosPago),
              ],
            ),
          ),

          const SizedBox(height: 20),
          PrimaryButton(
            label: 'Escribir por WhatsApp',
            color: const Color(0xFF25D366),
            onPressed: () => Enlaces.whatsApp(context),
          ),
          const SizedBox(height: 10),
          Text(
            'Deja pulsada una tarjeta para copiar el dato.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body(size: 10.5, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

class _TarjetaContacto extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String detalle;
  final String accion;
  final VoidCallback onTap;

  /// Dejar pulsado copia el dato, por si prefiere pegarlo en otro lado.
  final VoidCallback? onMantener;

  final Color colorIcono;

  const _TarjetaContacto({
    required this.icon,
    required this.titulo,
    required this.detalle,
    required this.accion,
    required this.onTap,
    this.onMantener,
    this.colorIcono = AppColors.mostaza,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onMantener,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borde),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.crema2,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: colorIcono, size: 19),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo, style: AppTextStyles.heading(size: 12.5)),
                  const SizedBox(height: 2),
                  Text(detalle,
                      style: AppTextStyles.body(size: 11.5, color: AppColors.muted)),
                ],
              ),
            ),
            Text(accion,
                style: AppTextStyles.heading(size: 11, color: AppColors.mostaza)),
            const Icon(Icons.chevron_right_rounded, color: AppColors.muted, size: 20),
          ],
        ),
      ),
    );
  }
}

class _FilaOscura extends StatelessWidget {
  final IconData icon;
  final String texto;
  const _FilaOscura({required this.icon, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.ambar),
        const SizedBox(width: 10),
        Expanded(
          child: Text(texto,
              style: AppTextStyles.body(size: 12, color: Colors.white)),
        ),
      ],
    );
  }
}
