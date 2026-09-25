import 'package:flutter/material.dart';
import '../models/extras.dart';
import '../models/product.dart';
import '../state/app_scope.dart';
import '../state/cart_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_image.dart';
import '../widgets/bebidas_sheet.dart';
import '../widgets/extras_picker.dart';
import '../widgets/primary_button.dart';
import 'payment_screen.dart';
import '../models/precio.dart';

class CartScreen extends StatelessWidget {
  /// Para el botón del carrito vacío.
  final VoidCallback? onVerMenu;

  /// Se llama cuando el pago sale bien, para saltar a "Mis pedidos".
  final VoidCallback? onPedidoEnviado;

  const CartScreen({super.key, this.onVerMenu, this.onPedidoEnviado});

  @override
  Widget build(BuildContext context) {
    final carrito = AppScope.carrito(context);

    return Container(
      color: AppColors.crema,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
            color: Colors.white,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                    child: Text('Tu carrito',
                        style: AppTextStyles.heading(size: 19))),
                if (!carrito.estaVacio)
                  GestureDetector(
                    onTap: () => _confirmarVaciar(context, carrito),
                    child: Text('Vaciar',
                        style: AppTextStyles.body(
                            size: 11.5, color: AppColors.tomate)),
                  ),
              ],
            ),
          ),
          Expanded(
            child: carrito.estaVacio
                ? _CarritoVacio(onVerMenu: onVerMenu)
                : ListView(
                    padding: const EdgeInsets.all(18),
                    children: [
                      ...carrito.lineas.map(
                        (linea) =>
                            _LineaCarrito(linea: linea, carrito: carrito),
                      ),
                      // Las bebidas se escogen aquí, no en el menú.
                      _SeccionBebidas(carrito: carrito),
                      const SizedBox(height: 12),
                      _Resumen(carrito: carrito),
                    ],
                  ),
          ),
          if (!carrito.estaVacio)
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
              child: PrimaryButton(
                label: 'Continuar al pago · ${formatoPesos(carrito.total)}',
                onPressed: () => _irAPagar(context, carrito),
              ),
            ),
        ],
      ),
    );
  }

  /// Lleva al pago y, si el comprobante se envió, vacía el carrito y
  /// manda al cliente a "Mis pedidos".
  Future<void> _irAPagar(BuildContext context, CartModel carrito) async {
    final enviado = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => PaymentScreen(total: carrito.total)),
    );

    if (enviado == true) {
      carrito.vaciar();
      onPedidoEnviado?.call();
    }
  }

  Future<void> _confirmarVaciar(BuildContext context, CartModel carrito) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title:
            Text('¿Vaciar el carrito?', style: AppTextStyles.heading(size: 15)),
        content: Text('Se quitan todos los productos que agregaste.',
            style: AppTextStyles.body(size: 12.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('No', style: AppTextStyles.body(size: 12.5)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Sí, vaciar',
                style:
                    AppTextStyles.heading(size: 12.5, color: AppColors.tomate)),
          ),
        ],
      ),
    );
    if (confirmado == true) carrito.vaciar();
  }
}

class _LineaCarrito extends StatelessWidget {
  final CartLine linea;
  final CartModel carrito;

  const _LineaCarrito({required this.linea, required this.carrito});

  Future<void> _editarSalsas(BuildContext context) async {
    final nuevas = await editarExtras(
      context: context,
      titulo: 'Salsas de ${linea.product.name}',
      subtitulo: 'Elige todas las que quieras',
      catalogo: kSalsas,
      seleccionados: linea.salsas,
    );
    if (nuevas != null) carrito.actualizarSalsas(linea, nuevas);
  }

