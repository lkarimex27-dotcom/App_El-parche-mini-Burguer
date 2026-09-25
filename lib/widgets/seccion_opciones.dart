import 'package:flutter/material.dart';
import '../models/precio.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Una opción dentro de una sección: su nombre y lo que suma al precio.
class OpcionSeleccionable {
  final String nombre;

  /// Lo que cobra de más. En cero no se muestra precio.
  final int recargo;

  final bool elegida;

  const OpcionSeleccionable({
    required this.nombre,
    required this.elegida,
    this.recargo = 0,
  });
}

/// Un bloque de opciones de la ficha del producto: título, una línea de
/// ayuda, y la lista. Se pliega tocando el encabezado, para que una ficha
/// con muchas adiciones no obligue a bajar media pantalla.
///
/// Con [unaSola] se comporta como un grupo de radio (elegir una cambia la
/// anterior); sin él, cada opción se enciende y se apaga por su cuenta.
class SeccionOpciones extends StatefulWidget {
  final String titulo;
  final String ayuda;
  final List<OpcionSeleccionable> opciones;
  final ValueChanged<String> onAlternar;
  final bool unaSola;

  /// Hay que escoger sí o sí. Se avisa con una etiqueta y no se deja plegar.
  final bool obligatoria;

  /// Abiertas de entrada: lo que no se ve, no se pide. Se puede plegar para
  /// llegar antes al botón cuando la lista es larga.
  final bool iniciaAbierta;

  const SeccionOpciones({
    super.key,
    required this.titulo,
    required this.ayuda,
    required this.opciones,
    required this.onAlternar,
    this.unaSola = false,
    this.obligatoria = false,
    this.iniciaAbierta = true,
  });

  @override
  State<SeccionOpciones> createState() => _SeccionOpcionesState();
}

class _SeccionOpcionesState extends State<SeccionOpciones> {
  late bool _abierta = widget.obligatoria || widget.iniciaAbierta;

  @override
  Widget build(BuildContext context) {
    final elegidas = widget.opciones.where((o) => o.elegida).length;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borde),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _abierta = !_abierta),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 13, 12, 13),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                widget.titulo,
                                style: AppTextStyles.heading(size: 14),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (widget.obligatoria) ...[
                              const SizedBox(width: 8),
                              const _Etiqueta(
                                texto: 'Obligatorio',
                                color: AppColors.mostaza,
                              ),
                            ] else if (elegidas > 0) ...[
                              const SizedBox(width: 8),
                              _Etiqueta(
                                texto: '$elegidas',
                                color: AppColors.verde,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.ayuda,
                          style: AppTextStyles.body(
                              size: 11, color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _abierta
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.muted,
                  ),
                ],
              ),
            ),
          ),
          if (_abierta)
            for (final opcion in widget.opciones)
              _FilaOpcion(
                opcion: opcion,
                unaSola: widget.unaSola,
                onTap: () => widget.onAlternar(opcion.nombre),
              ),
        ],
      ),
    );
  }
}

/// El contador o el aviso de "obligatorio" al lado del título.
class _Etiqueta extends StatelessWidget {
  final String texto;
  final Color color;
  const _Etiqueta({required this.texto, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(texto,
          style: AppTextStyles.heading(size: 9.5, color: color)),
    );
  }
}

class _FilaOpcion extends StatelessWidget {
  final OpcionSeleccionable opcion;
  final bool unaSola;
  final VoidCallback onTap;

  const _FilaOpcion({
    required this.opcion,
    required this.unaSola,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final elegida = opcion.elegida;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.borde)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                opcion.nombre,
                style: AppTextStyles.body(
                  size: 13,
                  weight: elegida ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (opcion.recargo > 0) ...[
              Text(
                '+${formatoPesos(opcion.recargo)}',
                style:
                    AppTextStyles.heading(size: 12, color: AppColors.verde),
              ),
              const SizedBox(width: 10),
            ],
            // Redondo para escoger una sola, cuadrado para marcar varias:
            // es la misma señal que usa el resto de las apps.
            _Marca(elegida: elegida, redonda: unaSola),
          ],
        ),
      ),
    );
  }
}

class _Marca extends StatelessWidget {
  final bool elegida;
  final bool redonda;
  const _Marca({required this.elegida, required this.redonda});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: elegida ? AppColors.mostaza : Colors.white,
        shape: redonda ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: redonda ? null : BorderRadius.circular(7),
        border: Border.all(
          color: elegida ? AppColors.mostaza : AppColors.borde,
          width: 1.8,
        ),
      ),
      child: elegida
          ? const Icon(Icons.check_rounded, size: 15, color: Colors.white)
          : null,
    );
  }
}
