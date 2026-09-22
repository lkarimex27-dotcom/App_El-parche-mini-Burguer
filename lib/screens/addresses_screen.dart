import 'package:flutter/material.dart';
import '../state/app_scope.dart';
import '../state/user_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_form_field.dart';
import '../widgets/primary_button.dart';

/// "Direcciones guardadas": agregar, editar, borrar y elegir a cuál
/// llega el domicilio.
class AddressesScreen extends StatelessWidget {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final usuario = AppScope.usuario(context);
    final direcciones = usuario.direcciones;

    return Scaffold(
      backgroundColor: AppColors.crema,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.carbon),
        title: Text('Direcciones guardadas', style: AppTextStyles.heading(size: 15)),
      ),
      body: direcciones.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_off_outlined,
                        size: 44, color: AppColors.borde),
                    const SizedBox(height: 12),
                    Text('Todavía no tienes direcciones',
                        style: AppTextStyles.heading(size: 13.5)),
                    const SizedBox(height: 4),
                    Text(
                      'Agrega una para que el domicilio llegue más rápido',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body(size: 12, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 90),
              itemCount: direcciones.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final direccion = direcciones[index];
                final principal = usuario.esPrincipal(direccion);

                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: principal ? AppColors.mostaza : AppColors.borde,
                      width: principal ? 1.6 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 17, color: AppColors.mostaza),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(direccion.alias,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.heading(size: 12.5)),
                          ),
                          const SizedBox(width: 8),
                          if (principal)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.verde,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Text('Principal',
                                  style: AppTextStyles.heading(
                                      size: 9, color: Colors.white)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(direccion.detalle, style: AppTextStyles.body(size: 12)),
                      if (direccion.indicaciones != null &&
                          direccion.indicaciones!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(direccion.indicaciones!,
                            style: AppTextStyles.body(
                                size: 11, color: AppColors.muted)),
                      ],
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          if (!principal)
                            _AccionTexto(
                              label: 'Usar esta',
                              onTap: () => usuario.marcarPrincipal(direccion),
                            ),
                          if (!principal) const SizedBox(width: 16),
                          _AccionTexto(
                            label: 'Editar',
                            onTap: () => _abrirFormulario(
                              context,
                              usuario,
                              direccion: direccion,
                            ),
                          ),
                          const Spacer(),
                          _AccionTexto(
                            label: 'Eliminar',
                            color: AppColors.tomate,
                            onTap: () => _confirmarEliminar(context, usuario, direccion),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.mostaza,
        foregroundColor: Colors.white,
        onPressed: () => _abrirFormulario(context, usuario),
        icon: const Icon(Icons.add, size: 20),
        label: Text('Agregar',
            style: AppTextStyles.heading(size: 12.5, color: Colors.white)),
      ),
    );
  }

  Future<void> _confirmarEliminar(
    BuildContext context,
    UserModel usuario,
    Direccion direccion,
  ) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text('¿Eliminar "${direccion.alias}"?',
            style: AppTextStyles.heading(size: 14)),
        content: Text('Esta dirección se quita de tu cuenta.',
            style: AppTextStyles.body(size: 12.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancelar', style: AppTextStyles.body(size: 12.5)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Eliminar',
                style: AppTextStyles.heading(size: 12.5, color: AppColors.tomate)),
          ),
        ],
      ),
    );
    if (confirmado == true) usuario.eliminarDireccion(direccion);
  }

  void _abrirFormulario(
    BuildContext context,
    UserModel usuario, {
    Direccion? direccion,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FormularioDireccion(usuario: usuario, direccion: direccion),
    );
  }
}

/// Hoja para crear o editar una dirección.
///
/// Es un StatefulWidget a propósito: así los TextEditingController viven y
/// se liberan con la hoja. Antes se creaban afuera y se liberaban apenas
/// cerraba, y como la hoja sigue animándose un momento más, la pantalla
/// petaba con "A TextEditingController was used after being disposed".
class _FormularioDireccion extends StatefulWidget {
  final UserModel usuario;
  final Direccion? direccion;

  const _FormularioDireccion({required this.usuario, this.direccion});

  @override
  State<_FormularioDireccion> createState() => _FormularioDireccionState();
}

class _FormularioDireccionState extends State<_FormularioDireccion> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _alias =
      TextEditingController(text: widget.direccion?.alias ?? '');
  late final TextEditingController _detalle =
      TextEditingController(text: widget.direccion?.detalle ?? '');
  late final TextEditingController _indicaciones =
      TextEditingController(text: widget.direccion?.indicaciones ?? '');

  bool _intentoGuardar = false;

  @override
  void dispose() {
    _alias.dispose();
    _detalle.dispose();
    _indicaciones.dispose();
    super.dispose();
  }

  void _guardar() {
    setState(() => _intentoGuardar = true);

    if (!_formKey.currentState!.validate()) {
      avisarCamposIncompletos(context, 'Falta el nombre o la dirección');
      return;
    }

    final messenger = ScaffoldMessenger.of(context);

    if (widget.direccion == null) {
      widget.usuario.agregarDireccion(
        alias: _alias.text,
        detalle: _detalle.text,
        indicaciones: _indicaciones.text,
      );
    } else {
      widget.usuario.actualizarDireccion(
        widget.direccion!.copyWith(
          alias: _alias.text.trim(),
          detalle: _detalle.text.trim(),
          indicaciones: _indicaciones.text.trim(),
        ),
      );
    }

    Navigator.of(context).pop();
    avisarExitoEn(
      messenger,
      widget.direccion == null ? 'Dirección guardada' : 'Dirección actualizada',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.crema,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            autovalidateMode: _intentoGuardar
                ? AutovalidateMode.onUserInteraction
                : AutovalidateMode.disabled,
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
                Text(
                  widget.direccion == null ? 'Nueva dirección' : 'Editar dirección',
                  style: AppTextStyles.heading(size: 15),
                ),
                const SizedBox(height: 2),
                Text('Los campos con * son obligatorios',
                    style: AppTextStyles.body(size: 10.5, color: AppColors.muted)),
                const SizedBox(height: 14),
                AppTextField(
                  controller: _alias,
                  hint: 'Nombre (Casa, Trabajo…)',
                  icon: Icons.bookmark_outline_rounded,
                  obligatorio: true,
                ),
                const SizedBox(height: 10),
                AppTextField(
                  controller: _detalle,
                  hint: 'Dirección completa',
                  icon: Icons.location_on_outlined,
                  obligatorio: true,
                  validarAdemas: (v) =>
                      v.length < 5 ? 'Escribe la dirección completa' : null,
                ),
                const SizedBox(height: 10),
                AppTextField(
                  controller: _indicaciones,
                  hint: 'Indicaciones para el domiciliario (opcional)',
                  icon: Icons.notes_rounded,
                ),
                const SizedBox(height: 18),
                PrimaryButton(label: 'Guardar', onPressed: _guardar),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AccionTexto extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AccionTexto({
    required this.label,
    required this.onTap,
    this.color = AppColors.mostaza,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Text(label, style: AppTextStyles.heading(size: 11.5, color: color)),
    );
  }
}