  /// Cambia la opción del producto (queso/tocineta, pollo/cerdo…) sin
  /// tener que sacarlo del carrito y volverlo a agregar.
  Future<void> _editarOpciones(BuildContext context) async {
    for (final variante in linea.product.variantes) {
      if (!context.mounted) return;
      final elegida = await showModalBottomSheet<String>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => _HojaOpciones(
          variante: variante,
          actual: linea.opciones[variante.titulo],
        ),
      );
      if (elegida != null) {
        carrito.actualizarOpcion(linea, variante.titulo, elegida);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppImage(
                linea.product.imageAsset,
                fallbackUrl: linea.product.imageUrl,
                placeholderIcon: iconoDeCategoria(linea.product.category),
                width: 62,
                height: 62,
                borderRadius: BorderRadius.circular(12),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(linea.product.name,
                        style: AppTextStyles.heading(size: 13)),
                    const SizedBox(height: 2),
                    Text(linea.resumen,
                        style: AppTextStyles.body(
                            size: 11, color: AppColors.muted)),
                    const SizedBox(height: 4),
                    Text(
                      '${formatoPesos(linea.precioUnitario)} c/u',
                      style: AppTextStyles.body(
                          size: 11, color: AppColors.mostaza),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => carrito.eliminar(linea),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.tomate.withAlpha(25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.delete_outline_rounded,
                      size: 18, color: AppColors.tomate),
                ),
              ),
            ],
          ),
          if (linea.salsas.isNotEmpty ||
              linea.adiciones.isNotEmpty ||
              linea.opciones.isNotEmpty) ...[
            const SizedBox(height: 10),
            // Lo que eligió: queso/tocineta, pollo/cerdo, sabor…
            for (final o in linea.opciones.entries)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: _LineaDetalle(
                  icono: Icons.tune_rounded,
                  etiqueta: o.key,
                  texto: o.value,
                ),
              ),
            if (linea.salsas.isNotEmpty)
              _ListaExtras(
                icono: Icons.water_drop_outlined,
                etiqueta: 'Salsas',
                extras: linea.salsas,
              ),
            if (linea.adiciones.isNotEmpty) ...[
              const SizedBox(height: 4),
              _ListaExtras(
                icono: Icons.add_circle_outline,
                etiqueta: 'Adiciones',
                extras: linea.adiciones,
              ),
            ],
          ],
          // ── Personalización: solo para la comida ──
          // Las adiciones NO están aquí: se escogen en la ficha del
          // producto, con la foto del plato a la vista.
          if (linea.product.permiteSalsas ||
              linea.product.tieneVariantes) ...[
            const SizedBox(height: 12),
            Text('Personaliza tu pedido',
                style:
                    AppTextStyles.heading(size: 11.5, color: AppColors.muted)),
            const SizedBox(height: 8),
            if (linea.product.tieneVariantes) ...[
              _BotonEditar(
                icono: Icons.tune_rounded,
                label: 'Opciones: ${linea.opciones.values.join(', ')}',
                onTap: () => _editarOpciones(context),
              ),
              const SizedBox(height: 8),
            ],
            if (linea.product.permiteSalsas)
              _BotonEditar(
                icono: Icons.water_drop_outlined,
                label: linea.salsas.isEmpty
                    ? 'Salsas'
                    : 'Salsas (${linea.salsas.length})',
                onTap: () => _editarSalsas(context),
              ),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: AppColors.borde),
          ),
          Row(
            children: [
              _QtyButton(
                  icon: Icons.remove,
                  onTap: () => carrito.cambiarCantidad(linea, -1)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Text('${linea.cantidad}',
                    style: AppTextStyles.heading(size: 14)),
              ),
              _QtyButton(
                  icon: Icons.add,
                  onTap: () => carrito.cambiarCantidad(linea, 1)),
              const Spacer(),
              Text(formatoPesos(linea.total),
                  style:
                      AppTextStyles.heading(size: 15, color: AppColors.carbon)),
            ],
          ),
        ],
      ),
    );
  }
}

/// Fila de detalle de una línea (gaseosa, notas, etc.).
class _LineaDetalle extends StatelessWidget {
  final IconData icono;
  final String etiqueta;
  final String texto;

