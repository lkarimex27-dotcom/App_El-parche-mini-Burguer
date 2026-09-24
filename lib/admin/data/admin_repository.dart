import 'package:flutter/foundation.dart';
import '../../models/product.dart';
import '../models/permisos.dart';

/// Estado local de los procesos administrativos. Esta capa mantiene la
/// interfaz desacoplada del origen de datos y puede sustituirse por una API.
class AdminRegistro {
  final String id;
  String titulo;
  String detalle;
  String estado;
  final double? cantidad;
  final double? valor;

  AdminRegistro({
    required this.id,
    required this.titulo,
    required this.detalle,
    required this.estado,
    this.cantidad,
    this.valor,
  });
}

class AdminRepository extends ChangeNotifier {
  final Map<ModuloAdmin, List<AdminRegistro>> _datos = {};
  int _consecutivo = 1;

  AdminRepository() {
    _sembrar();
  }

  List<AdminRegistro> registros(ModuloAdmin modulo) =>
      List.unmodifiable(_datos[modulo] ?? const []);

  List<AdminRegistro> buscar(ModuloAdmin modulo, String consulta) {
    final texto = consulta.trim().toLowerCase();
    if (texto.isEmpty) return registros(modulo);
    return registros(modulo)
        .where((r) => '${r.titulo} ${r.detalle} ${r.estado}'
            .toLowerCase()
            .contains(texto))
        .toList();
  }

  AdminRegistro agregar(
    ModuloAdmin modulo, {
    required String titulo,
    required String detalle,
    String estado = 'Activo',
    double? cantidad,
    double? valor,
  }) {
    final registro = AdminRegistro(
      id: '${modulo.name}-${_consecutivo++}',
      titulo: titulo.trim(),
      detalle: detalle.trim(),
      estado: estado,
      cantidad: cantidad,
      valor: valor,
    );
    _datos.putIfAbsent(modulo, () => []).insert(0, registro);
    notifyListeners();
    return registro;
  }

  void cambiarEstado(AdminRegistro registro) {
    final modulo = _datos.entries
        .firstWhere((entry) => entry.value.contains(registro))
        .key;
    final estados = estadosPara(modulo);
    final siguiente = (estados.indexOf(registro.estado) + 1) % estados.length;
    registro.estado = estados[siguiente];
    notifyListeners();
  }

  List<String> estadosPara(ModuloAdmin modulo) {
    switch (modulo) {
      case ModuloAdmin.inventario:
        return ['Disponible', 'Stock bajo', 'Agotado', 'En reposición'];
      case ModuloAdmin.compras:
        return ['Borrador', 'Solicitada', 'En tránsito', 'Recibida', 'Cancelada'];
      case ModuloAdmin.produccion:
        return ['Pendiente', 'En preparación', 'En control de calidad', 'Lista', 'No conforme'];
      case ModuloAdmin.productos:
        return ['Activo', 'Agotado temporalmente', 'Inactivo'];
      case ModuloAdmin.categorias:
        return ['Activa', 'Oculta', 'Inactiva'];
      case ModuloAdmin.fichasTecnicas:
        return ['Borrador', 'En revisión', 'Vigente', 'Archivada'];
      case ModuloAdmin.perdidas:
        return ['Registrada', 'En investigación', 'Aprobada', 'Descartada'];
      case ModuloAdmin.proveedores:
        return ['Activo', 'En evaluación', 'Suspendido', 'Inactivo'];
      case ModuloAdmin.clientes:
        return ['Activo', 'Inactivo', 'Bloqueado'];
      case ModuloAdmin.ventas:
        return ['Pendiente de pago', 'Pagada', 'Anulada', 'Reembolsada'];
      case ModuloAdmin.devoluciones:
        return ['Pendiente', 'En revisión', 'Aprobada', 'Rechazada', 'Completada'];
      case ModuloAdmin.usuarios:
        return ['Activo', 'Invitación pendiente', 'Bloqueado', 'Inactivo'];
      case ModuloAdmin.roles:
        return ['Activo', 'En revisión', 'Inactivo'];
      case ModuloAdmin.indicadores:
        return ['Actualizado', 'Revisar', 'Atendido'];
      case ModuloAdmin.perfil:
        return ['Activo', 'Pendiente de verificación'];
      case ModuloAdmin.configuracion:
        return ['Configurado', 'Pendiente de configuración'];
      case ModuloAdmin.dashboard:
      case ModuloAdmin.pedidos:
        return ['Pendiente', 'En revisión', 'Completado'];
    }
  }

