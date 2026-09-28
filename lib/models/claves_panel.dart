import 'rol.dart';

/// ─────────────────────────────────────────────────────────────────
/// CLAVES DE LOS PANELES — TEMPORALES
///
/// Mientras no hay backend, cada panel se abre con una clave fija. Van
/// aquí y no repartidas por las pantallas, para cambiarlas en un solo
/// sitio.
///
/// OJO: esto NO es seguridad de verdad. Las claves viajan dentro de la
/// app, así que cualquiera con el archivo instalado puede sacarlas. Sirve
/// para que un cliente curioso no se meta al panel, no para proteger el
/// negocio. Cuando exista la API, quien valida es el servidor y este
/// archivo se borra entero.
/// ─────────────────────────────────────────────────────────────────
const Map<Rol, String> _clavesPorRol = {
  Rol.administrador: 'Admin@Parche26',
  Rol.empleado: 'Empleado#26P',
  Rol.repartidor: 'Repartidor\$26',
};

/// Los roles que piden clave para entrar. El cliente no: su cuenta es la
/// de la app de siempre.
bool pideClave(Rol rol) => _clavesPorRol.containsKey(rol);

/// Si la clave escrita abre ese panel. Se compara tal cual, con mayúsculas
/// y símbolos, porque así se entregaron.
bool claveCorrecta(Rol rol, String escrita) {
  final esperada = _clavesPorRol[rol];
  if (esperada == null) return true;
  return escrita == esperada;
}
