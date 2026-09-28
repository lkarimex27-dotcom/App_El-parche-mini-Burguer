import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'screens/splash_screen.dart';
import 'state/app_scope.dart';
import 'state/orders_model.dart';
import 'state/tema_model.dart';
import 'theme/app_colors.dart';

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

    final tema = TemaModel(persistir: true);
    unawaited(tema.cargarGuardado());

    return AppScope(
      pedidosInicial: pedidos,
      temaInicial: tema,
      child: const _App(),
    );
  }
}

/// Va aparte del AppScope para poder escuchar el tema: si estuviera en el
/// mismo build, el MaterialApp no se enteraría de que cambió.
class _App extends StatelessWidget {
  const _App();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'El parche de la mini burger',
      debugShowCheckedModeBanner: false,
      theme: _claro,
      darkTheme: _oscuro,
      themeMode: AppScope.tema(context).modo,
      home: const SplashScreen(),
    );
  }

  static final ThemeData _claro = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.crema,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.mostaza,
      primary: AppColors.mostaza,
      secondary: AppColors.ambar,
    ),
  );

  static final ThemeData _oscuro = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.negroAdmin,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.mostaza,
      brightness: Brightness.dark,
      primary: AppColors.mostaza,
      secondary: AppColors.ambar,
      surface: AppColors.negroAdminSuave,
    ),
  );
}
