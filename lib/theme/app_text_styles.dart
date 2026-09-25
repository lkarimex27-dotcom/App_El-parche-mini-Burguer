import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Montserrat para títulos / mayúsculas / bold.
/// Poppins para cuerpo de texto.
/// DM Serif Display solo para el tagline del Splash.
///
/// Los tamaños que se piden en cada pantalla pasan por [_ajustar], que baja
/// un poco los textos grandes y deja casi igual los pequeños. Así la letra
/// general se ve más contenida sin perder la jerarquía: un título sigue
/// siendo claramente más grande que un texto secundario.
class AppTextStyles {
  AppTextStyles._();

  /// Piso: por debajo de esto no se encoge nada, para que siga legible.
  static const double _minimo = 9.5;

  /// Qué tanto se comprime lo que está por encima del piso. Bajarlo achica
  /// la letra de toda la app; subirlo la agranda. Es la perilla para
  /// ajustar el tamaño general sin tocar pantalla por pantalla.
  static const double _compresion = 0.80;

  static double _ajustar(double size) {
    if (size <= _minimo) return size;
    return _minimo + (size - _minimo) * _compresion;
  }

  static TextStyle heading({
    double size = 16,
    Color color = AppColors.carbon,
    FontWeight weight = FontWeight.w800,
  }) =>
      GoogleFonts.montserrat(
        fontSize: _ajustar(size),
        fontWeight: weight,
        color: color,
      );

  static TextStyle body({
    double size = 13,
    Color color = AppColors.carbon,
    FontWeight weight = FontWeight.w400,
  }) =>
      GoogleFonts.poppins(
        fontSize: _ajustar(size),
        fontWeight: weight,
        color: color,
      );

  static TextStyle tagline({
    double size = 16,
    Color color = Colors.white,
  }) =>
      GoogleFonts.dmSerifDisplay(fontSize: _ajustar(size), color: color);
}
