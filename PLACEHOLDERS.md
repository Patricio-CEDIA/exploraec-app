# Placeholders de esta rama (sesion-10)

Esta rama **no tiene ningún `TODO(sesion-NN)` pendiente** — es la implementación de referencia completa de ExploraEC tal como queda construida al final del curso (Sesiones 1-9 resueltas). No es un punto de partida con espacios en blanco: es la base sobre la que la Sesión 10 audita, pule y documenta, sin agregar tecnología nueva.

Al crear esta rama desde `sesion-09` se encontraron y resolvieron, además del `TODO(sesion-09)` esperado en `assistant_screen.dart`, dos marcadores `TODO(sesion-04)` que habían quedado sin resolver arrastrándose sin efecto visible desde la Sesión 4 (`lib/screens/home_screen.dart` y `lib/screens/map_screen.dart` — ambos dejaban la pantalla mostrando literalmente el texto "Pendiente de conectar con Obx" en vez de la lista/mapa real). Se corrigieron aquí: si estás dictando el curso y ves ese texto en una rama anterior (`sesion-04` a `sesion-09`), es ese bug — la corrección es descomentar el bloque `Obx(...)` ya presente debajo de cada marcador en esa rama.

## Comando de arranque

```bash
flutter pub get
flutter run
```

Para el Asistente ExploraIA (Sesión 9), sigue corriendo el mock server local:

```bash
cd mock-server && node mock-server.js
```

## Antes de usar esta rama en producción real

- Genera tu propio `lib/firebase_options.dart` con `flutterfire configure` (ver `lib/firebase_options.example.dart`) — no está en el repo, está en `.gitignore` a propósito.
- Reemplaza `<LLM_BACKEND_URL>` por un backend real desplegado (ver `mock-server/referencia-backend-cloud-function.md`) antes de publicar la app — el mock local es solo para la práctica de la Sesión 9.
