import 'package:flutter/material.dart';
import '../models/documento.dart';
import '../state/app_scope.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/primary_button.dart';
import 'addresses_screen.dart';
import 'contact_screen.dart';
import 'favorites_screen.dart';
import 'login_screen.dart';
import 'orders_screen.dart';
import 'profile_data_screen.dart';

class ProfileScreen extends StatelessWidget {
  /// Cierra el perfil y devuelve al Inicio (la flecha de arriba).
  final VoidCallback? onCerrar;

  const ProfileScreen({super.key, this.onCerrar});

  @override
  Widget build(BuildContext context) {
    final usuario = AppScope.usuario(context);
    final pedidos = AppScope.pedidos(context);
    final favoritos = usuario.favoritos.length;
    final direcciones = usuario.direcciones.length;
    final tipoDoc = tipoDocumentoPorCodigo(usuario.tipoDocumento);

    return Container(
      color: AppColors.crema,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          // Cabecera con los datos de la cuenta
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 22),
            decoration: const BoxDecoration(gradient: AppColors.ambarMostaza),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: onCerrar ?? () => Navigator.of(context).maybePop(),
                    tooltip: 'Cerrar perfil',
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),
                Container(
                  width: 64,
                  height: 64,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    usuario.iniciales,
                    style: AppTextStyles.heading(size: 20, color: AppColors.mostaza),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  usuario.nombre.isEmpty ? 'Tu cuenta' : usuario.nombre,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.heading(size: 14, color: Colors.white),
                ),
                if (usuario.email.isNotEmpty)
                  Text(usuario.email,
                      style: AppTextStyles.body(size: 11.5, color: Colors.white)),
                if (usuario.telefono.isNotEmpty)
                  Text(usuario.telefono,
                      style: AppTextStyles.body(size: 11.5, color: Colors.white)),
                if (usuario.documento.isNotEmpty)
                  Text(
                    '${tipoDoc?.codigo ?? ''} ${usuario.documento}'.trim(),
                    style: AppTextStyles.body(size: 11.5, color: Colors.white),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                // Material (y no Container) para que el ListTile pueda
                // pintar su fondo y el efecto de toque.
                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      _ProfileTile(
                        icon: Icons.person_outline_rounded,
                        label: 'Mis datos',
                        detalle: 'Nombre, documento, correo y teléfono',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const ProfileDataScreen()),
                        ),
                      ),
                      const Divider(height: 1),
                      _ProfileTile(
                        icon: Icons.location_on_outlined,
                        label: 'Direcciones guardadas',
                        detalle: direcciones == 0
                            ? 'Agrega tu primera dirección'
                            : direcciones == 1
                                ? '1 dirección'
                                : '$direcciones direcciones',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const AddressesScreen()),
                        ),
                      ),
                      const Divider(height: 1),
                      _ProfileTile(
                        icon: Icons.receipt_long_outlined,
                        label: 'Historial de pedidos',
                        detalle: pedidos.estaVacio
                            ? 'Todavía no has pedido'
                            : '${pedidos.pedidos.length} pedidos',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const OrdersHistoryPage()),
                        ),
                      ),
                      const Divider(height: 1),
                      _ProfileTile(
                        icon: Icons.star_border_rounded,
                        label: 'Favoritos',
                        detalle: favoritos == 0
                            ? 'Sin favoritos todavía'
                            : '$favoritos guardados',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const FavoritesScreen()),
                        ),
                      ),
                      const Divider(height: 1),
                      _ProfileTile(
                        icon: Icons.support_agent_rounded,
                        label: 'Contactar al negocio',
                        detalle: 'WhatsApp, teléfono y redes',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const ContactScreen()),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                PrimaryButton(
                  label: 'Cerrar sesión',
                  color: Colors.white,
                  colorTexto: AppColors.tomate,
                  onPressed: () => _confirmarSalida(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmarSalida(BuildContext context) async {
    final navigator = Navigator.of(context);
    final usuario = AppScope.usuarioSinEscuchar(context);
    final carrito = AppScope.carritoSinEscuchar(context);

    final salir = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text('¿Cerrar sesión?', style: AppTextStyles.heading(size: 14)),
        content: Text('Vas a volver a la pantalla de inicio de sesión.',
            style: AppTextStyles.body(size: 12.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancelar', style: AppTextStyles.body(size: 12.5)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Cerrar sesión',
                style: AppTextStyles.heading(size: 12.5, color: AppColors.tomate)),
          ),
        ],
      ),
    );

    if (salir == true) {
      usuario.cerrarSesion();
      carrito.vaciar();
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String detalle;
  final VoidCallback onTap;

  const _ProfileTile({
    required this.icon,
    required this.label,
    required this.detalle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.mostaza, size: 20),
      title: Text(label, style: AppTextStyles.body(size: 12.5, weight: FontWeight.w600)),
      subtitle: Text(detalle, style: AppTextStyles.body(size: 11, color: AppColors.muted)),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
      onTap: onTap,
    );
  }
}
