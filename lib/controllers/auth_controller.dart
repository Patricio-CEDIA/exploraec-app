import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

/// Autenticación con Firebase — Sesión 8. Fuente única de verdad de la
/// sesión del usuario, igual en espíritu a como `PlacesController` es la
/// fuente única de los lugares desde la Sesión 4: cualquier pantalla que
/// necesite saber "¿hay alguien logueado?" lee `usuario`, nunca vuelve a
/// preguntarle a `FirebaseAuth` por su cuenta.
class AuthController extends GetxController {
  final Rx<User?> usuario = Rx<User?>(null);
  final RxString mensajeError = ''.obs;
  final RxBool cargando = false.obs;

  bool get estaAutenticado => usuario.value != null;

  @override
  void onInit() {
    super.onInit();
    // `authStateChanges()` es un Stream (el mismo concepto de la Sesión 6,
    // ahí solo mencionado) — emite cada vez que el usuario inicia sesión,
    // cierra sesión, o la app arranca con una sesión ya guardada por
    // FirebaseAuth de una vez anterior.
    usuario.bindStream(FirebaseAuth.instance.authStateChanges());
  }

  Future<bool> registrar({required String correo, required String clave}) async {
    cargando.value = true;
    mensajeError.value = '';
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: correo,
        password: clave,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      mensajeError.value = switch (e.code) {
        'email-already-in-use' => 'Ya existe una cuenta con ese correo.',
        'weak-password' => 'La contraseña debe tener al menos 6 caracteres.',
        'invalid-email' => 'Ese correo no tiene un formato válido.',
        _ => 'No se pudo crear la cuenta (${e.code}).',
      };
      return false;
    } finally {
      cargando.value = false;
    }
  }

  Future<bool> iniciarSesion({required String correo, required String clave}) async {
    cargando.value = true;
    mensajeError.value = '';
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: correo,
        password: clave,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      mensajeError.value = switch (e.code) {
        'user-not-found' => 'No existe una cuenta con ese correo.',
        'wrong-password' || 'invalid-credential' => 'Contraseña incorrecta.',
        'invalid-email' => 'Ese correo no tiene un formato válido.',
        _ => 'No se pudo iniciar sesión (${e.code}).',
      };
      return false;
    } finally {
      cargando.value = false;
    }
  }

  Future<void> cerrarSesion() => FirebaseAuth.instance.signOut();
}
