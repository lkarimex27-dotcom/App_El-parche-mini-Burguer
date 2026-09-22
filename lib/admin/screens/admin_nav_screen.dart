import 'package:flutter/material.dart';
import '../../state/app_scope.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_header.dart';
import '../models/permisos.dart';
import '../widgets/admin_states.dart';
import 'admin_pedidos_screen.dart';
import 'dashboard_screen.dart';
import 'mas_screen.dart';

/// Contenedor del panel administrativo. La barra de abajo solo muestra
/// las pestañas que el rol puede ver; "Más" lleva al resto de módulos.
class AdminNavScreen extends StatefulWidget {
  const AdminNavScreen({super.key});

  @override
  State<AdminNavScreen> createState() => _AdminNavScreenState();
}

class _AdminNavScreenState extends State<AdminNavScreen> {
  int _indice = 0;

  /// Orden fijo de la barra. "Más" siempre va de último.
  static const List<ModuloAdmin> _pestanas = [
    ModuloAdmin.dashboard,
    ModuloAdmin.pedidos,
    ModuloAdmin.produccion,
    ModuloAdmin.inventario,
  ];

  void _irA(int i) => setState(() => _indice = i);

  /// Desde el dashboard o desde "Más": si el módulo es una pestaña, cambia
  /// de pestaña; si no, todavía no tiene pantalla (llega en otra etapa).
  void _abrirModulo(List<ModuloAdmin> visibles, ModuloAdmin modulo) {
    final i = visibles.indexOf(modulo);
    if (i != -1) {
      _irA(i);
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: AppColors.carbon,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Text('${modulo.label}: módulo en construcción',
              style: AppTextStyles.body(size: 12.5, color: Colors.white)),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final rol = AppScope.usuario(context).rol;
    final visibles = _pestanas.where((m) => puedeVer(rol, m)).toList();

    // Si el rol no puede ver nada del panel, no se le arma una barra vacía.
    if (visibles.isEmpty) {
      return const Scaffold(
        backgroundColor: AppColors.crema,
        body: Center(
          child: AdminEmptyState(
            icono: Icons.lock_outline_rounded,
            titulo: 'Sin acceso al panel',
            detalle: 'Tu rol no tiene permisos administrativos.',
          ),
        ),
      );
    }

    final indice = _indice.clamp(0, visibles.length);
    final pantallas = [
      for (final modulo in visibles) _pantallaDe(modulo, visibles),
      MasScreen(rol: rol, onAbrirModulo: (m) => _abrirModulo(visibles, m)),
    ];

    return Scaffold(
      body: Column(
        children: [
          const AppHeader(),
          Expanded(child: IndexedStack(index: indice, children: pantallas)),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: indice,
        onTap: _irA,
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
          for (final modulo in visibles)
            BottomNavigationBarItem(
              icon: Icon(modulo.icono),
              label: modulo.label,
            ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz_rounded),
            label: 'Más',
          ),
        ],
      ),
    );
  }

  Widget _pantallaDe(ModuloAdmin modulo, List<ModuloAdmin> visibles) {
    switch (modulo) {
      case ModuloAdmin.dashboard:
        return DashboardScreen(
          onAbrirModulo: (m) => _abrirModulo(visibles, m),
        );
      case ModuloAdmin.pedidos:
        return const AdminPedidosScreen();
      // Producción e Inventario llegan en las siguientes etapas.
      default:
        return _EnConstruccion(modulo: modulo);
    }
  }
}

class _EnConstruccion extends StatelessWidget {
  final ModuloAdmin modulo;
  const _EnConstruccion({required this.modulo});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.crema,
      child: Center(
        child: AdminEmptyState(
          icono: modulo.icono,
          titulo: modulo.label,
          detalle: 'Este módulo se construye en la siguiente etapa.',
        ),
      ),
    );
  }
}
