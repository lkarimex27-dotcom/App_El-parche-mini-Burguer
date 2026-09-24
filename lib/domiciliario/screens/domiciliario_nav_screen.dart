import 'package:flutter/material.dart';
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.crema,
      body: IndexedStack(
        index: _indice,
        children: [
          InicioDomiciliarioScreen(onPerfil: () => setState(() => _indice = 2)),
          const HistorialEntregasScreen(),
          const PerfilDomiciliarioScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
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
        ],
      ),
    );
  }
}
