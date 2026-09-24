import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  /// Cantidad de productos en el carrito. Si es > 0 se dibuja el
  /// globito rojo sobre el ícono del carrito.
  final int cantidadCarrito;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.cantidadCarrito = 0,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.mostaza,
      unselectedItemColor: AppColors.muted,
      showUnselectedLabels: true,
      selectedLabelStyle:
          const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
      unselectedLabelStyle:
          const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
      items: [
        const BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded), label: 'Inicio'),
        const BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu_rounded), label: 'Menú'),
        BottomNavigationBarItem(
          icon: Badge.count(
            count: cantidadCarrito,
            isLabelVisible: cantidadCarrito > 0,
            backgroundColor: AppColors.tomate,
            textColor: Colors.white,
            child: const Icon(Icons.shopping_cart_rounded),
          ),
          label: 'Carrito',
        ),
        const BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_rounded), label: 'Pedidos'),
      ],
    );
  }
}
