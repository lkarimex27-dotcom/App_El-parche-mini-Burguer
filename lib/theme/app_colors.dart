import 'package:flutter/material.dart';

/// Paleta de "El parche de la mini burger"
class AppColors {
  AppColors._();

  static const Color mostaza = Color(0xFFB68C1C);
  static const Color ambar = Color(0xFFD29A42);
  static const Color tomate = Color(0xFFA54131);
  static const Color crema = Color(0xFFFAF3E0);
  static const Color crema2 = Color(0xFFF4EEDC);
  static const Color carbon = Color(0xFF36393F);
  static const Color verde = Color(0xFF3A6D5E);
  static const Color muted = Color(0xFF8B8375);
  static const Color borde = Color(0xFFEAE0C8);

  // Solo para el tema oscuro del panel administrativo.
  static const Color negroAdmin = Color(0xFF111318);
  static const Color negroAdminSuave = Color(0xFF1B1E25);

  static const LinearGradient ambarMostaza = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [ambar, mostaza],
  );

  // ─────────────────────── Colores según el tema ───────────────────────
  //
  // Los de arriba son fijos y siguen sirviendo donde el color no cambia
  // (el mostaza de la marca, el rojo de un error). Estos otros preguntan
  // si la pantalla está en claro u oscuro, para que una misma pantalla
  // sirva en los dos modos sin escribirla dos veces.

  /// El fondo de la pantalla.
  static Color fondo(BuildContext context) =>
      _oscuro(context) ? negroAdmin : crema;

  /// El de las tarjetas y las hojas, por encima del fondo.
  static Color superficie(BuildContext context) =>
      _oscuro(context) ? negroAdminSuave : Colors.white;

  /// El texto principal.
  static Color texto(BuildContext context) =>
      _oscuro(context) ? const Color(0xFFF2EFE6) : carbon;

  /// El texto secundario y los rótulos.
  static Color textoSuave(BuildContext context) =>
      _oscuro(context) ? const Color(0xFF9E998B) : muted;

  /// Las líneas y los bordes.
  static Color linea(BuildContext context) =>
      _oscuro(context) ? const Color(0xFF2C3038) : borde;

  static bool _oscuro(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;
}
