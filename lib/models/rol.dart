/// Rol de la persona que entra a la app. Decide si ve la app del cliente,
/// el panel administrativo o la vista de repartidor.
enum Rol { administrador, repartidor, empleado, cliente }

extension RolUi on Rol {
  String get label {
    switch (this) {
      case Rol.administrador:
        return 'Administrador';
      case Rol.repartidor:
        return 'Repartidor';
      case Rol.empleado:
        return 'Empleado';
      case Rol.cliente:
        return 'Cliente';
    }
  }

  String get descripcion {
    switch (this) {
      case Rol.administrador:
        return 'Acceso total';
      case Rol.repartidor:
        return 'Entregas y pedidos';
      case Rol.empleado:
        return 'Operación del negocio';
      case Rol.cliente:
        return 'Compra desde la app';
    }
  }

  /// Los roles del negocio entran al panel; el repartidor y el cliente tienen
  /// sus propias experiencias de usuario.
  bool get esDelPanel => this != Rol.cliente && this != Rol.repartidor;

  /// Se conserva el nombre de la extensión porque la vista de domiciliario ya
  /// existed; ahora ese rol se muestra como Repartidor.
  bool get esDomiciliario => this == Rol.repartidor;
}

/// Busca un rol por su nombre guardado (útil cuando llegue del backend).
/// Los nombres antiguos se aceptan para no invalidar sesiones previas.
Rol rolPorNombre(String? nombre) {
  switch (nombre?.toLowerCase()) {
    case 'vendedor':
      return Rol.repartidor;
    case 'cocinero':
      return Rol.empleado;
    case 'domiciliario':
      return Rol.repartidor;
  }

  for (final r in Rol.values) {
    if (r.name == nombre?.toLowerCase()) return r;
  }
  return Rol.cliente;
}
