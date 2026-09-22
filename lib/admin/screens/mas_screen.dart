import 'package:flutter/material.dart';
import '../../models/rol.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../models/permisos.dart';
import '../widgets/admin_card.dart';
import '../widgets/admin_states.dart';

/// Los módulos que no caben en el bottom nav. Solo se listan los que el
/// rol puede ver: lo que no tiene permiso, no aparece.
class MasScreen extends StatelessWidget {
  final Rol rol;
  final void Function(ModuloAdmin modulo) onAbrirModulo;

  const MasScreen({super.key, required this.rol, required this.onAbrirModulo});

  /// Los de la barra inferior no se repiten aquí.
  static const List<ModuloAdmin> _enLaBarra = [
    ModuloAdmin.dashboard,
    ModuloAdmin.pedidos,
    ModuloAdmin.produccion,
    ModuloAdmin.inventario,
  ];

  static const List<_Grupo> _grupos = [
    _Grupo('Catálogo', [
      ModuloAdmin.productos,
      ModuloAdmin.categorias,
      ModuloAdmin.fichasTecnicas,
    ]),
    _Grupo('Abastecimiento', [
      ModuloAdmin.compras,
      ModuloAdmin.proveedores,
      ModuloAdmin.perdidas,
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
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                Text('Más', style: AppTextStyles.heading(size: 22)),
                const SizedBox(height: 2),
                Text('Módulos disponibles para ${rol.label}',
                    style: AppTextStyles.body(size: 13, color: AppColors.muted)),
                const SizedBox(height: 18),
                for (final grupo in grupos) ...[
                  Text(grupo.titulo.toUpperCase(),
                      style:
                          AppTextStyles.body(size: 11, color: AppColors.muted)),
                  const SizedBox(height: 8),
                  AdminCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        for (var i = 0; i < grupo.modulos.length; i++) ...[
                          if (i > 0)
                            const Divider(height: 1, color: AppColors.borde),
                          _FilaModulo(
                            modulo: grupo.modulos[i],
                            onTap: () => onAbrirModulo(grupo.modulos[i]),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                ],
              ],
            ),
    );
  }
}

class _Grupo {
  final String titulo;
  final List<ModuloAdmin> modulos;
  const _Grupo(this.titulo, this.modulos);
}

class _FilaModulo extends StatelessWidget {
  final ModuloAdmin modulo;
  final VoidCallback onTap;

  const _FilaModulo({required this.modulo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.crema2,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Icon(modulo.icono, size: 18, color: AppColors.mostaza),
      ),
      title: Text(modulo.label,
          style: AppTextStyles.body(size: 13.5, weight: FontWeight.w600)),
      trailing:
          const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
    );
  }
}
