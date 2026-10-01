# Placeholders de esta rama (sesion-09)

Punto de partida: ExploraEC con autenticación (Firebase Auth) y reseñas colaborativas (Firestore) de la Sesión 8. Tráela con:

```bash
git fetch starter
git checkout starter/sesion-09 -- lib pubspec.yaml PLACEHOLDERS.md mock-server
```

El objetivo de esta sesión es agregar la pantalla "Asistente ExploraIA", que llama a un backend propio (nunca a un proveedor de LLM directamente) para recomendar un lugar entre los ya cargados. El bloque comentado trae, justo debajo del `TODO`, un comentario `// Por qué:` con la explicación.

## Archivos nuevos ya completos (sin `TODO`)
- `lib/services/ai_assistant_service.dart` — completo. Llama a `<LLM_BACKEND_URL>/recomendacion` (constante `kAiBackendUrl`, configurable con `--dart-define` sin tocar el código).
- `mock-server/mock-server.js` — completo. Servidor local de prueba (sin dependencias, solo Node), NO es parte de la app Flutter — corre aparte, ver `mock-server/README.md`.
- `mock-server/referencia-backend-cloud-function.md` — código de referencia de cómo se vería el backend real con una API key de verdad — **no se despliega en este curso**.
- Botón «Centrar en mi ubicación» del Mapa y distancia en las tarjetas de Inicio — resultado del Paso 7 opcional de la Sesión 5, ya resuelto en esta rama.
- Deslizar para actualizar en Inicio (`RefreshIndicator`) — resultado del Paso 7 opcional de la Sesión 6, ya resuelto en esta rama.
- Idioma guardado con Hive (`SettingsService`) — resultado del Paso 6 opcional de la Sesión 7, ya resuelto en esta rama.
- Botón «Cerrar sesión» en la pantalla de Favoritos — resultado del Paso 7 opcional de la Sesión 8, ya resuelto en esta rama.

## Qué descomentar

| Archivo | Qué descomentar | Paso de la práctica |
|---|---|---|
| `lib/screens/assistant_screen.dart` | `_preguntar()`: borrar el bloque `await Future.delayed(...)` + su `setState` de aviso, y descomentar el bloque real que llama a `AiAssistantService.pedirRecomendacion(...)` | Paso 4 |
| `lib/screens/assistant_screen.dart` | *(Opcional)* Descomentar el `Wrap` de `ActionChip` bajo el campo de texto (preguntas sugeridas; no hay nada que borrar) | Paso 7 (opcional) |

El Paso 7 es opcional: no cuenta dentro de los 55 minutos. Sin él la pantalla funciona igual (con el campo de texto).

## Comando de arranque

```bash
# Terminal 1 — el mock del backend de IA
cd mock-server
node mock-server.js

# Terminal 2 — la app (Android emulator)
cd ..
flutter pub get
flutter run --dart-define=LLM_BACKEND_URL=http://10.0.2.2:3000
```

> Nota: el valor por defecto de `kAiBackendUrl` ya es `http://10.0.2.2:3000` (loopback del emulador Android), así que en ese caso `flutter run` sin `--dart-define` también funciona — el flag de arriba es necesario solo si usas un dispositivo físico o el simulador de iOS (ver tabla de URLs en `mock-server/README.md`).
