import 'package:flutter/material.dart';
import '../state/app_scope.dart';
import '../widgets/aparicion.dart';
import '../widgets/app_header.dart';
import '../widgets/bottom_nav_bar.dart';
import 'home_screen.dart';
import 'menu_screen.dart';
import 'cart_screen.dart';
import 'orders_screen.dart';
import 'profile_screen.dart';

/// Contenedor de las 5 pestañas del bottom nav:
/// Inicio, Menú, Carrito, Mis pedidos y Perfil.
///
/// El encabezado (logo + perfil) vive aquí, así se ve igual en todas
/// las pestañas y las pantallas de adentro no lo repiten.
class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _currentIndex = 0;

  /// Categoría con la que debe abrir el Menú (null = todas).
  String? _categoriaMenu;
  int _solicitudMenu = 0;

  void _goToTab(int index) => setState(() => _currentIndex = index);

  /// Desde Inicio: abre la pestaña Menú ya filtrada por esa categoría.
  void _abrirCategoria(String categoria) {
    setState(() {
      _categoriaMenu = categoria;
      _solicitudMenu++;
      _currentIndex = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final carrito = AppScope.carrito(context);

    final screens = [
      HomeScreen(
        onVerMenu: () => _goToTab(1),
        onVerCategoria: _abrirCategoria,
      ),
      MenuScreen(categoriaInicial: _categoriaMenu, solicitud: _solicitudMenu),
      CartScreen(
        onVerMenu: () => _goToTab(1),
        onPedidoEnviado: () => _goToTab(3),
      ),
      OrdersScreen(onVerMenu: () => _goToTab(1)),
      ProfileScreen(onCerrar: () => _goToTab(0)),
    ];

    return Scaffold(
      body: Column(
        children: [
          Aparicion(
            orden: 0,
            child: AppHeader(onPerfil: () => _goToTab(4)),
          ),
          Expanded(
            child: IndexedStack(index: _currentIndex, children: screens),
          ),
        ],
      ),
      bottomNavigationBar: Aparicion(
        orden: 2,
        desplazamiento: -14,
        child: AppBottomNavBar(
          currentIndex: _currentIndex,
          onTap: _goToTab,
          cantidadCarrito: carrito.cantidadTotal,
        ),
      ),
    );
  }
}
