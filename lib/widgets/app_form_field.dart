import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Decoración común a todos los campos de la app, para que los formularios
/// se vean iguales en Login, Registro, Mis datos y Direcciones.
InputDecoration campoDecoration({
  required String hint,
  IconData? icon,
  Widget? suffix,
  bool obligatorio = false,
}) {
  return InputDecoration(
    hintText: obligatorio ? '$hint *' : hint,
    hintStyle: AppTextStyles.body(size: 12.5, color: AppColors.muted),
    prefixIcon: icon == null
        ? null
        : Icon(icon, color: AppColors.mostaza, size: 19),
    suffixIcon: suffix,
    filled: true,
    fillColor: Colors.white,
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
    errorStyle: AppTextStyles.body(size: 10.5, color: AppColors.tomate),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.borde),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.mostaza, width: 1.6),
    ),
    // Los campos que faltan quedan marcados en rojo tomate.
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.tomate, width: 1.6),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.tomate, width: 1.6),
    ),
  );
}

/// Campo de texto de la app. Si es [obligatorio], valida que no quede vacío
/// y marca el borde en rojo con el mensaje debajo.
class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? initialValue;
  final String hint;
  final IconData? icon;
  final TextInputType? teclado;
  final bool obscure;
  final Widget? suffix;
  final bool obligatorio;
  final int? maxLength;
  final List<TextInputFormatter>? formatters;

  /// Validación extra, además de la de campo obligatorio.
  final String? Function(String)? validarAdemas;

  final void Function(String)? onChanged;

  const AppTextField({
    super.key,
    this.controller,
    this.initialValue,
    required this.hint,
    this.icon,
    this.teclado,
    this.obscure = false,
    this.suffix,
    this.obligatorio = false,
    this.maxLength,
    this.formatters,
    this.validarAdemas,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      keyboardType: teclado,
      obscureText: obscure,
      maxLength: maxLength,
      inputFormatters: formatters,
      onChanged: onChanged,
      style: AppTextStyles.body(size: 13),
      decoration: campoDecoration(
        hint: hint,
        icon: icon,
        suffix: suffix,
        obligatorio: obligatorio,
      ).copyWith(counterText: ''),
      validator: (valor) {
        final texto = (valor ?? '').trim();
        if (obligatorio && texto.isEmpty) return 'Completa este campo';
        if (texto.isEmpty) return null;
        return validarAdemas?.call(texto);
      },
    );
  }
}

/// Aviso de "te faltan campos" que se muestra arriba del formulario.
class AvisoFaltantes extends StatelessWidget {
  final String mensaje;
  const AvisoFaltantes({super.key, required this.mensaje});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.tomate.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.tomate.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, size: 16, color: AppColors.tomate),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              mensaje,
              style: AppTextStyles.body(size: 11.5, color: AppColors.tomate),
            ),
          ),
        ],
      ),
    );
  }
}

/// Muestra el mensaje de "faltan campos" como SnackBar, igual en toda la app.
void avisarCamposIncompletos(BuildContext context,
    [String mensaje = 'Completa los campos marcados en rojo']) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        backgroundColor: AppColors.tomate,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(mensaje,
                  style: AppTextStyles.body(size: 12.5, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
}

/// Confirmación verde, también compartida.
void avisarExito(BuildContext context, String mensaje) =>
    avisarExitoEn(ScaffoldMessenger.of(context), mensaje);

/// Igual que [avisarExito], pero recibiendo el messenger ya resuelto.
/// Se usa cuando hay que navegar y avisar: se toma el messenger antes de
/// salir de la pantalla, porque después el context ya no sirve.
void avisarExitoEn(ScaffoldMessengerState messenger, String mensaje) {
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        backgroundColor: AppColors.verde,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Text(mensaje,
            style: AppTextStyles.body(size: 12.5, color: Colors.white)),
      ),
    );
}