  const _LineaDetalle({
    required this.icono,
    required this.etiqueta,
    required this.texto,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icono, size: 13, color: AppColors.mostaza),
        const SizedBox(width: 6),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: AppTextStyles.body(size: 11, color: AppColors.muted),
              children: [
                TextSpan(
                  text: '$etiqueta: ',
                  style: AppTextStyles.heading(
                      size: 10.5, color: AppColors.carbon),
                ),
                TextSpan(text: texto),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ListaExtras extends StatelessWidget {
  final IconData icono;
  final String etiqueta;
  final Set<Extra> extras;

  const _ListaExtras({
    required this.icono,
    required this.etiqueta,
    required this.extras,
  });

  @override
  Widget build(BuildContext context) {
    final texto = extras
        .map((e) =>
            e.esGratis ? e.nombre : '${e.nombre} +${formatoPesos(e.precio)}')
        .join(' · ');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icono, size: 13, color: AppColors.mostaza),
        const SizedBox(width: 6),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: AppTextStyles.body(size: 11, color: AppColors.muted),
              children: [
                TextSpan(
                  text: '$etiqueta: ',
                  style: AppTextStyles.heading(
                      size: 10.5, color: AppColors.carbon),
                ),
                TextSpan(text: texto),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BotonEditar extends StatelessWidget {
  final IconData icono;
  final String label;
  final VoidCallback onTap;

  const _BotonEditar(
      {required this.icono, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.crema,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: AppColors.borde),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icono, size: 14, color: AppColors.mostaza),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body(size: 11.5, weight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Resumen extends StatelessWidget {
  final CartModel carrito;
  const _Resumen({required this.carrito});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          _SummaryRow(
            label: '${carrito.cantidadTotal} '
                '${carrito.cantidadTotal == 1 ? "producto" : "productos"}',
            value: carrito.subtotal,
          ),
          const SizedBox(height: 6),
          _SummaryRow(label: 'Domicilio', value: carrito.domicilio),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: AppTextStyles.heading(size: 14)),
              Text(formatoPesos(carrito.total),
                  style: AppTextStyles.heading(size: 16, color: AppColors.verde)),
            ],
          ),
        ],
      ),
    );
  }
}

class _CarritoVacio extends StatelessWidget {
  final VoidCallback? onVerMenu;
  const _CarritoVacio({this.onVerMenu});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.shopping_cart_outlined,
                size: 48, color: AppColors.borde),
            const SizedBox(height: 12),
            Text('Tu carrito está vacío',
                style: AppTextStyles.heading(size: 15)),
            const SizedBox(height: 4),
            Text(
              'Agrega algo rico del menú y aquí lo ves',
              textAlign: TextAlign.center,
              style: AppTextStyles.body(size: 12.5, color: AppColors.muted),
            ),
            if (onVerMenu != null) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: 180,
                child:
                    PrimaryButton(label: 'Ver el menú', onPressed: onVerMenu),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.crema2,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: AppColors.borde),
        ),
        child: Icon(icon, size: 15, color: AppColors.carbon),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final int value;
  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: AppTextStyles.body(size: 12.5, color: AppColors.muted)),
        Text(formatoPesos(value), style: AppTextStyles.body(size: 12.5)),
      ],
    );
  }
}

/// Hoja para cambiar una opción del producto desde el carrito.
class _HojaOpciones extends StatelessWidget {
  final Variante variante;
  final String? actual;

  const _HojaOpciones({required this.variante, this.actual});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.crema,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(variante.titulo, style: AppTextStyles.heading(size: 15)),
          const SizedBox(height: 12),
          ...variante.opciones.map(
            (o) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(o.nombre),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: o.nombre == actual
                        ? const Color(0xFFFBF1DF)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: o.nombre == actual
                          ? AppColors.mostaza
                          : AppColors.borde,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        o.nombre == actual
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        size: 17,
                        color: o.nombre == actual
                            ? AppColors.mostaza
                            : AppColors.muted,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(o.nombre,
                            style: AppTextStyles.body(
                                size: 12.5, weight: FontWeight.w600)),
                      ),
                      Text(formatoPesos(o.precio),
                          style: AppTextStyles.heading(
                              size: 12, color: AppColors.muted)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Sección "Bebidas" del carrito: desde aquí se abre la lista de bebidas.
/// Si ya hay alguna en el pedido, la nombra para que no se agregue doble
/// sin darse cuenta.
class _SeccionBebidas extends StatelessWidget {
  final CartModel carrito;
  const _SeccionBebidas({required this.carrito});

  @override
  Widget build(BuildContext context) {
    final enElCarrito = carrito.lineas
        .where((l) => l.product.category == kCategoriaBebidas)
        .toList();

    return GestureDetector(
      onTap: () => mostrarBebidas(context),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borde),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.crema2,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.local_drink_outlined,
                  size: 19, color: AppColors.mostaza),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Bebidas', style: AppTextStyles.heading(size: 13)),
                  const SizedBox(height: 2),
                  Text(
                    enElCarrito.isEmpty
                        ? 'Agrégale algo de tomar'
                        : enElCarrito
                            .map((l) => '${l.cantidad} × ${l.product.name}')
                            .join(' · '),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body(size: 11, color: AppColors.muted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: AppColors.mostaza,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}
