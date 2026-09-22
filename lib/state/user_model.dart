import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../models/rol.dart';

class Direccion {
  final String id;
  final String alias;
  final String detalle;
  final String? indicaciones;

  const Direccion({
    required this.id,
    required this.alias,
    required this.detalle,
    this.indicaciones,
  });

  Direccion copyWith({String? alias, String? detalle, String? indicaciones}) =>
      Direccion(
        id: id,
        alias: alias ?? this.alias,
        detalle: detalle ?? this.detalle,
        indicaciones: indicaciones ?? this.indicaciones,
      );
}

/// Datos de la cuenta del cliente. Arranca vacío: se llena con lo que la
/// persona escribe al registrarse o al iniciar sesión, nunca con datos
/// inventados. Cuando conectes el backend, estos métodos son los que
/// llamarían a la API.
class UserModel extends ChangeNotifier {
  String nombre;
  String email;
  String telefono;
  String? tipoDocumento;
  String documento;

  /// Decide si entra a la app del cliente o al panel administrativo.
  Rol rol;

  final List<Direccion> _direcciones = [];
  String? _direccionPrincipalId;
  final Set<String> _favoritos = {};

  UserModel({
    this.nombre = '',
    this.email = '',
    this.telefono = '',
    this.tipoDocumento,
    this.documento = '',
    this.rol = Rol.cliente,
  });

  bool get tieneSesion => nombre.isNotEmpty || email.isNotEmpty;

  /// Primer nombre, para saludar sin que quede larguísimo.
  String get primerNombre {
    final partes = nombre.trim().split(RegExp(r'\s+'));
    return partes.first.isEmpty ? '' : partes.first;
  }

  /// Iniciales para el círculo del perfil en el encabezado.
  String get iniciales {
    final partes =
        nombre.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (partes.isEmpty) {
      return email.isEmpty ? '?' : email[0].toUpperCase();
    }
    if (partes.length == 1) return partes.first[0].toUpperCase();
    return (partes[0][0] + partes[1][0]).toUpperCase();
  }

  // ───────────────────────── Sesión y datos ─────────────────────────

  /// Al crear la cuenta: guarda todo lo que la persona escribió.
  void registrar({
    required String nombre,
    required String email,
    required String telefono,
    String? tipoDocumento,
    String documento = '',
    Rol rol = Rol.cliente,
  }) {
    this.nombre = nombre.trim();
    this.email = email.trim();
    this.telefono = telefono.trim();
    this.tipoDocumento = tipoDocumento;
    this.documento = documento.trim();
    this.rol = rol;
    notifyListeners();
  }

  /// Al entrar con correo: si todavía no hay nombre guardado, se arma uno
  /// legible con la parte de antes del @ (no se inventa nada, se usa lo
  /// que la persona escribió). Cuando haya backend, aquí llegan sus datos.
  void iniciarSesionConCorreo(String email) {
    this.email = email.trim();
    if (nombre.isEmpty) nombre = _nombreDesdeCorreo(this.email);
    rol = _rolDemoDesdeCorreo(this.email);
    notifyListeners();
  }

  /// TEMPORAL: mientras no hay backend, el rol sale del correo para poder
  /// entrar al panel (admin@…, vendedor@…, cocinero@…; cualquier otro es
  /// cliente). Cuando la API devuelva el rol del usuario, se borra esto.
  static Rol _rolDemoDesdeCorreo(String email) {
    switch (email.split('@').first.toLowerCase()) {
      case 'admin':
      case 'administrador':
        return Rol.administrador;
      case 'vendedor':
        return Rol.vendedor;
      case 'cocinero':
        return Rol.cocinero;
      default:
        return Rol.cliente;
    }
  }

  /// Al entrar con Google o Apple.
  void iniciarSesionExterna({required String proveedor, String? email}) {
    if (email != null && email.isNotEmpty) this.email = email.trim();
    if (nombre.isEmpty && this.email.isNotEmpty) {
      nombre = _nombreDesdeCorreo(this.email);
    }
    notifyListeners();
  }

  void cerrarSesion() {
    nombre = '';
    email = '';
    telefono = '';
    tipoDocumento = null;
    documento = '';
    rol = Rol.cliente;
    _direcciones.clear();
    _direccionPrincipalId = null;
    _favoritos.clear();
    notifyListeners();
  }

  static String _nombreDesdeCorreo(String email) {
    final local = email.split('@').first;
    final palabras = local
        .split(RegExp(r'[._\-]+'))
        .where((p) => p.isNotEmpty)
        .map((p) => p[0].toUpperCase() + p.substring(1).toLowerCase());
    return palabras.join(' ');
  }

  void actualizarDatos({
    String? nombre,
    String? email,
    String? telefono,
    String? tipoDocumento,
    String? documento,
  }) {
    if (nombre != null && nombre.trim().isNotEmpty) this.nombre = nombre.trim();
    if (email != null && email.trim().isNotEmpty) this.email = email.trim();
    if (telefono != null && telefono.trim().isNotEmpty) {
      this.telefono = telefono.trim();
    }
    if (tipoDocumento != null) this.tipoDocumento = tipoDocumento;
    if (documento != null) this.documento = documento.trim();
    notifyListeners();
  }

  // ─────────────────────────── Direcciones ──────────────────────────

  List<Direccion> get direcciones => List.unmodifiable(_direcciones);

  Direccion? get direccionPrincipal {
    for (final d in _direcciones) {
      if (d.id == _direccionPrincipalId) return d;
    }
    return _direcciones.isEmpty ? null : _direcciones.first;
  }

  bool esPrincipal(Direccion direccion) => direccion.id == _direccionPrincipalId;

  void agregarDireccion({
    required String alias,
    required String detalle,
    String? indicaciones,
  }) {
    final direccion = Direccion(
      id: 'd${DateTime.now().microsecondsSinceEpoch}',
      alias: alias.trim(),
      detalle: detalle.trim(),
      indicaciones: indicaciones?.trim(),
    );
    _direcciones.add(direccion);
    _direccionPrincipalId ??= direccion.id;
    notifyListeners();
  }

  void actualizarDireccion(Direccion direccion) {
    final i = _direcciones.indexWhere((d) => d.id == direccion.id);
    if (i == -1) return;
    _direcciones[i] = direccion;
    notifyListeners();
  }

  void eliminarDireccion(Direccion direccion) {
    _direcciones.removeWhere((d) => d.id == direccion.id);
    if (_direccionPrincipalId == direccion.id) {
      _direccionPrincipalId = _direcciones.isEmpty ? null : _direcciones.first.id;
    }
    notifyListeners();
  }

  void marcarPrincipal(Direccion direccion) {
    _direccionPrincipalId = direccion.id;
    notifyListeners();
  }

  // ──────────────────────────── Favoritos ───────────────────────────

  Set<String> get favoritos => Set.unmodifiable(_favoritos);

  bool esFavorito(Product product) => _favoritos.contains(product.id);

  void alternarFavorito(Product product) {
    if (!_favoritos.remove(product.id)) _favoritos.add(product.id);
    notifyListeners();
  }

  List<Product> get productosFavoritos =>
      demoProducts.where((p) => _favoritos.contains(p.id)).toList();
}
