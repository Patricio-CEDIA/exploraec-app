import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import 'register_screen.dart';

/// Pantalla de inicio de sesión — Sesión 8. Se llega aquí desde Favoritos
/// o desde el formulario de reseñas cuando `AuthController.estaAutenticado`
/// es `false` — nunca es la pantalla inicial de la app: ExploraEC permite
/// explorar lugares sin cuenta, solo pide sesión para guardar o comentar.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _correoCtrl = TextEditingController();
  final _claveCtrl = TextEditingController();
  final AuthController _auth = Get.find<AuthController>();

  Future<void> _enviar() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await _auth.iniciarSesion(
      correo: _correoCtrl.text.trim(),
      clave: _claveCtrl.text,
    );
    if (ok && mounted) Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inicia sesión')),
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
                decoration: const InputDecoration(labelText: 'Contraseña'),
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
                        : const Text('Ingresar'),
                  )),
              TextButton(
                onPressed: () => Get.to(() => const RegisterScreen()),
                child: const Text('¿No tienes cuenta? Regístrate'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
