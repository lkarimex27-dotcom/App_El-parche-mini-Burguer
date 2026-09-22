/// Rol de la persona que entra a la app. Decide si ve la app del cliente
/// o el panel administrativo, y qué módulos del panel puede abrir.
enum Rol { administrador, vendedor, cocinero, cliente }

extension RolUi on Rol {
  String get label {
    switch (this) {
      case Rol.administrador:
        return 'Administrador';
      case Rol.vendedor:
        return 'Vendedor';
      case Rol.cocinero:
        return 'Cocinero';
      case Rol.cliente:
        return 'Cliente';
    }
  }

  String get descripcion {
    switch (this) {
      case Rol.administrador:
        return 'Acceso total';
      case Rol.vendedor:
        return 'Ventas y pedidos';
      case Rol.cocinero:
        return 'Producción';
      case Rol.cliente:
        return 'Compra desde la app';
    }
  }

  /// Los tres roles del negocio entran al panel; el cliente no.
  bool get esDelPanel => this != Rol.cliente;
}

/// Busca un rol por su nombre guardado (útil cuando llegue del backend).
Rol rolPorNombre(String? nombre) {
  for (final r in Rol.values) {
    if (r.name == nombre) return r;
  }
  return Rol.cliente;
}
