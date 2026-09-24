import 'package:flutter/foundation.dart';

class DomiciliarioModel extends ChangeNotifier {
  bool enTurno;
  String vehiculo;
  Uint8List? avatarBytes;

  DomiciliarioModel(
      {this.enTurno = true, this.vehiculo = '', this.avatarBytes});

  void cambiarTurno(bool valor) {
    if (enTurno == valor) return;
    enTurno = valor;
    notifyListeners();
  }

  void actualizarVehiculo(String valor) {
    final nuevo = valor.trim();
    if (vehiculo == nuevo) return;
    vehiculo = nuevo;
    notifyListeners();
  }

  void actualizarAvatar(Uint8List? bytes) {
    avatarBytes = bytes;
    notifyListeners();
  }
}
