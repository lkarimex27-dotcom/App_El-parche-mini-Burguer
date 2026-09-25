/// Datos del negocio en un solo lugar: cámbialos aquí y se actualizan
/// en Inicio, Perfil y donde más se usen.
class BusinessInfo {
  BusinessInfo._();

  /// Logo oficial del negocio (assets/images/).
  static const String logo = 'assets/images/logo mini Burguer.png';

  static const String nombre = 'El parche de las miniBurguer';
  static const String nombreCorto = 'El Parche';
  static const String tagline = 'Mini burgers, máximo sabor';
  static const int desde = 2013;

  static const String historia =
      'Empezamos en 2013 con una parrilla en la esquina del barrio y una idea '
      'sencilla: mini hamburguesas hechas al momento, con carne fresca, pan '
      'artesanal y las salsas de la casa. Hoy seguimos preparando cada pedido '
      'igual que el primer día, para el parche de siempre.';

  static const String horario = 'Lun a dom · 5:00 p.m. – 11:30 p.m.';
  static const String direccion = 'Cra 45 #12-30, Barrio El Parche';

  // ─────────── UBICACIÓN: CONFIGURAR CON EL LOCAL REAL ───────────
  // Estas coordenadas son provisionales. Para poner las del local: abre
  // Google Maps, haz clic derecho justo encima del negocio y elige
  // "copiar coordenadas"; pega el primer número en latitud y el segundo
  // en longitud. El mapa de "Contactar" se mueve solo.
  static const double latitud = 6.2442;
  static const double longitud = -75.5812;

  // ─────────────── CONTACTO: CONFIGURAR AQUÍ ───────────────
  // Estos son los datos que venían en el proyecto. Reemplázalos por los
  // reales del negocio y los enlaces de WhatsApp e Instagram de la
  // pantalla "Contactar" quedan apuntando solos al sitio correcto.

  static const String telefono = '3206332670';

  /// Número de WhatsApp como se muestra en pantalla.
  static const String whatsapp = '3206332670';

  /// Indicativo del país, sin el "+". Colombia = 57.
  static const String indicativoPais = '57';

  /// Usuario de Instagram, sin la arroba.
  static const String instagramUsuario = 'elparchedelasminiburguers';

  static const String facebook = 'El parche de la mini burger';

  // ──────────────── Enlaces armados con lo de arriba ────────────────

  static const String instagram = '@$instagramUsuario';

  /// El número sin espacios ni guiones, como lo necesita wa.me.
  static String get whatsappSoloDigitos =>
      whatsapp.replaceAll(RegExp(r'\D'), '');

  /// Mensaje con el que arranca el chat de WhatsApp.
  static const String mensajeWhatsApp =
      'Hola, vengo de la app y quiero hacer un pedido 🍔';

  /// Enlace universal de WhatsApp: abre la app si está instalada y, si no,
  /// el chat desde el navegador.
  static String get whatsappUrl =>
      'https://wa.me/$indicativoPais$whatsappSoloDigitos'
      '?text=${Uri.encodeComponent(mensajeWhatsApp)}';

  /// Abre directamente la app de Instagram (si está instalada).
  static String get instagramApp => 'instagram://user?username=$instagramUsuario';

  /// Respaldo por navegador cuando no está la app de Instagram.
  static String get instagramWeb =>
      'https://www.instagram.com/$instagramUsuario/';

  static const String tiempoEntrega = '25 – 40 min';
  static const int precioDomicilio = 4000;
  static const String zonasDomicilio =
      'Domicilio en El Parche, La Floresta, Centro y barrios vecinos.';
  static const String metodosPago = 'Efectivo, Nequi y Bancolombia';

  static const double calificacion = 4.8;
  static const int resenas = 320;

  /// Foto de ambiente para los fondos (Splash, Login, Registro).
  /// Igual que en los productos: es un respaldo mientras no pongas
  /// assets/images/splash_bg.jpg y login_bg.jpg.
  static const String fotoAmbiente =
      'https://images.unsplash.com/photo-1550547660-d9450f859349?w=1000&q=80';

  /// Foto de la bienvenida del Inicio (respaldo de assets/images/bienvenida.jpg).
  static const String fotoBienvenida =
      'https://images.unsplash.com/photo-1561758033-d89a9ad46330?w=1000&q=80';

  /// Lo que hace distinto al negocio — se muestra en Inicio.
  static const List<String> promesas = [
    'Carne 100% fresca, nunca congelada',
    'Pan artesanal horneado cada día',
    'Salsas preparadas en casa',
  ];
}
