import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../models/precio.dart';
import '../../state/app_scope.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/aparicion.dart';
import '../widgets/domiciliario_card.dart';
import '../widgets/estado_entrega_badge.dart';

class HistorialEntregasScreen extends StatefulWidget {
  const HistorialEntregasScreen({super.key});

  @override
  State<HistorialEntregasScreen> createState() =>
      _HistorialEntregasScreenState();
}

class _HistorialEntregasScreenState extends State<HistorialEntregasScreen> {
  DateTime? _filtro;

  @override
  Widget build(BuildContext context) {
    final usuario = AppScope.usuario(context);
    final pedidos = AppScope.pedidos(context);
    final historial = pedidos.historialDe(usuario.email).where((pedido) {
      if (_filtro == null) return true;
      return pedido.fecha.year == _filtro!.year &&
          pedido.fecha.month == _filtro!.month &&
          pedido.fecha.day == _filtro!.day;
    }).toList();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 22, 16, 24),
        children: [
          Text('Historial de entregas', style: AppTextStyles.heading(size: 21)),
          const SizedBox(height: 4),
          Text('Consulta tus entregas completadas',
              style: AppTextStyles.body(size: 12, color: AppColors.muted)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _seleccionarFecha,
                  icon: const Icon(Icons.calendar_month_outlined, size: 18),
                  label: Text(_filtro == null
                      ? 'Filtrar por fecha'
                      : _fechaTexto(_filtro!)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.mostaza,
                    side: const BorderSide(color: AppColors.mostaza),
                  ),
                ),
              ),
              if (_filtro != null)
                IconButton(
                  tooltip: 'Quitar filtro',
                  onPressed: () => setState(() => _filtro = null),
                  icon:
                      const Icon(Icons.close_rounded, color: AppColors.tomate),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (historial.isEmpty)
            const DomiciliarioCard(
                child: Text('No hay entregas para este filtro.'))
          else
            ...historial.asMap().entries.map((entry) => Aparicion(
                  orden: entry.key,
                  child: _EntregaHistorica(pedido: entry.value),
                )),
        ],
      ),
    );
  }

  Future<void> _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDate: _filtro ?? DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(seedColor: AppColors.mostaza)),
        child: child!,
      ),
    );
    if (fecha != null) setState(() => _filtro = fecha);
  }

  String _fechaTexto(DateTime fecha) =>
      '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
}

class _EntregaHistorica extends StatelessWidget {
  final Order pedido;
  const _EntregaHistorica({required this.pedido});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DomiciliarioCard(
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.verde.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.check_rounded, color: AppColors.verde),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pedido #${pedido.id}',
                      style: AppTextStyles.heading(size: 12.5)),
                  Text(
                      pedido.cliente.isEmpty
                          ? 'Cliente sin nombre'
                          : pedido.cliente,
                      style: AppTextStyles.body(size: 11.5)),
                  Text(pedido.fechaTexto,
                      style: AppTextStyles.body(
                          size: 10.5, color: AppColors.muted)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(formatoPesos(pedido.total),
                    style: AppTextStyles.heading(
                        size: 12.5, color: AppColors.tomate)),
                const SizedBox(height: 5),
                EstadoEntregaBadge(estado: pedido.status),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
