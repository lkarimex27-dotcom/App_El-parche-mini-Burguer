import 'package:flutter/material.dart';
import '../models/extras.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'primary_button.dart';
import '../models/precio.dart';

/// Chips de selección múltiple para salsas o adiciones.
/// Las que no son gratis muestran su precio.
class ExtrasWrap extends StatelessWidget {
  final List<Extra> catalogo;
  final Set<Extra> seleccionados;
  final ValueChanged<Extra> onAlternar;

  const ExtrasWrap({
    super.key,
    required this.catalogo,
    required this.seleccionados,
    required this.onAlternar,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: catalogo.map((extra) {
        final activo = seleccionados.contains(extra);
        return GestureDetector(
          onTap: () => onAlternar(extra),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: activo ? AppColors.mostaza : Colors.white,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: activo ? AppColors.mostaza : AppColors.borde,
                width: 1.4,
              ),
            ),
            // Los nombres largos ("Carne desmechada mixta…") no caben en una
            // línea en celulares angostos: se limita el ancho y el texto se
            // parte en dos renglones en vez de desbordarse.
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width - 56,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  activo ? Icons.check_circle : Icons.add_circle_outline,
                  size: 14,
                  color: activo ? Colors.white : AppColors.muted,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    extra.nombre,
                    style: AppTextStyles.body(
                      size: 12,
                      weight: FontWeight.w600,
                      color: activo ? Colors.white : AppColors.carbon,
                    ),
                  ),
                ),
                if (!extra.esGratis) ...[
                  const SizedBox(width: 6),
                  Text(
                    '+${formatoPesos(extra.precio)}',
                    style: AppTextStyles.heading(
                      size: 10.5,
                      color: activo ? Colors.white : AppColors.verde,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Hoja inferior para editar las salsas o las adiciones de un producto
/// que ya está en el carrito. Devuelve la selección nueva, o `null` si
/// el cliente cerró sin guardar.
Future<Set<Extra>?> editarExtras({
  required BuildContext context,
  required String titulo,
  required String subtitulo,
  required List<Extra> catalogo,
  required Set<Extra> seleccionados,
}) {
  return showModalBottomSheet<Set<Extra>>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) {
      final seleccion = {...seleccionados};

      return StatefulBuilder(
        builder: (context, setSheetState) {
          final extraTotal = sumaExtras(seleccion);

          return Container(
            decoration: const BoxDecoration(
              color: AppColors.crema,
              borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
            ),
            padding: EdgeInsets.fromLTRB(
              18,
              12,
              18,
              18 + MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.borde,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(titulo, style: AppTextStyles.heading(size: 16)),
                const SizedBox(height: 2),
                Text(subtitulo,
                    style:
                        AppTextStyles.body(size: 11.5, color: AppColors.muted)),
                const SizedBox(height: 14),
                Flexible(
                  child: SingleChildScrollView(
                    child: ExtrasWrap(
                      catalogo: catalogo,
                      seleccionados: seleccion,
                      onAlternar: (extra) => setSheetState(() {
                        if (!seleccion.remove(extra)) seleccion.add(extra);
                      }),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text('Suman', style: AppTextStyles.body(size: 12.5)),
                    const Spacer(),
                    Text(
                      extraTotal == 0
                          ? 'Sin costo'
                          : '+${formatoPesos(extraTotal)}',
                      style: AppTextStyles.heading(
                          size: 14, color: AppColors.tomate),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                PrimaryButton(
                  label: 'Guardar',
                  onPressed: () => Navigator.of(context).pop(seleccion),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
