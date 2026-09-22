import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/documento.dart';
import '../state/app_scope.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_form_field.dart';
import '../widgets/primary_button.dart';

/// "Mis datos": deja ver y cambiar los datos de la cuenta.
/// Lo que se guarda aquí se ve de una en el encabezado, el saludo del
/// Inicio y el Perfil.
class ProfileDataScreen extends StatefulWidget {
  const ProfileDataScreen({super.key});

  @override
  State<ProfileDataScreen> createState() => _ProfileDataScreenState();
}

class _ProfileDataScreenState extends State<ProfileDataScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombre;
  late final TextEditingController _email;
  late final TextEditingController _telefono;
  late final TextEditingController _documento;
  late String _tipoDocumento;

  bool _intentoGuardar = false;

  @override
  void initState() {
    super.initState();
    final usuario = AppScope.usuarioSinEscuchar(context);
    _nombre = TextEditingController(text: usuario.nombre);
    _email = TextEditingController(text: usuario.email);
    _telefono = TextEditingController(text: usuario.telefono);
    _documento = TextEditingController(text: usuario.documento);
    _tipoDocumento = usuario.tipoDocumento ?? kTiposDocumento.first.codigo;
  }

  @override
  void dispose() {
    _nombre.dispose();
    _email.dispose();
    _telefono.dispose();
    _documento.dispose();
    super.dispose();
  }

  void _guardar() {
    setState(() => _intentoGuardar = true);

    if (!_formKey.currentState!.validate()) {
      avisarCamposIncompletos(context);
      return;
    }

    final messenger = ScaffoldMessenger.of(context);

    AppScope.usuarioSinEscuchar(context).actualizarDatos(
      nombre: _nombre.text,
      email: _email.text,
      telefono: _telefono.text,
      tipoDocumento: _tipoDocumento,
      documento: _documento.text,
    );

    Navigator.of(context).pop();
    avisarExitoEn(messenger, 'Tus datos quedaron guardados');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.crema,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.carbon),
        title: Text('Mis datos', style: AppTextStyles.heading(size: 15)),
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: _intentoGuardar
            ? AutovalidateMode.onUserInteraction
            : AutovalidateMode.disabled,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Text('Los campos con * son obligatorios',
                style: AppTextStyles.body(size: 10.5, color: AppColors.muted)),
            const SizedBox(height: 12),
            AppTextField(
              controller: _nombre,
              hint: 'Nombre completo',
              icon: Icons.person_outline_rounded,
              obligatorio: true,
              validarAdemas: (v) =>
                  v.length < 3 ? 'Escribe tu nombre completo' : null,
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: DropdownButtonFormField<String>(
                    initialValue: _tipoDocumento,
                    isExpanded: true,
                    style: AppTextStyles.body(size: 12.5),
                    decoration: campoDecoration(
                      hint: 'Tipo',
                      icon: Icons.badge_outlined,
                      obligatorio: true,
                    ),
                    items: kTiposDocumento
                        .map((t) => DropdownMenuItem(
                              value: t.codigo,
                              child: Text(t.codigo,
                                  style: AppTextStyles.body(size: 12.5)),
                            ))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _tipoDocumento = v ?? _tipoDocumento),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 6,
                  child: AppTextField(
                    controller: _documento,
                    hint: 'N° documento',
                    teclado: TextInputType.number,
                    obligatorio: true,
                    formatters: [FilteringTextInputFormatter.digitsOnly],
                    validarAdemas: (v) => v.length < 5 ? 'Número muy corto' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              tipoDocumentoPorCodigo(_tipoDocumento)?.nombre ?? '',
              style: AppTextStyles.body(size: 10, color: AppColors.muted),
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _email,
              hint: 'Correo electrónico',
              icon: Icons.mail_outline_rounded,
              teclado: TextInputType.emailAddress,
              obligatorio: true,
              validarAdemas: (v) =>
                  !v.contains('@') || !v.contains('.') ? 'Correo no válido' : null,
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _telefono,
              hint: 'Teléfono',
              icon: Icons.phone_outlined,
              teclado: TextInputType.phone,
              obligatorio: true,
              formatters: [FilteringTextInputFormatter.digitsOnly],
              validarAdemas: (v) => v.length < 7 ? 'Teléfono no válido' : null,
            ),
            const SizedBox(height: 22),
            PrimaryButton(label: 'Guardar cambios', onPressed: _guardar),
          ],
        ),
      ),
    );
  }
}
