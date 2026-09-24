import 'package:flutter/material.dart';
import '../../models/rol.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../models/permisos.dart';
import '../widgets/admin_states.dart';

/// Los módulos que no caben en el bottom nav. Solo se listan los que el
/// rol puede ver: lo que no tiene permiso, no aparece.
class MasScreen extends StatelessWidget {
  final Rol rol;
  final void Function(ModuloAdmin modulo) onAbrirModulo;

  const MasScreen({super.key, required this.rol, required this.onAbrirModulo});

  static const List<ModuloAdmin> _enLaBarra = [
    ModuloAdmin.dashboard,
    ModuloAdmin.pedidos,
    ModuloAdmin.produccion,
    ModuloAdmin.inventario,
  ];

  static const List<_Grupo> _grupos = [
    _Grupo('Abastecimiento', [
      ModuloAdmin.compras,
      ModuloAdmin.proveedores,
      ModuloAdmin.perdidas,
    ]),
    _Grupo('Catálogo', [
      ModuloAdmin.productos,
      ModuloAdmin.categorias,
      ModuloAdmin.fichasTecnicas,
    ]),
    _Grupo('Comercial', [
      ModuloAdmin.ventas,
      ModuloAdmin.clientes,
      ModuloAdmin.devoluciones,
      ModuloAdmin.indicadores,
    ]),
    _Grupo('Administración', [
      ModuloAdmin.usuarios,
      ModuloAdmin.roles,
      ModuloAdmin.perfil,
      ModuloAdmin.configuracion,
    ]),
  ];

  @override
  Widget build(BuildContext context) {
    final grupos = [
      for (final g in _grupos)
        _Grupo(
          g.titulo,
          g.modulos
              .where((m) => !_enLaBarra.contains(m) && puedeVer(rol, m))
              .toList(),
        )
    ].where((g) => g.modulos.isNotEmpty).toList();

    return Container(
      color: AppColors.crema,
      child: grupos.isEmpty
          ? const Center(
              child: AdminEmptyState(
                icono: Icons.lock_outline_rounded,
                titulo: 'No tienes más módulos',
                detalle: 'Tu rol solo trabaja con las pestañas de abajo.',
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              children: [
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFB68C1C), Color(0xFFD29A42)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(28),
                      bottomRight: Radius.circular(28),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.grid_view_rounded,
                              color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Text('Más',
                              style: AppTextStyles.heading(
                                  size: 22, color: Colors.white)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(28),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Panel de servicios ${rol.label}',
                          style: AppTextStyles.body(
                              size: 12,
                              color: Colors.white,
                              weight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                for (final grupo in grupos) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(grupo.titulo.toUpperCase(),
                        style: AppTextStyles.body(
                            size: 11,
                            color: AppColors.muted,
                            weight: FontWeight.w700)),
                  ),
                  _ModuloGrid(
                    modulos: grupo.modulos,
                    onAbrirModulo: onAbrirModulo,
                  ),
                  const SizedBox(height: 20),
                ],
              ],
            ),
    );
  }
}

class _ModuloGrid extends StatelessWidget {
  final List<ModuloAdmin> modulos;
  final void Function(ModuloAdmin modulo) onAbrirModulo;

  const _ModuloGrid({
    required this.modulos,
    required this.onAbrirModulo,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: modulos.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.86,
      ),
      itemBuilder: (context, index) {
        final modulo = modulos[index];
        return _ModuloCard(
          modulo: modulo,
          onTap: () => onAbrirModulo(modulo),
        );
      },
    );
  }
}

class _ModuloCard extends StatelessWidget {
  final ModuloAdmin modulo;
  final VoidCallback onTap;

  const _ModuloCard({required this.modulo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(34),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: AppColors.crema2,
                  shape: BoxShape.circle,
                ),
                child: Icon(modulo.icono, color: AppColors.mostaza, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                modulo.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body(
                    size: 11, weight: FontWeight.w700, color: AppColors.carbon),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Grupo {
  final String titulo;
  final List<ModuloAdmin> modulos;
  const _Grupo(this.titulo, this.modulos);
}
