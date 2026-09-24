import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'state/app_scope.dart';
import 'state/orders_model.dart';
import 'theme/app_colors.dart';
 import 'screens/splash_screen.dart';

void main() {
  // El splash nativo se queda en pantalla hasta que SplashScreen termina
  // de precargar sus imágenes: así no hay parpadeo blanco al arrancar.
  final binding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: binding);
  runApp(const ParcheMiniBurgerApp());
}

class ParcheMiniBurgerApp extends StatelessWidget {
  const ParcheMiniBurgerApp({super.key});

  @override
  Widget build(BuildContext context) {
    // AppScope va por fuera del MaterialApp para que el carrito y los
    // datos del usuario sobrevivan a cualquier navegación.
    final pedidos = OrdersModel(persistir: true);
    unawaited(pedidos.cargarGuardados());
    return AppScope(
      pedidosInicial: pedidos,
      child: MaterialApp(
        title: 'El parche de la mini burger',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: AppColors.crema,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.mostaza,
            primary: AppColors.mostaza,
            secondary: AppColors.ambar,
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
