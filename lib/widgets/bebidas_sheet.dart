import 'package:flutter/material.dart';
import '../models/product.dart';
import '../state/app_scope.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'app_image.dart';
import 'app_form_field.dart';

/// Lista de bebidas que se abre desde el carrito. Cada una muestra foto,
/// nombre, precio y el botón de agregar. Si tiene sabores o tamaños, se
/// escogen antes de agregarla.
Future<void> mostrarBebidas(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _HojaBebidas(),
  );
}

class _HojaBebidas extends StatelessWidget {
  const _HojaBebidas();

  @override
  Widget build(BuildContext context) {
    final lista = bebidas;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: AppColors.crema,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
        child: Column(
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
            Text('Bebidas', style: AppTextStyles.heading(size: 16)),
            const SizedBox(height: 2),
            Text('Agrégale algo de tomar a tu pedido',
                style: AppTextStyles.body(size: 11.5, color: AppColors.muted)),
            const SizedBox(height: 14),
            Expanded(
              child: ListView.separated(
                controller: scrollController,
                itemCount: lista.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) => _TarjetaBebida(bebida: lista[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TarjetaBebida extends StatefulWidget {
  final Product bebida;
  const _TarjetaBebida({required this.bebida});

  @override
  State<_TarjetaBebida> createState() => _TarjetaBebidaState();
}

class _TarjetaBebidaState extends State<_TarjetaBebida> {
  late final Map<String, String> _opciones = widget.bebida.opcionesPorDefecto;

  void _agregar() {
    final messenger = ScaffoldMessenger.of(context);

    AppScope.carritoSinEscuchar(context).agregar(
      product: widget.bebida,
      opciones: _opciones,
    );

    Navigator.of(context).pop();
    avisarExitoEn(messenger, '${widget.bebida.name} al carrito');
  }

  @override
  Widget build(BuildContext context) {
    final bebida = widget.bebida;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borde),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppImage(
                bebida.imageAsset,
                fallbackUrl: bebida.imageUrl,
                placeholderIcon: Icons.local_drink,
                width: 56,
                height: 56,
                borderRadius: BorderRadius.circular(12),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(bebida.name, style: AppTextStyles.heading(size: 12.5)),
                    const SizedBox(height: 2),
                    Text('\$${bebida.price}',
                        style: AppTextStyles.heading(
                            size: 13, color: AppColors.tomate)),
                  ],
                ),
              ),
              TextButton(
                onPressed: _agregar,
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.mostaza,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100)),
                ),
                child: Text('Agregar',
                    style:
                        AppTextStyles.heading(size: 11.5, color: Colors.white)),
              ),
            ],
          ),
          // Sabores o tamaños, cuando la bebida los tiene.
          ...bebida.variantes.map(
            (v) => Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${v.titulo}:',
                      style:
                          AppTextStyles.body(size: 11, color: AppColors.muted)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: v.opciones.map((o) {
                      final activa = _opciones[v.titulo] == o.nombre;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _opciones[v.titulo] = o.nombre),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: activa ? AppColors.mostaza : AppColors.crema,
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              color:
                                  activa ? AppColors.mostaza : AppColors.borde,
                            ),
                          ),
                          child: Text(
                            o.nombre,
                            style: AppTextStyles.body(
                              size: 11.5,
                              weight: FontWeight.w600,
                              color: activa ? Colors.white : AppColors.carbon,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
