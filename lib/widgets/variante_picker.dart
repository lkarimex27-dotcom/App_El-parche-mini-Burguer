import 'package:flutter/material.dart';
import '../models/product.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Un grupo de opciones del producto: "Queso o tocineta", "Pollo o cerdo",
/// "Sabor"… Se escoge una sola. Si alguna opción cambia el precio, se ve.
class VariantePicker extends StatelessWidget {
  final Variante variante;
  final String? elegida;
  final int precioBaseProducto;
  final ValueChanged<OpcionVariante> onElegir;

  const VariantePicker({
    super.key,
    required this.variante,
    required this.elegida,
    required this.precioBaseProducto,
    required this.onElegir,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(variante.titulo, style: AppTextStyles.heading(size: 13)),
        const SizedBox(height: 8),
        ...variante.opciones.map((o) {
          final activa = o.nombre == elegida;
          // Solo se muestra el precio cuando la opción cuesta distinto.
          final diferencia = o.precio - precioBaseProducto;

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: () => onElegir(o),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                decoration: BoxDecoration(
                  color: activa ? const Color(0xFFFBF1DF) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: activa ? AppColors.mostaza : AppColors.borde,
                    width: activa ? 1.6 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      activa
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      size: 17,
                      color: activa ? AppColors.mostaza : AppColors.muted,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        o.nombre,
                        style: AppTextStyles.body(
                            size: 12.5, weight: FontWeight.w600),
                      ),
                    ),
                    Text(
                      diferencia == 0 ? '\$${o.precio}' : '+\$$diferencia',
                      style: AppTextStyles.heading(
                        size: 12,
                        color: diferencia == 0 ? AppColors.muted : AppColors.tomate,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
