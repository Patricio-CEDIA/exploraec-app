import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';

/// Registro de cuenta nueva — Sesión 8. Misma forma que [LoginScreen],
/// llamando a `registrar()` en vez de `iniciarSesion()`.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _correoCtrl = TextEditingController();
  final _claveCtrl = TextEditingController();
  final AuthController _auth = Get.find<AuthController>();

  Future<void> _enviar() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await _auth.registrar(
      correo: _correoCtrl.text.trim(),
      clave: _claveCtrl.text,
    );
    if (ok && mounted) {
      Get.back(); // vuelve al Login, que a su vez cierra vía authStateChanges
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crea tu cuenta')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _correoCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Correo'),
                validator: (v) =>
                    (v == null || !v.contains('@')) ? 'Ingresa un correo válido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _claveCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Contraseña (mín. 6 caracteres)'),
                validator: (v) =>
                    (v == null || v.length < 6) ? 'Mínimo 6 caracteres' : null,
              ),
              const SizedBox(height: 16),
              Obx(() => _auth.mensajeError.value.isEmpty
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(_auth.mensajeError.value,
                          style: const TextStyle(color: Colors.red)),
                    )),
              Obx(() => ElevatedButton(
                    onPressed: _auth.cargando.value ? null : _enviar,
                    child: _auth.cargando.value
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Crear cuenta'),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
