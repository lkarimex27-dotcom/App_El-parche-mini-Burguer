import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// Barra de búsqueda del panel. La usan todos los listados (pedidos,
/// inventario, productos…), así que no lleva nada propio de un módulo.
class AdminSearchBar extends StatelessWidget {
  final String hint;
  final ValueChanged<String> onBuscar;
  final TextEditingController? controller;

  const AdminSearchBar({
    super.key,
    required this.hint,
    required this.onBuscar,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onBuscar,
      style: AppTextStyles.body(size: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.body(size: 12.5, color: AppColors.muted),
        prefixIcon: const Icon(Icons.search_rounded,
            size: 20, color: AppColors.muted),
        suffixIcon: controller == null || controller!.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.close_rounded, size: 18),
                color: AppColors.muted,
                onPressed: () {
                  controller!.clear();
                  onBuscar('');
                },
              ),
        filled: true,
        fillColor: Colors.white,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borde),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.mostaza, width: 1.6),
        ),
      ),
    );
  }
}

/// Fila de filtros. El primero suele ser "Todos" y va con `valor: null`.
class FiltroChips<T> extends StatelessWidget {
  final List<FiltroOpcion<T>> opciones;
  final T? seleccionado;
  final ValueChanged<T?> onSeleccionar;

  const FiltroChips({
    super.key,
    required this.opciones,
    required this.seleccionado,
    required this.onSeleccionar,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: opciones.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final opcion = opciones[i];
          final activo = opcion.valor == seleccionado;

          return GestureDetector(
            onTap: () => onSeleccionar(opcion.valor),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: activo ? AppColors.mostaza : Colors.white,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: activo ? AppColors.mostaza : AppColors.borde,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    opcion.label,
                    style: AppTextStyles.body(
                      size: 12,
                      weight: FontWeight.w600,
                      color: activo ? Colors.white : AppColors.carbon,
                    ),
                  ),
                  if (opcion.cantidad != null) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: activo
                            ? Colors.white.withAlpha(60)
                            : AppColors.crema2,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        '${opcion.cantidad}',
                        style: AppTextStyles.heading(
                          size: 10,
                          color: activo ? Colors.white : AppColors.muted,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class FiltroOpcion<T> {
  final String label;
  final T? valor;
  final int? cantidad;

  const FiltroOpcion(this.label, this.valor, {this.cantidad});
}
