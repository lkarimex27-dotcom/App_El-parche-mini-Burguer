import 'package:flutter/material.dart';
import '../../admin/models/permisos.dart';
import '../../admin/screens/admin_module_screen.dart';
import '../../admin/screens/admin_profile_screen.dart';
import '../../admin/screens/mas_screen.dart';
import '../../admin/widgets/admin_states.dart';
import '../../state/app_scope.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_header.dart';
import 'inicio_empleado_screen.dart';

/// El panel del empleado. Tiene su propio inicio —el turno, no el negocio—
/// y de ahí en adelante entra a los mismos módulos que el administrador,
/// pero solo a los que su rol permite ver.
///
/// Las tablas de los módulos, las tarjetas y la tabla de permisos se
/// comparten con el panel del administrador y viven en lib/admin/: son las
/// mismas para los dos y duplicarlas solo llevaría a que se desincronicen.
class EmpleadoNavScreen extends StatefulWidget {
  const EmpleadoNavScreen({super.key});

  @override
  State<EmpleadoNavScreen> createState() => _EmpleadoNavScreenState();
}

class _EmpleadoNavScreenState extends State<EmpleadoNavScreen> {
  int _indice = 0;

  /// Lo que el empleado hace todo el día, en la barra de abajo. El resto de
  /// sus módulos (compras, catálogo, ventas) queda en "Más".
  static const List<ModuloAdmin> _pestanas = [
    ModuloAdmin.dashboard,
    ModuloAdmin.produccion,
    ModuloAdmin.inventario,
  ];

  void _irA(int i) => setState(() => _indice = i);

  /// Desde el inicio o desde "Más": cambia de pestaña o abre el módulo.
  void _abrirModulo(List<ModuloAdmin> visibles, ModuloAdmin modulo) {
    final i = visibles.indexOf(modulo);
    if (i != -1) {
      _irA(i);
      return;
    }
    if (modulo == ModuloAdmin.perfil) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const AdminProfileScreen()),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: AppColors.fondo(context),
          body: AdminModuleScreen(modulo: modulo, mostrarRegreso: true),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rol = AppScope.usuario(context).rol;
    final visibles = _pestanas.where((m) => puedeVer(rol, m)).toList();

    // Si le quitaron los permisos no se le arma una barra vacía.
    if (visibles.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.fondo(context),
        body: const Center(
          child: AdminEmptyState(
            icono: Icons.lock_outline_rounded,
            titulo: 'Sin acceso',
            detalle: 'Tu rol no tiene módulos asignados.',
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
          AppHeader(
            onPerfil: () => _abrirModulo(visibles, ModuloAdmin.perfil),
            mostrarTema: true,
          ),
          Expanded(child: IndexedStack(index: indice, children: pantallas)),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: indice,
        onTap: _irA,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.superficie(context),
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
              // "Dashboard" es palabra de dueño; para el empleado es su
              // pantalla de inicio.
              label: modulo == ModuloAdmin.dashboard ? 'Inicio' : modulo.label,
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
    if (modulo == ModuloAdmin.dashboard) {
      return InicioEmpleadoScreen(
        onAbrirModulo: (m) => _abrirModulo(visibles, m),
      );
    }
    return AdminModuleScreen(modulo: modulo);
  }
}
