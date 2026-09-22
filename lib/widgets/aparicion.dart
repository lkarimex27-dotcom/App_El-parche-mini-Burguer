import 'package:flutter/material.dart';

/// Hace que un bloque entre con un desvanecido y un pequeño deslizamiento
/// hacia arriba. Con [orden] se escalonan varios bloques para que el Inicio
/// se arme de arriba hacia abajo en vez de aparecer de golpe.
///
/// No usa temporizadores: el retraso está dentro de la misma animación,
/// así que no deja nada pendiente si la pantalla se cierra antes.
class Aparicion extends StatefulWidget {
  final Widget child;

  /// 0 = entra primero, 1 = un pelito después, y así.
  final int orden;

  /// Cuánto sube al aparecer, en píxeles.
  final double desplazamiento;

  const Aparicion({
    super.key,
    required this.child,
    this.orden = 0,
    this.desplazamiento = 18,
  });

  @override
  State<Aparicion> createState() => _AparicionState();
}

class _AparicionState extends State<Aparicion>
    with SingleTickerProviderStateMixin {
  static const Duration _duracionBase = Duration(milliseconds: 420);
  static const Duration _escalon = Duration(milliseconds: 90);

  late final Duration _retraso = _escalon * widget.orden;
  late final Duration _total = _retraso + _duracionBase;

  late final AnimationController _controller =
      AnimationController(vsync: this, duration: _total);

  late final double _inicio =
      _total.inMilliseconds == 0 ? 0 : _retraso.inMilliseconds / _total.inMilliseconds;

  late final Animation<double> _curva = CurvedAnimation(
    parent: _controller,
    curve: Interval(_inicio, 1, curve: Curves.easeOutCubic),
  );

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _curva,
      child: widget.child,
      builder: (context, child) => Opacity(
        opacity: _curva.value,
        child: Transform.translate(
          offset: Offset(0, widget.desplazamiento * (1 - _curva.value)),
          child: child,
        ),
      ),
    );
  }
}

/// Ruta que entra con fundido y un acercamiento muy leve. Se usa al pasar
/// del splash al login y al entrar a la app después de iniciar sesión o
/// registrarse, para que nunca haya un corte seco entre pantallas.
Route<T> rutaConFundido<T>(Widget destino) {
  return PageRouteBuilder<T>(
    transitionDuration: const Duration(milliseconds: 650),
    reverseTransitionDuration: const Duration(milliseconds: 350),
    pageBuilder: (_, __, ___) => destino,
    transitionsBuilder: (_, animation, __, child) {
      final suave = CurvedAnimation(parent: animation, curve: Curves.easeOut);
      return FadeTransition(
        opacity: suave,
        child: ScaleTransition(
          scale: Tween<double>(begin: 1.04, end: 1.0).animate(suave),
          child: child,
        ),
      );
    },
  );
}
