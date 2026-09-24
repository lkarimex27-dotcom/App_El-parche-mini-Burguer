import 'dart:math';

import 'package:flutter/material.dart';
import '../models/business_info.dart';
import '../services/enlaces.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// El mapa de "Dónde estamos": muestra dónde queda el local y al tocarlo
/// abre la app de mapas del celular con la ruta.
///
/// Está armado con los mosaicos públicos de OpenStreetMap en vez de Google
/// Maps para no tener que manejar una llave de API ni sumar un paquete
/// nativo: son imágenes normales y el pin se dibuja encima.
class MapaNegocio extends StatelessWidget {
  /// Cuánto se acerca. 16 se ve la cuadra, 17 la esquina.
  final int zoom;
  final double alto;

  const MapaNegocio({super.key, this.zoom = 16, this.alto = 170});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Enlaces.abrirMaps(context, BusinessInfo.direccion),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: alto,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              const ColoredBox(color: AppColors.crema2),
              LayoutBuilder(
                builder: (context, restricciones) => _Mosaicos(
                  ancho: restricciones.maxWidth,
                  alto: alto,
                  zoom: zoom,
                ),
              ),
              // El pin va fijo en el centro: los mosaicos se corren para
              // que el local quede justo debajo.
              const Center(
                child: Padding(
                  // La punta del pin es la que señala, no su centro.
                  padding: EdgeInsets.only(bottom: 26),
                  child: Icon(Icons.location_on,
                      size: 34, color: AppColors.tomate),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  color: Colors.white.withValues(alpha: 0.88),
                  child: Row(
                    children: [
                      const Icon(Icons.directions_rounded,
                          size: 15, color: AppColors.mostaza),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text('Toca para abrir en tu app de mapas',
                            style: AppTextStyles.body(
                                size: 10.5, color: AppColors.carbon)),
                      ),
                      // Los mosaicos son de OpenStreetMap y su licencia
                      // pide dejar el crédito a la vista.
                      Text('© OpenStreetMap',
                          style: AppTextStyles.body(
                              size: 8.5, color: AppColors.muted)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Pinta los mosaicos que hacen falta para llenar el recuadro, corridos de
/// modo que las coordenadas del negocio caigan justo en el centro.
class _Mosaicos extends StatelessWidget {
  final double ancho;
  final double alto;
  final int zoom;

  const _Mosaicos({
    required this.ancho,
    required this.alto,
    required this.zoom,
  });

  static const double _lado = 256;

  @override
  Widget build(BuildContext context) {
    // Web Mercator: de grados a "cuántos mosaicos" hay hasta ese punto.
    final n = pow(2, zoom).toDouble();
    const latRad = BusinessInfo.latitud * pi / 180;
    final x = (BusinessInfo.longitud + 180) / 360 * n;
    final y = (1 - log(tan(latRad) + 1 / cos(latRad)) / pi) / 2 * n;

    // Píxel del mundo que debe quedar en la esquina de arriba a la izquierda.
    final origenX = x * _lado - ancho / 2;
    final origenY = y * _lado - alto / 2;

    final desdeX = (origenX / _lado).floor();
    final hastaX = ((origenX + ancho) / _lado).floor();
    final desdeY = (origenY / _lado).floor();
    final hastaY = ((origenY + alto) / _lado).floor();
    final maximo = n.toInt();

    final mosaicos = <Widget>[];
    for (var tx = desdeX; tx <= hastaX; tx++) {
      for (var ty = desdeY; ty <= hastaY; ty++) {
        // Fuera del mundo no hay mosaico; en horizontal da la vuelta.
        if (ty < 0 || ty >= maximo) continue;
        final txReal = tx % maximo;

        mosaicos.add(Positioned(
          left: tx * _lado - origenX,
          top: ty * _lado - origenY,
          width: _lado,
          height: _lado,
          child: Image.network(
            'https://tile.openstreetmap.org/$zoom/$txReal/$ty.png',
            // OpenStreetMap pide identificarse para servir los mosaicos.
            headers: const {'User-Agent': 'ElParcheMiniBurguer/1.0'},
            fit: BoxFit.cover,
            // Sin internet el mapa queda en el fondo crema, sin romperse.
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
        ));
      }
    }

    return Stack(clipBehavior: Clip.hardEdge, children: mosaicos);
  }
}
