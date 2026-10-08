# Placeholders de esta rama (sesion-09)

Punto de partida: ExploraEC con la Sesión 8 resuelta (inicio de sesión con token seguro, `ApiClient` con interceptores, CRUD de gastos, cierre de sesión limpio y cambio de contraseña). Tráela con:

```bash
git fetch starter
git checkout starter/sesion-09 -- lib test pubspec.yaml PLACEHOLDERS.md mock-server
flutter pub get
```

El objetivo de esta sesión es el Asistente ExploraIA: una pestaña donde la persona pregunta por sus gastos, conectada a un **proxy** local (`mock-server/`, modo mock, sin ninguna clave de IA), enviando solo el resumen por categoría y pidiendo confirmación antes de registrar nada.

**Todos los bloques son solo de descomentar**: nada que borrar ni copiar. Selecciona las líneas comentadas que están **debajo** de `TODO(sesion-09) Paso N` (no el `TODO` ni el «Por qué») y presiona `Ctrl + /` (`Cmd + /` en Mac).

## Archivos ya completos (sin `TODO`)
- `mock-server/mock-server.js` — el proxy (Node 18 o superior, sin dependencias): `POST /asistente`, reglas en modo mock, `PORT` configurable. No lee ni registra la cabecera `Authorization`; solo registra el tamaño y los nombres de los campos que recibe.
- `mock-server/README.md` — contrato, URL según el entorno y qué reconoce el mock. `ejemplo-consulta.json` y `ejemplo-registro.json` sirven para probar el proxy con `curl`, sin la app.
- `lib/services/ai_assistant_service.dart` — `kAiBackendUrl` (`--dart-define=LLM_BACKEND_URL=...`), `RespuestaIA`, `AccionPropuesta` (validada: una acción incompleta se descarta) y `AiAssistantService.preguntar(consulta, resumen)`, con errores traducidos a mensajes legibles. No lleva ninguna clave de IA.
- `lib/models/resumen_gastos.dart` y `GastosApiService.obtenerResumen()` (`GET /gastos/resumen`) con `GastosController.obtenerResumen()`.
- `lib/screens/assistant_screen.dart` — la pantalla completa; solo faltan los bloques de abajo. Incluye el diálogo de confirmación (`confirmarAccion`).
- `lib/main.dart` — registra `AiAssistantService` y agrega la pestaña «Asistente». `SinSesionView` ahora acepta un título.

## Qué descomentar

| Archivo | Bloque | Paso |
|---|---|---|
| `lib/screens/assistant_screen.dart` | Pedir el resumen, llamar al proxy y mostrar la respuesta (3 líneas) | 4 |
| `lib/screens/assistant_screen.dart` | Pedir confirmación cuando la IA propone una acción (1 línea) | 5 |
| `lib/screens/assistant_screen.dart` | Preguntas sugeridas (`Wrap` con chips) | 8 (opcional) |

## Pruebas

`test/sesion_09_test.dart` (7 pruebas) usa un backend y un proxy falsos: no necesita el backend, el proxy ni el emulador. Junto con las 15 de la Sesión 8 suman 22. Con la rama recién traída **pasan 19 y fallan 3**; al terminar cada paso:

| Después del Paso | Pasan | Fallan |
|---|---|---|
| 1 (rama recién traída) | 19 | 3 |
| 4 | 20 | 2 |
| 5 | 22 | 0 |

Ejecutarlas: `flutter test`.