  bool eliminar(ModuloAdmin modulo, AdminRegistro registro) {
    if (modulo == ModuloAdmin.proveedores &&
        registros(ModuloAdmin.compras)
            .any((c) => c.detalle.contains(registro.titulo))) {
      return false;
    }
    final eliminado = _datos[modulo]?.remove(registro) ?? false;
    if (eliminado) notifyListeners();
    return eliminado;
  }

  void _sembrar() {
    _datos[ModuloAdmin.inventario] = [
      AdminRegistro(
          id: 'i-1',
          titulo: 'Queso cheddar',
          detalle: 'Stock: 1.5 kg · Mínimo: 5 · Máximo: 20',
          estado: 'Bajo',
          cantidad: 1.5),
      AdminRegistro(
          id: 'i-2',
          titulo: 'Tocineta',
          detalle: 'Stock: 3 kg · Mínimo: 4 · Máximo: 15',
          estado: 'Bajo',
          cantidad: 3),
      AdminRegistro(
          id: 'i-3',
          titulo: 'Pan brioche',
          detalle: 'Stock: 48 unidades · Mínimo: 20 · Máximo: 100',
          estado: 'Disponible',
          cantidad: 48),
    ];
    _datos[ModuloAdmin.proveedores] = [
      AdminRegistro(
          id: 'pr-1',
          titulo: 'Distribuciones La 30',
          detalle: 'NIT 901234567 · compras: 4',
          estado: 'Activo'),
      AdminRegistro(
          id: 'pr-2',
          titulo: 'Frutas El Campo',
          detalle: 'NIT 900765432 · compras: 0',
          estado: 'Activo'),
    ];
    _datos[ModuloAdmin.compras] = [
      AdminRegistro(
          id: 'co-1',
          titulo: 'Compra #C-1001',
          detalle: 'Distribuciones La 30 · 12/09/2026 · Queso cheddar',
          estado: 'Recibida',
          valor: 480000),
    ];
    _datos[ModuloAdmin.categorias] = [
      for (final categoria in kCategorias)
        AdminRegistro(
            id: 'cat-${categoria.nombre}',
            titulo: categoria.nombre,
            detalle: 'Categoría activa del menú',
            estado: 'Activa'),
    ];
    _datos[ModuloAdmin.productos] = [
      for (final producto in demoProducts.take(12))
        AdminRegistro(
            id: producto.id,
            titulo: producto.name,
            detalle: '${producto.category} · ${producto.price} COP',
            estado: 'Activo',
            valor: producto.price.toDouble()),
    ];
    _datos[ModuloAdmin.fichasTecnicas] = [
      for (final producto in demoProducts.take(8))
        AdminRegistro(
            id: 'ficha-${producto.id}',
            titulo: producto.name,
            detalle: 'Versión 1 · ${producto.ingredientes.join(', ')}',
            estado: 'Vigente'),
    ];
    _datos[ModuloAdmin.produccion] = [
      AdminRegistro(
          id: 'op-1',
          titulo: 'OP-2026-001 · Pedido #1053',
          detalle: '2 Mini Burguer, 2 Gaseosas · entrega estimada 25 min',
          estado: 'En proceso'),
      AdminRegistro(
          id: 'op-2',
          titulo: 'OP-2026-002 · Preparación interna',
          detalle: 'Base de salsa de la casa · entrega estimada 40 min',
          estado: 'Pendiente'),
    ];
    _datos[ModuloAdmin.clientes] = [
      AdminRegistro(
          id: 'cli-1',
          titulo: 'Laura Mejía',
          detalle: 'laura@correo.com · 3 pedidos · 310 000 0000',
          estado: 'Activo'),
      AdminRegistro(
          id: 'cli-2',
          titulo: 'Daniela Ortiz',
          detalle: 'daniela@correo.com · 5 pedidos · 315 000 0000',
          estado: 'Activo'),
    ];
    _datos[ModuloAdmin.ventas] = [
      AdminRegistro(
          id: 'v-1',
          titulo: 'Venta #1051',
          detalle: 'Pedido entregado · Nequi · 23/09/2026',
          estado: 'Pagada',
          valor: 68000),
      AdminRegistro(
          id: 'v-2',
          titulo: 'Venta #1052',
          detalle: 'Pedido listo · Bancolombia · 23/09/2026',
          estado: 'Pagada',
          valor: 52000),
    ];
    _datos[ModuloAdmin.devoluciones] = [
      AdminRegistro(
          id: 'dev-1',
          titulo: 'Devolución #D-001',
          detalle: 'Pedido #1048 · producto llegó tarde · reposición acordada',
          estado: 'Pendiente'),
    ];
    _datos[ModuloAdmin.perdidas] = [
      AdminRegistro(
          id: 'per-1',
          titulo: 'Pérdida #P-001',
          detalle: 'Producto no conforme · 2 unidades · 22/09/2026',
          estado: 'Registrada'),
    ];
    _datos[ModuloAdmin.usuarios] = [
      AdminRegistro(
          id: 'u-1',
          titulo: 'admin@parche.com',
          detalle: 'Administrador · acceso completo',
          estado: 'Activo'),
      AdminRegistro(
          id: 'u-2',
          titulo: 'cocinero@parche.com',
          detalle: 'Cocinero · producción e inventario',
          estado: 'Activo'),
    ];
    _datos[ModuloAdmin.roles] = [
      AdminRegistro(
          id: 'rol-1',
          titulo: 'Administrador',
          detalle: 'Todos los módulos y permisos',
          estado: 'Activo'),
      AdminRegistro(
          id: 'rol-2',
          titulo: 'Vendedor',
          detalle: 'Pedidos, clientes, ventas y devoluciones',
          estado: 'Activo'),
      AdminRegistro(
          id: 'rol-3',
          titulo: 'Cocinero',
          detalle: 'Producción, inventario y fichas técnicas',
          estado: 'Activo'),
    ];
    _datos[ModuloAdmin.perfil] = [
      AdminRegistro(
          id: 'perfil',
          titulo: 'Mi perfil',
          detalle: 'Datos de la cuenta y preferencias de acceso',
          estado: 'Activo'),
    ];
    _datos[ModuloAdmin.configuracion] = [
      AdminRegistro(
          id: 'config-1',
          titulo: 'Tiempo de empaque',
          detalle: '10 minutos añadidos después de producción',
          estado: 'Configurado'),
      AdminRegistro(
          id: 'config-2',
          titulo: 'Monto de aprobación',
          detalle: '150000 COP',
          estado: 'Configurado'),
    ];
    _datos[ModuloAdmin.indicadores] = [
      AdminRegistro(
          id: 'ind-1',
          titulo: 'Pedidos con tiempo crítico',
          detalle: '2 pedidos superan el 80% del tiempo estimado',
          estado: 'Revisar'),
      AdminRegistro(
          id: 'ind-2',
          titulo: 'Ventas vs devoluciones',
          detalle: 'Ventas: 1.240.000 COP · Devoluciones: 68.000 COP',
          estado: 'Actualizado'),
      AdminRegistro(
          id: 'ind-3',
          titulo: 'Top de productos vendidos',
          detalle: 'Hamburguesa doble · 38 unidades esta semana',
          estado: 'Actualizado'),
    ];
  }
}
