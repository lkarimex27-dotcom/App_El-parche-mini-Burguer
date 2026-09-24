import 'package:flutter/material.dart';
import 'app_logo.dart';

/// Encabezado que se ve en todas las pantallas de adentro de la app.
class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
      child: const SafeArea(
        bottom: false,
        child: Row(
          children: [
            Expanded(
              child: AppLogo(height: 40, horizontal: true),
            ),
          ],
        ),
      ),
    );
  }
}
