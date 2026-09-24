/// El precio como se escribe en Colombia: "$12.500", con punto cada tres
/// cifras. Una sola versión para toda la app — el menú, el carrito, los
/// pedidos y el panel — para que nunca se vea "$12500" en una pantalla y
/// "$12.500" en la de al lado.
///
/// No usa `intl` a propósito: son ocho líneas y el formato de pesos no
/// cambia según el idioma del celular.
String formatoPesos(int valor) {
  final digitos = valor.abs().toString();
  final salida = StringBuffer();

  for (var i = 0; i < digitos.length; i++) {
    // El punto va cada vez que faltan un múltiplo de 3 dígitos por escribir.
    if (i > 0 && (digitos.length - i) % 3 == 0) salida.write('.');
    salida.write(digitos[i]);
  }

  return '${valor < 0 ? '-' : ''}\$$salida';
}
