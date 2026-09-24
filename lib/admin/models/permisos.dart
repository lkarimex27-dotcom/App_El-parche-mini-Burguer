import 'package:flutter/material.dart';
import '../../models/rol.dart';

/// Los módulos del panel administrativo.
enum ModuloAdmin {
  dashboard,
  pedidos,
  produccion,
  inventario,
  compras,
  productos,
  categorias,
  fichasTecnicas,
  perdidas,
  proveedores,
  clientes,
  ventas,
  devoluciones,
  usuarios,
  roles,
  indicadores,
  perfil,
  configuracion,
}

extension ModuloAdminUi on ModuloAdmin {
  String get label {
    switch (this) {
      case ModuloAdmin.dashboard:
        return 'Dashboard';
      case ModuloAdmin.pedidos:
        return 'Pedidos';
      case ModuloAdmin.produccion:
        return 'Producción';
      case ModuloAdmin.inventario:
        return 'Inventario';
      case ModuloAdmin.compras:
        return 'Compras';
      case ModuloAdmin.productos:
        return 'Productos';
      case ModuloAdmin.categorias:
        return 'Categorías';
      case ModuloAdmin.fichasTecnicas:
        return 'Fichas técnicas';
      case ModuloAdmin.perdidas:
        return 'Pérdidas';
      case ModuloAdmin.proveedores:
        return 'Proveedores';
      case ModuloAdmin.clientes:
        return 'Clientes';
      case ModuloAdmin.ventas:
        return 'Ventas';
      case ModuloAdmin.devoluciones:
        return 'Devoluciones';
      case ModuloAdmin.usuarios:
        return 'Usuarios';
      case ModuloAdmin.roles:
        return 'Roles y permisos';
      case ModuloAdmin.indicadores:
        return 'Indicadores';
      case ModuloAdmin.perfil:
        return 'Mi perfil';
      case ModuloAdmin.configuracion:
        return 'Configuración';
    }
  }

  IconData get icono {
    switch (this) {
      case ModuloAdmin.dashboard:
        return Icons.space_dashboard_outlined;
      case ModuloAdmin.pedidos:
        return Icons.receipt_long_outlined;
      case ModuloAdmin.produccion:
        return Icons.outdoor_grill_outlined;
      case ModuloAdmin.inventario:
        return Icons.inventory_2_outlined;
      case ModuloAdmin.compras:
        return Icons.shopping_cart_outlined;
      case ModuloAdmin.productos:
        return Icons.lunch_dining_outlined;
      case ModuloAdmin.categorias:
        return Icons.category_outlined;
      case ModuloAdmin.fichasTecnicas:
        return Icons.description_outlined;
      case ModuloAdmin.perdidas:
        return Icons.report_gmailerrorred_outlined;
      case ModuloAdmin.proveedores:
        return Icons.local_shipping_outlined;
      case ModuloAdmin.clientes:
        return Icons.people_outline;
      case ModuloAdmin.ventas:
        return Icons.payments_outlined;
      case ModuloAdmin.devoluciones:
        return Icons.assignment_return_outlined;
      case ModuloAdmin.usuarios:
        return Icons.manage_accounts_outlined;
      case ModuloAdmin.roles:
        return Icons.admin_panel_settings_outlined;
      case ModuloAdmin.indicadores:
        return Icons.insights_outlined;
      case ModuloAdmin.perfil:
        return Icons.person_outline_rounded;
      case ModuloAdmin.configuracion:
        return Icons.settings_outlined;
    }
  }
}

/// Lo que se puede hacer dentro de un módulo.
enum Permiso { ver, crear, editar, eliminar, cambiarEstado, anular }

extension PermisoUi on Permiso {
  String get label {
    switch (this) {
      case Permiso.ver:
        return 'Ver';
      case Permiso.crear:
        return 'Crear';
      case Permiso.editar:
        return 'Editar';
      case Permiso.eliminar:
        return 'Eliminar';
      case Permiso.cambiarEstado:
        return 'Cambiar estado';
      case Permiso.anular:
        return 'Anular';
    }
  }
}

const Set<Permiso> _soloVer = {Permiso.ver};
const Set<Permiso> _verYCambiarEstado = {
  Permiso.ver,
  Permiso.cambiarEstado,
};

bool moduloAdmiteCreacion(ModuloAdmin modulo) {
  switch (modulo) {
    case ModuloAdmin.proveedores:
    case ModuloAdmin.compras:
    case ModuloAdmin.produccion:
    case ModuloAdmin.pedidos:
    case ModuloAdmin.devoluciones:
      return true;
    default:
      return false;
  }
}

/// Qué puede hacer cada rol en cada módulo. Cuando haya backend, esto es
/// lo que llegaría de la API: la interfaz ya lee solo de aquí.
final Map<Rol, Map<ModuloAdmin, Set<Permiso>>> permisosPorRol = {
  Rol.administrador: {
    for (final m in ModuloAdmin.values)
      m: {
        if (moduloAdmiteCreacion(m)) Permiso.crear,
        Permiso.ver,
        if (m != ModuloAdmin.perfil) Permiso.editar,
        if (m == ModuloAdmin.proveedores) Permiso.eliminar,
        if (m != ModuloAdmin.dashboard) Permiso.cambiarEstado,
      },
  },
  Rol.vendedor: {
    ModuloAdmin.dashboard: _soloVer,
    ModuloAdmin.pedidos: {Permiso.ver, Permiso.crear, Permiso.cambiarEstado},
    ModuloAdmin.productos: _verYCambiarEstado,
    ModuloAdmin.clientes: {
      Permiso.ver,
      Permiso.editar,
      Permiso.cambiarEstado,
    },
    ModuloAdmin.ventas: _verYCambiarEstado,
    ModuloAdmin.devoluciones: {
      Permiso.ver,
      Permiso.crear,
      Permiso.cambiarEstado,
    },
    ModuloAdmin.perfil: {Permiso.ver, Permiso.editar},
  },
  Rol.cocinero: {
    ModuloAdmin.dashboard: _soloVer,
    ModuloAdmin.produccion: {Permiso.ver, Permiso.crear, Permiso.cambiarEstado},
    ModuloAdmin.inventario: _verYCambiarEstado,
    ModuloAdmin.fichasTecnicas: _verYCambiarEstado,
    ModuloAdmin.perfil: {
      Permiso.ver,
      Permiso.editar,
      Permiso.cambiarEstado,
    },
  },
  // El cliente no entra al panel.
  Rol.cliente: {},
};

Set<Permiso> permisosDe(Rol rol, ModuloAdmin modulo) =>
    permisosPorRol[rol]?[modulo] ?? const {};

/// Si no puede ver el módulo, no se muestra en la navegación.
bool puedeVer(Rol rol, ModuloAdmin modulo) =>
    permisosDe(rol, modulo).contains(Permiso.ver);

bool puede(Rol rol, ModuloAdmin modulo, Permiso permiso) =>
    permisosDe(rol, modulo).contains(permiso);
