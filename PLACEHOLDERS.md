# Placeholders de esta rama (sesion-08)

Punto de partida: ExploraEC con favoritos y caché persistentes en Hive (Sesión 7), sin cuentas de usuario ni datos colaborativos. Tráela con:

```bash
git fetch starter
git checkout starter/sesion-08 -- lib pubspec.yaml PLACEHOLDERS.md firestore.rules
```

El objetivo de esta sesión es agregar Firebase: autenticación por correo/contraseña, y reseñas de lugares visibles para todos los usuarios (Firestore). Cada bloque comentado trae, justo debajo del `TODO`, un comentario `// Por qué:` con la explicación.

## ⚠️ Este branch NO compila hasta completar el Paso 2

A diferencia de todas las sesiones anteriores, `flutter pub get && flutter run` **no** va a funcionar de entrada. `lib/main.dart` importa `firebase_options.dart`, un archivo que no existe todavía en tu copia — lo genera `flutterfire configure` con los datos de TU propio proyecto de Firebase (Paso 2 de la práctica). Es un archivo específico de cada proyecto de Firebase, así que no puede venir pre-armado en este repo. Ver `lib/firebase_options.example.dart` para entender su forma antes de generarlo.

## Archivos nuevos ya completos (sin `TODO`)
- `lib/models/review.dart` — completo.
- `lib/services/reviews_service.dart` — completo, ya usado desde `detail_screen.dart`.
- `firestore.rules` — completo. Pégalo en la consola de Firebase (Firestore Database → Reglas) en el Paso 5 — no es un archivo que el proyecto lea automáticamente.
- `lib/firebase_options.example.dart` — plantilla de referencia, no se usa directamente (ver advertencia arriba).
- `lib/screens/login_screen.dart`, `lib/screens/register_screen.dart` — completos.
- `lib/screens/favorites_screen.dart` — ya exige sesión iniciada (muestra un botón "Iniciar sesión" si `AuthController.estaAutenticado` es `false`).
- `lib/screens/detail_screen.dart` — ya tiene la sección de reseñas completa (lectura en tiempo real vía `StreamBuilder`), salvo el botón "Publicar" (ver tabla abajo).
- `lib/bindings/places_binding.dart` — ya registra `AuthController` junto a `PlacesController`.
- `pubspec.yaml` — ya incluye `firebase_core`, `firebase_auth`, `cloud_firestore`.
- `.gitignore` — ya excluye `lib/firebase_options.dart` además de `google-services.json`/`GoogleService-Info.plist`.

## Qué descomentar

| Archivo | Qué descomentar | Paso de la práctica |
|---|---|---|
| `lib/controllers/auth_controller.dart` | `registrar()`: borrar `async => false;` y descomentar el cuerpo real (`createUserWithEmailAndPassword` + manejo de `FirebaseAuthException`) | Paso 3 |
| `lib/controllers/auth_controller.dart` | `iniciarSesion()`: borrar `async => false;` y descomentar el cuerpo real (`signInWithEmailAndPassword` + manejo de `FirebaseAuthException`) | Paso 3 |
| `lib/controllers/places_controller.dart` | `alternarFavorito()`: borrar la línea `return;` (bien al inicio, dentro del cuerpo) y descomentar las 3 líneas que verifican `Get.find<AuthController>().estaAutenticado` antes de continuar | Paso 4 |
| `lib/screens/detail_screen.dart` | `_enviarReseña()`: borrar `return;` y descomentar el bloque real que arma un `Review` y llama a `ReviewsService.agregar(...)` | Paso 5 |

Nota del analizador: `places_controller.dart` importa `auth_controller.dart` desde antes de descomentar el Paso 4 — hasta ese momento, el analizador puede marcar ese import como "no usado todavía" dentro del bloque comentado; es esperado, no un error.

## Comando de arranque

```bash
dart pub global activate flutterfire_cli
flutterfire configure
flutter pub get
flutter run
```
