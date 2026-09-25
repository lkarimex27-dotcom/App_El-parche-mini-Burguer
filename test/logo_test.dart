import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parche_mini_burger/models/business_info.dart';

void main() {
  test('el logo del negocio existe en assets', () {
    // El nombre lleva espacios y mayúsculas: un dedazo no se nota hasta
    // que la app arranca sin logo y nadie sabe por qué.
    expect(BusinessInfo.logo, isNotEmpty);
    expect(File(BusinessInfo.logo).existsSync(), isTrue,
        reason: 'BusinessInfo.logo apunta a ${BusinessInfo.logo} y no está');
  });
}
