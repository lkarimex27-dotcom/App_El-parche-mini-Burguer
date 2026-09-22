/// Tipos de documento que acepta la app.
class TipoDocumento {
  final String codigo;
  final String nombre;

  const TipoDocumento(this.codigo, this.nombre);

  @override
  String toString() => codigo;
}

const List<TipoDocumento> kTiposDocumento = [
  TipoDocumento('C.C.', 'Cédula de ciudadanía'),
  TipoDocumento('T.I.', 'Tarjeta de identidad'),
  TipoDocumento('C.E.', 'Cédula de extranjería'),
  TipoDocumento('PPT', 'Permiso por Protección Temporal'),
  TipoDocumento('PEP', 'Permiso Especial de Permanencia'),
  TipoDocumento('Pasaporte', 'Pasaporte'),
  TipoDocumento('NIT', 'NIT'),
];

TipoDocumento? tipoDocumentoPorCodigo(String? codigo) {
  if (codigo == null) return null;
  for (final t in kTiposDocumento) {
    if (t.codigo == codigo) return t;
  }
  return null;
}
