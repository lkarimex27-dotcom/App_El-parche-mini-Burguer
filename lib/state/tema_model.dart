import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Si la app se ve clara u oscura. Lo decide la persona con el botón de la
/// luna y se guarda en el teléfono, para que al volver a abrir siga como lo
/// dejó.
class TemaModel extends ChangeNotifier {
  static const _clave = 'tema_oscuro';

  bool _oscuro;
  final bool _persistir;

  TemaModel({bool oscuro = false, bool persistir = false})
      : _oscuro = oscuro,
        _persistir = persistir;

  bool get oscuro => _oscuro;

  ThemeMode get modo => _oscuro ? ThemeMode.dark : ThemeMode.light;

  /// El ícono del botón: la luna cuando está claro (para pasar a oscuro) y
  /// el sol cuando está oscuro.
  IconData get icono =>
      _oscuro ? Icons.light_mode_rounded : Icons.dark_mode_rounded;

  String get descripcion => _oscuro ? 'Pasar a modo claro' : 'Modo oscuro';

  void alternar() {
    _oscuro = !_oscuro;
    notifyListeners();
    unawaited(_guardar());
  }

  /// Lee lo que la persona dejó escogido la última vez.
  Future<void> cargarGuardado() async {
    if (!_persistir) return;
    final preferencias = await SharedPreferences.getInstance();
    final guardado = preferencias.getBool(_clave);
    if (guardado == null || guardado == _oscuro) return;
    _oscuro = guardado;
    notifyListeners();
  }

  Future<void> _guardar() async {
    if (!_persistir) return;
    final preferencias = await SharedPreferences.getInstance();
    await preferencias.setBool(_clave, _oscuro);
  }
}
