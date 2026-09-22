import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parche_mini_burger/models/business_info.dart';
import 'package:parche_mini_burger/models/extras.dart';
import 'package:parche_mini_burger/models/product.dart';
import 'package:parche_mini_burger/screens/contact_screen.dart';
import 'package:parche_mini_burger/screens/order_detail_screen.dart';
import 'package:parche_mini_burger/screens/orders_screen.dart';
import 'package:parche_mini_burger/state/app_scope.dart';
import 'package:parche_mini_burger/state/cart_model.dart';
import 'package:parche_mini_burger/state/orders_model.dart';
import 'package:parche_mini_burger/widgets/app_image.dart';

Product get _clasica => demoProducts.firstWhere((p) => p.id == 'hamburguesa_doble');
Extra get _tocineta => kAdiciones.firstWhere((e) => e.id == 'ad_tocineta');
Extra get _bbq => kSalsas.firstWhere((e) => e.id == 'bbq');
Product get _chuzo => demoProducts.firstWhere((p) => p.id == 'chuzo_pollo_cerdo');
const _opcionChuzo = {'Elige tu opción': 'Cerdo'};

OrdersModel _conUnPedido() {
  final carrito = CartModel()
    ..agregar(
      product: _clasica,
      salsas: {_bbq},
      adiciones: {_tocineta},
      cantidad: 3,
    )
..agregar(product: _chuzo, opciones: _opcionChuzo, cantidad: 1);

  final pedidos = OrdersModel();
  pedidos.crearDesdeCarrito(
    carrito: carrito,
    metodoPago: 'Nequi',
    direccion: 'Cra 45 #12-30, apto 302',
    comprobante: 'comprobante.jpg',
  );
  return pedidos;
}

void main() {
  setUp(() {
    final view = TestWidgetsFlutterBinding.ensureInitialized()
        .platformDispatcher
        .views
        .first;
    view.physicalSize = const Size(400, 1800);
    view.devicePixelRatio = 1.0;
  });

  tearDown(() {
    final view = TestWidgetsFlutterBinding.ensureInitialized()
        .platformDispatcher
        .views
        .first;
    view.resetPhysicalSize();
    view.resetDevicePixelRatio();
  });

  testWidgets('la tarjeta del pedido muestra el producto, no un número suelto',
      (tester) async {
    final pedidos = _conUnPedido();

    await tester.pumpWidget(AppScope(
      pedidosInicial: pedidos,
      child: const MaterialApp(home: Scaffold(body: OrdersScreen())),
    ));
    await tester.pumpAndSettle();

    // Producto principal (el de mayor cantidad) con su cantidad y su foto.
    expect(find.text('3 × ${_clasica.name}'), findsOneWidget);
    expect(find.byType(AppImage), findsWidgets);
    // Los demás productos se indican, no se esconden.
    expect(find.text('+1 producto'), findsOneWidget);
    expect(find.textContaining('4 en total'), findsOneWidget);
    // Total y estado reales del pedido.
    expect(find.text('\$${pedidos.pedidos.first.total}'), findsOneWidget);
    expect(find.text('En preparación'), findsOneWidget);
  });

  testWidgets('tocar la tarjeta abre el detalle con todo el pedido',
      (tester) async {
    final pedidos = _conUnPedido();
    final pedido = pedidos.pedidos.first;

    await tester.pumpWidget(AppScope(
      pedidosInicial: pedidos,
      child: const MaterialApp(home: Scaffold(body: OrdersScreen())),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('3 × ${_clasica.name}'));
    await tester.pumpAndSettle();

    expect(find.byType(OrderDetailScreen), findsOneWidget);

    // Los dos productos, con salsas, adiciones y bebida.
    expect(find.text('3 × ${_clasica.name}'), findsOneWidget);
    expect(find.text('1 × ${_chuzo.name}'), findsOneWidget);
    expect(find.textContaining(_bbq.nombre, findRichText: true), findsOneWidget);
    expect(find.textContaining(_tocineta.nombre, findRichText: true), findsOneWidget);
    expect(find.textContaining('Cerdo', findRichText: true), findsWidgets);

    // Subtotales, total, entrega, pago, estado y fecha.
    expect(find.textContaining('Subtotal · 3 ×'), findsOneWidget);
    expect(find.text('\$${pedido.total}'), findsOneWidget);
    expect(find.text('Cra 45 #12-30, apto 302'), findsOneWidget);
    expect(find.text('Nequi'), findsOneWidget);
    expect(find.text('#${pedido.id}'), findsOneWidget);
    expect(find.text('comprobante.jpg'), findsOneWidget);
    expect(find.text(pedido.fechaTexto), findsWidgets);
  });

  test('los enlaces de contacto salen de los datos del negocio', () {
    // WhatsApp: indicativo + número sin espacios, con mensaje.
    expect(
      BusinessInfo.whatsappUrl,
      startsWith('https://wa.me/'
          '${BusinessInfo.indicativoPais}${BusinessInfo.whatsappSoloDigitos}'),
    );
    expect(BusinessInfo.whatsappSoloDigitos, matches(RegExp(r'^\d+$')));
    expect(BusinessInfo.whatsappUrl, contains('?text='));

    // Instagram: app primero, web de respaldo, ambos con el mismo usuario.
    expect(BusinessInfo.instagramApp,
        'instagram://user?username=${BusinessInfo.instagramUsuario}');
    expect(BusinessInfo.instagramWeb,
        'https://www.instagram.com/${BusinessInfo.instagramUsuario}/');
    expect(BusinessInfo.instagram, '@${BusinessInfo.instagramUsuario}');
  });

  testWidgets('Contactar tiene los botones de WhatsApp e Instagram',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ContactScreen()));
    await tester.pumpAndSettle();

    expect(find.text('WhatsApp'), findsOneWidget);
    expect(find.text('Instagram'), findsOneWidget);
    expect(find.text('Escribir por WhatsApp'), findsOneWidget);
    // Son acciones, no adorno: dicen "Abrir".
    expect(find.text('Abrir'), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });
}
