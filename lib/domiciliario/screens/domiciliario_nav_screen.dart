import 'package:flutter/material.dart';
import '../../admin/data/admin_mock.dart';
import '../../screens/main_nav_screen.dart';
import '../../state/app_scope.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import 'historial_entregas_screen.dart';
import 'inicio_domiciliario_screen.dart';
import 'perfil_domiciliario_screen.dart';

class DomiciliarioNavScreen extends StatefulWidget {
  const DomiciliarioNavScreen({super.key});

  @override
  State<DomiciliarioNavScreen> createState() => _DomiciliarioNavScreenState();
}

class _DomiciliarioNavScreenState extends State<DomiciliarioNavScreen> {
  int _indice = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final usuario = AppScope.usuarioSinEscuchar(context);
      final pedidos = AppScope.pedidosSinEscuchar(context);
      if (pedidos.pedidosAsignados(usuario.email).isEmpty) {
        pedidos.agregarPedidosEjemplo(
          pedidosDeEjemplo()
              .where((pedido) => pedido.domiciliarioId != null)
              .map((pedido) => pedido.asignarADomiciliario(usuario.email))
              .toList(),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.crema,
      body: IndexedStack(
        index: _indice,
        children: [
          InicioDomiciliarioScreen(onPerfil: () => setState(() => _indice = 2)),
          const HistorialEntregasScreen(),
          const PerfilDomiciliarioScreen(),
          MainNavScreen(
            onVolverDomiciliario: () => setState(() => _indice = 0),
          ),
        ],
      ),
      bottomNavigationBar: _indice == 3
          ? null
          : BottomNavigationBar(
              currentIndex: _indice,
              onTap: (indice) => setState(() => _indice = indice),
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              selectedItemColor: AppColors.mostaza,
              unselectedItemColor: AppColors.muted,
              selectedLabelStyle: AppTextStyles.heading(size: 10),
              unselectedLabelStyle: AppTextStyles.body(size: 10),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home_rounded),
                  label: 'Inicio',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.history_rounded),
                  label: 'Historial',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline_rounded),
                  activeIcon: Icon(Icons.person_rounded),
                  label: 'Perfil',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.shopping_bag_outlined),
                  activeIcon: Icon(Icons.shopping_bag_rounded),
                  label: 'Comprar',
                ),
              ],
            ),
    );
  }
}
