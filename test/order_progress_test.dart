import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parche_mini_burger/models/order.dart';
import 'package:parche_mini_burger/widgets/order_progress.dart';

void main() {
  Order pedido(OrderStatus status, {List<OrderEvento>? historial}) => Order(
        id: '001',
        fecha: DateTime(2026, 9, 22, 13, 5),
        status: status,
        lineas: const [],
        subtotal: 20000,
        domicilio: 3000,
        metodoPago: 'Nequi',
        historial: historial,
      );

  Future<void> mostrar(WidgetTester tester, Order order) => tester.pumpWidget(
        MaterialApp(home: Scaffold(body: OrderProgress(order: order))),
      );

  testWidgets('muestra todo el camino y marca en cuál fase va',
      (tester) async {
    await mostrar(tester, pedido(OrderStatus.preparacion));

    for (final fase in kFasesPedido) {
      expect(find.text(fase.label), findsOneWidget, reason: fase.label);
    }
    // "Ahora" señala una sola fase: la actual.
    expect(find.text('Ahora'), findsOneWidget);
  });

  testWidgets('un pedido cancelado corta el camino donde se quedó',
      (tester) async {
    final orden = pedido(
      OrderStatus.cancelado,
      historial: [
        OrderEvento(
          fecha: DateTime(2026, 9, 22, 13, 5),
          texto: 'Pedido recibido',
          estado: OrderStatus.pendiente,
        ),
        OrderEvento(
          fecha: DateTime(2026, 9, 22, 13, 20),
          texto: 'Aprobado',
          estado: OrderStatus.aprobado,
        ),
        OrderEvento(
          fecha: DateTime(2026, 9, 22, 13, 40),
          texto: 'Cancelado por el cliente',
          estado: OrderStatus.cancelado,
        ),
      ],
    );
    await mostrar(tester, orden);

    expect(orden.faseActual, kFasesPedido.indexOf(OrderStatus.aprobado));
    expect(find.text('Aprobado'), findsOneWidget);
    expect(find.text('Cancelado'), findsOneWidget);
    // Lo que nunca pasó no se muestra.
    expect(find.text('En preparación'), findsNothing);
    expect(find.text('Entregado'), findsNothing);
  });

  testWidgets('la fase actual resalta y las demás se desvanecen',
      (tester) async {
    await mostrar(tester, pedido(OrderStatus.preparacion));

    // Los pasos se pintan con opacidad distinta: el de ahora al 100 %, los
    // ya cumplidos a media luz y los que faltan casi apagados.
    final opacidades = tester
        .widgetList<Opacity>(find.byType(Opacity))
        .map((o) => o.opacity)
        .toSet();
    expect(opacidades, contains(1.0));
    expect(opacidades.any((o) => o < 0.6), isTrue);
    expect(opacidades.any((o) => o < 0.4), isTrue);
  });

  testWidgets('la hora de cada fase sale del historial', (tester) async {
    await mostrar(tester, pedido(OrderStatus.pendiente));
    expect(find.text('1:05 p.m.'), findsOneWidget);
  });
}
