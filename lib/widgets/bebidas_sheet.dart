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
              width: 62,
              height: 62,
              enVitrina: true,
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

          final foto = p.fotoDe(sabor);

          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borde),
            ),
            // Columna y no una sola fila: los sabores van debajo, a todo lo
            // ancho. Metidos en la fila no cabían y la desbordaban.
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AppImage(
                      // La botella de este sabor y este tamaño si la hay; si
                      // no, la de la marca. Nunca la del producto del menú,
                      // que agrupa varias marcas.
                      foto.isEmpty ? marca.imageAsset : foto,
                      placeholderIcon: Icons.local_drink,
                      width: 62,
                      height: 62,
                      // Las botellas son mucho más altas que anchas:
                      // recortadas se vería solo el centro, sin tapa ni base.
                      enVitrina: true,
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
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _BotonAgregar(onTap: () => _agregar(context, p)),
                  ],
                ),
                // Cuando el tamaño tiene varios sabores, se escoge aquí
                // mismo en vez de repetir la fila por cada sabor.
                if (p.pideSabor) ...[
                  const SizedBox(height: 10),
                  _SelectorSabor(
                    sabores: p.sabores,
                    elegido: sabor ?? p.sabores.first,
                    onElegir: (nuevo) =>
                        setState(() => _sabor[p.tamano] = nuevo),
                  ),
                ],
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
/// El botón redondo de agregar, como el de las apps de domicilios. Ocupa
/// mucho menos que uno con texto, que es lo que desbordaba la fila en los
/// celulares angostos.
class _BotonAgregar extends StatelessWidget {
  final VoidCallback onTap;
  const _BotonAgregar({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Agregar al carrito',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(100),
        child: Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.mostaza,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}

/// Los sabores de un tamaño, como fichas que se envuelven solas. Antes era
/// un desplegable, pero no cabía al lado del botón y desbordaba la fila; en
/// fichas se ve de una cuáles hay y cuál está elegido.
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
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final sabor in sabores)
          GestureDetector(
            onTap: () => onElegir(sabor),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color:
                    sabor == elegido ? AppColors.mostaza : AppColors.crema,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color:
                      sabor == elegido ? AppColors.mostaza : AppColors.borde,
                ),
              ),
              child: Text(
                sabor,
                style: AppTextStyles.body(
                  size: 11.5,
                  weight: FontWeight.w600,
                  color: sabor == elegido ? Colors.white : AppColors.carbon,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
