import 'package:flutter/material.dart';
import '../models/product.dart';
import '../state/app_scope.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'app_form_field.dart';
import 'app_image.dart';
import '../models/precio.dart';

/// Las bebidas que se abren desde el carrito, en dos pasos: primero la
/// marca (Coca-Cola, Postobón, Hit…) y después el tamaño y el sabor.
/// Así el cliente escoge como piensa —"quiero una Coca-Cola, grande"—
/// en vez de tener que buscar su marca dentro de cada presentación.
Future<void> mostrarBebidas(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _HojaMarcas(),
  );
}

/// La cáscara común de las dos hojas: fondo crema, esquinas redondeadas,
/// el agarrador de arriba y el título.
class _Hoja extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final Widget hijo;
  final double alto;

  const _Hoja({
    required this.titulo,
    required this.subtitulo,
    required this.hijo,
    this.alto = 0.75,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: alto,
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
            Text(titulo, style: AppTextStyles.heading(size: 16)),
            const SizedBox(height: 2),
            Text(subtitulo,
                style: AppTextStyles.body(size: 11.5, color: AppColors.muted)),
            const SizedBox(height: 14),
            Expanded(
              child: PrimaryScrollController(
                controller: scrollController,
                child: hijo,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────── Paso 1: la marca ───────────────────────────

class _HojaMarcas extends StatelessWidget {
  const _HojaMarcas();

  @override
  Widget build(BuildContext context) {
    final marcas = bebidasPorMarca();

    return _Hoja(
      titulo: 'Bebidas',
      subtitulo: 'Elige la marca y después el tamaño',
      hijo: ListView.separated(
        primary: true,
        itemCount: marcas.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) => _TarjetaMarca(marca: marcas[i]),
      ),
    );
  }
}

class _TarjetaMarca extends StatelessWidget {
  final MarcaBebida marca;
  const _TarjetaMarca({required this.marca});

  @override
  Widget build(BuildContext context) {
    final cuantas = marca.presentaciones.length;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _HojaTamanos(marca: marca),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borde),
        ),
        child: Row(
          children: [
            AppImage(
              marca.imageAsset,
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
                  Text(marca.nombre,
                      style: AppTextStyles.heading(size: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(
                    '$cuantas ${cuantas == 1 ? 'presentación' : 'presentaciones'}',
                    style: AppTextStyles.body(size: 11, color: AppColors.muted),
                  ),
                  const SizedBox(height: 2),
                  Text('Desde ${formatoPesos(marca.desde)}',
                      style: AppTextStyles.heading(
                          size: 12.5, color: AppColors.verde)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.muted, size: 22),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────── Paso 2: tamaño y sabor ───────────────────────

class _HojaTamanos extends StatefulWidget {
  final MarcaBebida marca;
  const _HojaTamanos({required this.marca});

  @override
  State<_HojaTamanos> createState() => _HojaTamanosState();
}

class _HojaTamanosState extends State<_HojaTamanos> {
  /// El sabor elegido en cada fila, por tamaño. Arranca en el primero.
  late final Map<String, String> _sabor = {
    for (final p in widget.marca.presentaciones)
      if (p.sabores.isNotEmpty) p.tamano: p.sabores.first,
  };

  MarcaBebida get marca => widget.marca;

  void _agregar(BuildContext context, PresentacionBebida p) {
    final messenger = ScaffoldMessenger.of(context);
    final navegador = Navigator.of(context);
    final sabor = _sabor[p.tamano];

    AppScope.carritoSinEscuchar(context).agregar(
      product: p.producto,
      opciones: Map<String, String>.from(p.opcionesCon(sabor)),
    );

    // Se cierran las dos hojas: la de tamaños y la de marcas.
    navegador.pop();
    navegador.pop();
    avisarExitoEn(messenger, '${marca.nombre} ${p.tamano} al carrito');
  }

  @override
  Widget build(BuildContext context) {
    return _Hoja(
      titulo: marca.nombre,
      subtitulo: 'Escoge el tamaño que quieres',
      alto: 0.6,
      hijo: ListView.separated(
        primary: true,
        itemCount: marca.presentaciones.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final p = marca.presentaciones[i];
          final sabor = _sabor[p.tamano];
          // Con un solo sabor no hay nada que escoger, y solo se nombra si
          // dice algo distinto de la marca ("Manzana" sí, "Coca-Cola"
          // dentro de Coca-Cola no).
          final mostrarSabor =
              !p.pideSabor && sabor != null && sabor != marca.nombre;

          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borde),
            ),
            child: Row(
              children: [
                AppImage(
                  // La de la marca, no la del producto: un mismo producto
                  // del menú agrupa varias marcas.
                  marca.imageAsset,
                  placeholderIcon: Icons.local_drink,
                  width: 50,
                  height: 50,
                  borderRadius: BorderRadius.circular(10),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.tamano.isEmpty ? p.producto.name : p.tamano,
                        style: AppTextStyles.heading(size: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (mostrarSabor) ...[
                        const SizedBox(height: 2),
                        Text(sabor,
                            style: AppTextStyles.body(
                                size: 11, color: AppColors.muted),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ],
                      const SizedBox(height: 2),
                      Text(formatoPesos(p.precio),
                          style: AppTextStyles.heading(
                              size: 12.5, color: AppColors.verde)),
                      // Cuando el tamaño tiene varios sabores, se escoge
                      // aquí mismo en vez de repetir la fila por sabor.
                      if (p.pideSabor) ...[
                        const SizedBox(height: 6),
                        _SelectorSabor(
                          sabores: p.sabores,
                          elegido: sabor ?? p.sabores.first,
                          onElegir: (nuevo) =>
                              setState(() => _sabor[p.tamano] = nuevo),
                        ),
                      ],
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => _agregar(context, p),
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.mostaza,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100)),
                  ),
                  child: Text('Agregar',
                      style: AppTextStyles.heading(
                          size: 11.5, color: Colors.white)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// El seleccionador de sabor: un menú pequeño dentro de la fila del tamaño.
/// Se usa solo cuando esa marca tiene más de un sabor en ese tamaño.
class _SelectorSabor extends StatelessWidget {
  final List<String> sabores;
  final String elegido;
  final ValueChanged<String> onElegir;

  const _SelectorSabor({
    required this.sabores,
    required this.elegido,
    required this.onElegir,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.crema,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColors.borde),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: elegido,
          isDense: true,
          borderRadius: BorderRadius.circular(12),
          icon: const Icon(Icons.expand_more_rounded,
              size: 18, color: AppColors.mostaza),
          style: AppTextStyles.body(size: 11.5, weight: FontWeight.w600),
          dropdownColor: Colors.white,
          items: [
            for (final sabor in sabores)
              DropdownMenuItem(value: sabor, child: Text(sabor)),
          ],
          onChanged: (nuevo) {
            if (nuevo != null) onElegir(nuevo);
          },
        ),
      ),
    );
  }
}
