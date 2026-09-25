import 'package:flutter/widgets.dart';
import '../domiciliario/models/domiciliario_model.dart';
import 'cart_model.dart';
import 'orders_model.dart';
import 'user_model.dart';
import '../admin/data/admin_repository.dart';

/// Deja el carrito, los pedidos y los datos del usuario disponibles en todo
/// el árbol de widgets, sin paquetes externos.
///
/// - `AppScope.carrito(context)` / `usuario(context)` / `pedidos(context)` se
///   suscriben: el widget se reconstruye solo cuando algo cambia.
/// - Las versiones `...SinEscuchar` sirven para acciones (un onTap que
///   agrega algo) donde no hace falta reconstruir.
class AppScope extends StatefulWidget {
  final Widget child;

  /// Permiten inyectar estado ya armado (útil en pruebas).
  final CartModel? carritoInicial;
  final UserModel? usuarioInicial;
  final OrdersModel? pedidosInicial;
  final DomiciliarioModel? domiciliarioInicial;
  final AdminRepository? adminInicial;

  const AppScope({
    super.key,
    required this.child,
    this.carritoInicial,
    this.usuarioInicial,
    this.pedidosInicial,
    this.domiciliarioInicial,
    this.adminInicial,
  });

  static CartModel carrito(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_CarritoScope>()!.notifier!;

  static UserModel usuario(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_UsuarioScope>()!.notifier!;

  static OrdersModel pedidos(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_PedidosScope>()!.notifier!;

  static DomiciliarioModel domiciliario(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<_DomiciliarioScope>()!
      .notifier!;

  static AdminRepository admin(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_AdminScope>()!.notifier!;


  static CartModel carritoSinEscuchar(BuildContext context) =>
      context.getInheritedWidgetOfExactType<_CarritoScope>()!.notifier!;

  static UserModel usuarioSinEscuchar(BuildContext context) =>
      context.getInheritedWidgetOfExactType<_UsuarioScope>()!.notifier!;

  static OrdersModel pedidosSinEscuchar(BuildContext context) =>
      context.getInheritedWidgetOfExactType<_PedidosScope>()!.notifier!;

  static DomiciliarioModel domiciliarioSinEscuchar(BuildContext context) =>
      context.getInheritedWidgetOfExactType<_DomiciliarioScope>()!.notifier!;

  static AdminRepository adminSinEscuchar(BuildContext context) =>
      context.getInheritedWidgetOfExactType<_AdminScope>()!.notifier!;


  @override
  State<AppScope> createState() => _AppScopeState();
}

class _AppScopeState extends State<AppScope> {
  late final CartModel _carrito = widget.carritoInicial ?? CartModel();
  late final UserModel _usuario = widget.usuarioInicial ?? UserModel();
  late final OrdersModel _pedidos = widget.pedidosInicial ?? OrdersModel();
  late final DomiciliarioModel _domiciliario =
      widget.domiciliarioInicial ?? DomiciliarioModel();
  late final AdminRepository _admin = widget.adminInicial ?? AdminRepository();

  @override
  void dispose() {
    _carrito.dispose();
    _usuario.dispose();
    _pedidos.dispose();
    _domiciliario.dispose();
    _admin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _CarritoScope(
      notifier: _carrito,
      child: _UsuarioScope(
        notifier: _usuario,
        child: _PedidosScope(
          notifier: _pedidos,
          child: _AdminScope(
            notifier: _admin,
            child: _DomiciliarioScope(
              notifier: _domiciliario,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

class _CarritoScope extends InheritedNotifier<CartModel> {
  const _CarritoScope({required super.notifier, required super.child});
}

class _UsuarioScope extends InheritedNotifier<UserModel> {
  const _UsuarioScope({required super.notifier, required super.child});
}

class _PedidosScope extends InheritedNotifier<OrdersModel> {
  const _PedidosScope({required super.notifier, required super.child});
}

class _DomiciliarioScope extends InheritedNotifier<DomiciliarioModel> {
  const _DomiciliarioScope({required super.notifier, required super.child});
}

class _AdminScope extends InheritedNotifier<AdminRepository> {
  const _AdminScope({required super.notifier, required super.child});
}
