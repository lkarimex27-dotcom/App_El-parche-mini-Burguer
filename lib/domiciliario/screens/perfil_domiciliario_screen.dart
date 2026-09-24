import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../screens/login_screen.dart';
import '../../state/app_scope.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/aparicion.dart';
import '../widgets/domiciliario_card.dart';

class PerfilDomiciliarioScreen extends StatefulWidget {
  const PerfilDomiciliarioScreen({super.key});

  @override
  State<PerfilDomiciliarioScreen> createState() =>
      _PerfilDomiciliarioScreenState();
}

class _PerfilDomiciliarioScreenState extends State<PerfilDomiciliarioScreen> {
  bool _editando = false;
  Uint8List? _avatarTemporal;
  late final TextEditingController _nombre;
  late final TextEditingController _telefono;
  late final TextEditingController _vehiculo;

  @override
  void initState() {
    super.initState();
    final usuario = AppScope.usuarioSinEscuchar(context);
    final domicilio = AppScope.domiciliarioSinEscuchar(context);
    _nombre = TextEditingController(text: usuario.nombre);
    _telefono = TextEditingController(text: usuario.telefono);
    _vehiculo = TextEditingController(text: domicilio.vehiculo);
    _avatarTemporal = domicilio.avatarBytes;
  }

  @override
  void dispose() {
    _nombre.dispose();
    _telefono.dispose();
    _vehiculo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usuario = AppScope.usuario(context);
    final domicilio = AppScope.domiciliario(context);
    final pedidos = AppScope.pedidos(context).pedidosAsignados(usuario.email);
    final completadas =
        pedidos.where((p) => p.status.name == 'entregado').length;
    final ahora = DateTime.now();
    final hoy = pedidos
        .where((p) =>
            p.status.name == 'entregado' &&
            p.fecha.year == ahora.year &&
            p.fecha.month == ahora.month &&
            p.fecha.day == ahora.day)
        .length;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 22, 16, 24),
        children: [
          Row(
            children: [
              Expanded(
                  child: Text('Mi perfil',
                      style: AppTextStyles.heading(size: 21))),
              if (!_editando)
                IconButton(
                  tooltip: 'Editar perfil',
                  onPressed: () => setState(() => _editando = true),
                  icon:
                      const Icon(Icons.edit_outlined, color: AppColors.mostaza),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Aparicion(
              child: _editando
                  ? _formulario(context)
                  : _resumen(usuario, domicilio)),
          const SizedBox(height: 12),
          Aparicion(
            orden: 1,
            child: Row(
              children: [
                Expanded(
                    child: _DatoPerfil(
                        valor: '$completadas', texto: 'Entregas totales')),
                const SizedBox(width: 10),
                Expanded(
                    child:
                        _DatoPerfil(valor: '$hoy', texto: 'Entregas de hoy')),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Aparicion(
            orden: 2,
            child: DomiciliarioCard(
              child: TextButton.icon(
                onPressed: () {
                  AppScope.usuarioSinEscuchar(context).cerrarSesion();
                  Navigator.of(context).pushAndRemoveUntil(
                      rutaConFundido(const LoginScreen()), (route) => false);
                },
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Cerrar sesión'),
                style: TextButton.styleFrom(foregroundColor: AppColors.tomate),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _resumen(dynamic usuario, dynamic domicilio) {
    final avatar = domicilio.avatarBytes;
    return DomiciliarioCard(
      child: Column(
        children: [
          CircleAvatar(
            radius: 38,
            backgroundColor: AppColors.mostaza,
            backgroundImage: avatar == null ? null : MemoryImage(avatar),
            child: avatar == null
                ? Text(usuario.iniciales,
                    style: AppTextStyles.heading(size: 22, color: Colors.white))
                : null,
          ),
          const SizedBox(height: 12),
          Text(usuario.nombre.isEmpty ? 'Domiciliario' : usuario.nombre,
              style: AppTextStyles.heading(size: 16)),
          const SizedBox(height: 4),
          Text(usuario.email,
              style: AppTextStyles.body(size: 11.5, color: AppColors.muted)),
          if (usuario.telefono.isNotEmpty)
            Text(usuario.telefono,
                style: AppTextStyles.body(size: 11.5, color: AppColors.muted)),
          const SizedBox(height: 10),
          Text(
              domicilio.vehiculo.isEmpty
                  ? 'Vehículo no registrado'
                  : domicilio.vehiculo,
              style: AppTextStyles.body(size: 11.5, color: AppColors.ambar)),
        ],
      ),
    );
  }

  Widget _formulario(BuildContext context) {
    final usuario = AppScope.usuario(context);
    return DomiciliarioCard(
      child: Column(
        children: [
          GestureDetector(
            onTap: _elegirFoto,
            child: CircleAvatar(
              radius: 38,
              backgroundColor: AppColors.mostaza,
              backgroundImage: _avatarTemporal == null
                  ? null
                  : MemoryImage(_avatarTemporal!),
              child: _avatarTemporal == null
                  ? const Icon(Icons.add_a_photo_outlined, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
              controller: _nombre,
              decoration: const InputDecoration(labelText: 'Nombre')),
          const SizedBox(height: 10),
          TextField(
            controller: _telefono,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'Teléfono'),
          ),
          const SizedBox(height: 10),
          TextField(
              controller: _vehiculo,
              decoration:
                  const InputDecoration(labelText: 'Vehículo (opcional)')),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Correo: ${usuario.email} (no editable)',
                style: AppTextStyles.body(size: 10.5, color: AppColors.muted)),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                  child: OutlinedButton(
                      onPressed: _cancelar, child: const Text('Cancelar'))),
              const SizedBox(width: 10),
              Expanded(
                  child: ElevatedButton(
                      onPressed: _guardar,
                      child: const Text('Guardar cambios'))),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _elegirFoto() async {
    final fuente = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Galería'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Cámara'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (fuente == null) return;
    final foto =
        await ImagePicker().pickImage(source: fuente, imageQuality: 80);
    if (foto == null || !mounted) return;
    final bytes = await foto.readAsBytes();
    if (mounted) setState(() => _avatarTemporal = bytes);
  }

  void _guardar() {
    final usuario = AppScope.usuarioSinEscuchar(context);
    final domicilio = AppScope.domiciliarioSinEscuchar(context);
    // TEMPORAL: estos cambios viven en AppScope hasta conectar backend.
    usuario.actualizarDatos(nombre: _nombre.text, telefono: _telefono.text);
    domicilio.actualizarVehiculo(_vehiculo.text);
    domicilio.actualizarAvatar(_avatarTemporal);
    setState(() => _editando = false);
  }

  void _cancelar() {
    final usuario = AppScope.usuarioSinEscuchar(context);
    final domicilio = AppScope.domiciliarioSinEscuchar(context);
    _nombre.text = usuario.nombre;
    _telefono.text = usuario.telefono;
    _vehiculo.text = domicilio.vehiculo;
    _avatarTemporal = domicilio.avatarBytes;
    setState(() => _editando = false);
  }
}

class _DatoPerfil extends StatelessWidget {
  final String valor;
  final String texto;
  const _DatoPerfil({required this.valor, required this.texto});

  @override
  Widget build(BuildContext context) => DomiciliarioCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(valor,
                style:
                    AppTextStyles.heading(size: 21, color: AppColors.tomate)),
            const SizedBox(height: 3),
            Text(texto,
                style: AppTextStyles.body(size: 10, color: AppColors.muted)),
          ],
        ),
      );
}
