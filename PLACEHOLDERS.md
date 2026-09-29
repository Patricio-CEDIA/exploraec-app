# Placeholders de esta rama (sesion-06)

Punto de partida: ExploraEC con `PlacesController` (Sesión 4) y mapa real con posición del usuario (Sesión 5) ya resueltos; los lugares siguen siendo los de ejemplo escritos a mano. Tráela con:

```bash
git fetch starter
git checkout starter/sesion-06 -- lib pubspec.yaml PLACEHOLDERS.md
```

El objetivo de esta sesión es reemplazar los lugares de ejemplo por lugares reales obtenidos de la Overpass API de OpenStreetMap (sin API key), usando la posición real del usuario, integrando la consulta en el `PlacesController`. Cada bloque comentado trae, justo debajo del `TODO`, un comentario `// Por qué:` con la explicación.

## Archivos nuevos ya completos (sin `TODO`)
- `lib/services/places_api_service.dart` — construcción de la consulta Overpass QL, llamada HTTP, manejo de errores (`SocketException`, timeout, `429`, JSON inválido) y mapeo de la respuesta a `Place`.
- `lib/models/place.dart` — nuevo `Place.fromOverpassElement(...)`; ya no incluye `fetchLugaresSimulado` (reemplazada por el servicio real de esta sesión).
- `pubspec.yaml` — ya incluye `http`.

## Qué descomentar

| Archivo | Qué descomentar | Paso de la práctica |
|---|---|---|
| `lib/controllers/places_controller.dart` | En `cargarLugares()`: borrar `lugares.value = []; estado.value = EstadoCarga.exito;` y descomentar el bloque `try { ... } catch (e) { ... }` completo (posición del controller → Overpass → se agregan los lugares creados a mano en `AddPlaceScreen`) | Paso 3 |

Con la rama recién traída (antes de descomentar nada), Inicio y el Mapa muestran una lista vacía (`EmptyView` en Inicio, mapa sin marcadores de lugares) — es el comportamiento esperado hasta completar el Paso 3. `HomeScreen` y `MapScreen` no se modifican: ya leen el controller desde las Sesiones 4 y 5.

## Comando de arranque

```bash
flutter pub get
flutter run
```
