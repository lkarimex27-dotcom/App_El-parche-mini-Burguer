import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../state/app_scope.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/primary_button.dart';

enum _MetodoPago { nequi, bancolombia }

class PaymentScreen extends StatefulWidget {
  final int total;
  const PaymentScreen({super.key, required this.total});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  _MetodoPago _metodo = _MetodoPago.nequi;

  String? _comprobanteNombre;
  Uint8List? _comprobanteBytes;
  bool _cargando = false;

  bool get _tieneComprobante => _comprobanteBytes != null;

  /// Pregunta de dónde sacar la imagen: galería o archivos.
  Future<void> _elegirOrigen() async {
    if (_cargando) return;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.crema,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
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
            const SizedBox(height: 16),
            Text('¿De dónde tomamos el comprobante?',
                style: AppTextStyles.heading(size: 15)),
            const SizedBox(height: 2),
            Text('Busca la captura de la transferencia',
                style: AppTextStyles.body(size: 11.5, color: AppColors.muted)),
            const SizedBox(height: 16),
            _OpcionOrigen(
              icon: Icons.photo_library_outlined,
              titulo: 'Galería',
              detalle: 'Las fotos y capturas de tu celular',
              onTap: () {
                Navigator.of(context).pop();
                _desdeGaleria();
              },
            ),
            const SizedBox(height: 10),
            _OpcionOrigen(
              icon: Icons.folder_open_outlined,
              titulo: 'Archivos',
              detalle: 'Descargas, Drive y demás carpetas',
              onTap: () {
                Navigator.of(context).pop();
                _desdeArchivos();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _desdeGaleria() async {
    setState(() => _cargando = true);
    try {
      final foto = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (foto == null) return;
      _guardarComprobante(await foto.readAsBytes(), foto.name);
    } catch (e) {
      _avisarError('No pudimos abrir la galería');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _desdeArchivos() async {
    setState(() => _cargando = true);
    try {
      final archivo = await FilePicker.pickFile(type: FileType.image);
      if (archivo == null) return;
      _guardarComprobante(await archivo.readAsBytes(), archivo.name);
    } catch (e) {
      _avisarError('No pudimos abrir tus archivos');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  void _guardarComprobante(Uint8List bytes, String nombre) {
    if (!mounted) return;
    setState(() {
      _comprobanteBytes = bytes;
      _comprobanteNombre = nombre;
    });
  }

  void _quitarComprobante() {
    setState(() {
      _comprobanteBytes = null;
      _comprobanteNombre = null;
    });
  }

  void _avisarError(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: AppColors.tomate,
          content: Text(mensaje,
              style: AppTextStyles.body(size: 12.5, color: Colors.white)),
        ),
      );
  }

  /// Crea el pedido con todo lo que el cliente eligió y lo guarda en
  /// "Mis pedidos". Devuelve `true` al carrito para que se vacíe.
  void _confirmarPedido() {
    final carrito = AppScope.carritoSinEscuchar(context);
    final usuario = AppScope.usuarioSinEscuchar(context);

    AppScope.pedidosSinEscuchar(context).crearDesdeCarrito(
      carrito: carrito,
      metodoPago: _metodo == _MetodoPago.nequi ? 'Nequi' : 'Bancolombia',
      cliente: usuario.nombre,
      direccion: usuario.direccionPrincipal?.detalle,
      comprobante: _comprobanteNombre,
    );

    Navigator.of(context).pop(true);
  }

  String _peso(Uint8List bytes) {
    final kb = bytes.lengthInBytes / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(0)} KB';
    return '${(kb / 1024).toStringAsFixed(1)} MB';
  }

  /// Recuadro para tocar cuando todavía no hay comprobante.
  Widget _zonaDeSubida() {
    return GestureDetector(
      onTap: _elegirOrigen,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 26),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.mostaza, width: 1.6),
        ),
        child: Column(
          children: [
            if (_cargando)
              const SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  valueColor: AlwaysStoppedAnimation(AppColors.mostaza),
                ),
              )
            else
              const Icon(Icons.upload_rounded, color: AppColors.mostaza, size: 26),
            const SizedBox(height: 10),
            Text(
              _cargando ? 'Abriendo…' : 'Toca para subir tu comprobante',
              style: AppTextStyles.body(size: 12.5, weight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const _Pista(icon: Icons.photo_library_outlined, texto: 'Galería'),
                const SizedBox(width: 8),
                Text('o', style: AppTextStyles.body(size: 11, color: AppColors.muted)),
                const SizedBox(width: 8),
                const _Pista(icon: Icons.folder_open_outlined, texto: 'Archivos'),
              ],
            ),
            const SizedBox(height: 8),
            Text('PNG o JPG',
                style: AppTextStyles.body(size: 11, color: AppColors.muted)),
          ],
        ),
      ),
    );
  }

  /// Ya hay imagen: se ve, y se puede cambiar o quitar.
  Widget _vistaPrevia() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.verde, width: 1.6),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.memory(
              _comprobanteBytes!,
              width: double.infinity,
              height: 200,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.check_circle_rounded, size: 18, color: AppColors.verde),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _comprobanteNombre ?? 'comprobante',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body(size: 12, weight: FontWeight.w600),
                    ),
                    Text(_peso(_comprobanteBytes!),
                        style: AppTextStyles.body(size: 10.5, color: AppColors.muted)),
                  ],
                ),
              ),
              TextButton(
                onPressed: _elegirOrigen,
                child: Text('Cambiar',
                    style: AppTextStyles.heading(size: 11.5, color: AppColors.mostaza)),
              ),
              TextButton(
                onPressed: _quitarComprobante,
                child: Text('Quitar',
                    style: AppTextStyles.heading(size: 11.5, color: AppColors.tomate)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.crema,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.carbon),
        title: Text('Método de pago', style: AppTextStyles.heading(size: 16)),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                _MetodoTile(
                  icon: Icons.account_balance_wallet_rounded,
                  color: AppColors.tomate,
                  title: 'Nequi',
                  subtitle: '300 123 4567',
                  selected: _metodo == _MetodoPago.nequi,
                  onTap: () => setState(() => _metodo = _MetodoPago.nequi),
                ),
                const SizedBox(height: 10),
                _MetodoTile(
                  icon: Icons.account_balance_rounded,
                  color: AppColors.verde,
                  title: 'Bancolombia',
                  subtitle: 'Ahorros · 000-123456-78',
                  selected: _metodo == _MetodoPago.bancolombia,
                  onTap: () => setState(() => _metodo = _MetodoPago.bancolombia),
                ),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppColors.carbon, borderRadius: BorderRadius.circular(14)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total a transferir', style: AppTextStyles.heading(size: 12, color: Colors.white)),
                      const SizedBox(height: 4),
                      Text('\$${widget.total}', style: AppTextStyles.heading(size: 22, color: AppColors.ambar)),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Text('Sube tu comprobante', style: AppTextStyles.heading(size: 12.5)),
                const SizedBox(height: 8),
                if (_tieneComprobante) _vistaPrevia() else _zonaDeSubida(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
            child: PrimaryButton(
              label: 'Enviar comprobante',
              onPressed: !_tieneComprobante ? null : _confirmarPedido,
            ),
          ),
        ],
      ),
    );
  }
}

/// Una de las dos opciones de la hoja: Galería o Archivos.
class _OpcionOrigen extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String detalle;
  final VoidCallback onTap;

  const _OpcionOrigen({
    required this.icon,
    required this.titulo,
    required this.detalle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borde),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.crema2,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.mostaza, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo, style: AppTextStyles.heading(size: 13.5)),
                  const SizedBox(height: 2),
                  Text(detalle,
                      style: AppTextStyles.body(size: 11, color: AppColors.muted)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}

/// Los dos atajos que se ven dentro del recuadro de subida.
class _Pista extends StatelessWidget {
  final IconData icon;
  final String texto;
  const _Pista({required this.icon, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.mostaza),
        const SizedBox(width: 4),
        Text(texto, style: AppTextStyles.body(size: 11.5, color: AppColors.carbon)),
      ],
    );
  }
}

class _MetodoTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _MetodoTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? AppColors.mostaza : AppColors.borde, width: 1.6),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(9)),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.heading(size: 13)),
                  Text(subtitle, style: AppTextStyles.body(size: 11, color: AppColors.muted)),
                ],
              ),
            ),
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? AppColors.mostaza : Colors.transparent,
                border: Border.all(color: selected ? AppColors.mostaza : AppColors.borde, width: 1.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
