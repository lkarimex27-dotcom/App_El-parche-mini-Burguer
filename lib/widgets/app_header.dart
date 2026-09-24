import 'package:flutter/material.dart';
import 'app_logo.dart';
import '../state/app_scope.dart';

/// Encabezado que se ve en todas las pantallas de adentro de la app.
class AppHeader extends StatelessWidget {
  final VoidCallback? onVolver;

  const AppHeader({super.key, this.onVolver});

  @override
  Widget build(BuildContext context) {
    final usuario = AppScope.usuario(context);
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            if (onVolver != null)
              IconButton(
                tooltip: 'Volver a repartidor',
                onPressed: onVolver,
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            const Expanded(
              child: AppLogo(height: 40, horizontal: true),
            ),
            CircleAvatar(
              radius: 19,
              backgroundColor: const Color(0xFFB68C1C),
              child: Text(
                usuario.iniciales,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
