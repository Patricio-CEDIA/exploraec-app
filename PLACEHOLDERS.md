# Placeholders de esta rama (sesion-07)

Punto de partida: ExploraEC con `PlacesController` (GetX) ya compartido entre Inicio y Mapa (Sesión 4), sin ninguna persistencia — cerrar la app pierde todo, y sin conexión no hay nada que mostrar salvo el error. Tráela con:

```bash
git fetch starter
git checkout starter/sesion-07 -- lib pubspec.yaml PLACEHOLDERS.md
```

El objetivo de esta sesión es agregar una caché local con Hive (`PlaceRepository`) y favoritos que sobreviven reiniciar la app. Cada bloque comentado trae, justo debajo del `TODO`, un comentario `// Por qué:` con la explicación.

## Archivos nuevos ya completos (sin `TODO`)
- `lib/repositories/place_repository.dart` — completo, no tiene marcadores. Se usa recién al completar el Paso 2 en `places_controller.dart` (ver tabla de abajo) — hasta entonces, el analizador puede marcar el campo `_repository` del controller como "no usado", es esperado.
- `lib/screens/favorites_screen.dart` — completo, reemplaza a `favorites_placeholder_screen.dart` (se eliminó de esta rama).
- `lib/main.dart` — ya inicializa Hive (`Hive.initFlutter()`, abre las cajas `lugares_cache` y `favoritos`) antes de `runApp`, y usa `FavoritesScreen` en vez del placeholder.
- `lib/bindings/places_binding.dart` — ya arma el `PlaceRepository` con la caja `lugares_cache` y se lo pasa al `PlacesController`.
- `lib/models/place.dart` — ya tiene `toMap()`/`fromMap()` para la (de)serialización manual con Hive.
- `lib/widgets/place_card.dart` — ya muestra el ícono de favorito (`Obx` + `controller.esFavorito(place)`/`controller.alternarFavorito(place)`); no hace nada visible hasta completar el Paso 3.
- `pubspec.yaml` — ya incluye `hive`, `hive_flutter`, `path_provider`.
- Botón «Centrar en mi ubicación» del Mapa y distancia en las tarjetas de Inicio — resultado del Paso 7 opcional de la Sesión 5, ya resuelto en esta rama.

## Qué descomentar

| Archivo | Qué descomentar | Paso de la práctica |
|---|---|---|
| `lib/controllers/places_controller.dart` | En `cargarLugares()`: borrar el bloque que llama a `PlacesApiService.buscarLugaresCercanos(...)` directamente y descomentar el bloque que llama a `_repository.obtenerLugaresCercanos(...)` (con caché) | Paso 2 |
| `lib/controllers/places_controller.dart` | Borrar la versión en memoria de `alternarFavorito` (la del Paso 6 opcional de la Sesión 4) y descomentar el cuerpo real (agrega/quita de `_favoritosBox` y de la lista reactiva `favoritos`) | Paso 3 |

Con la rama recién traída (antes de descomentar nada), la app funciona igual que al final de la Sesión 6 (sin caché; los favoritos funcionan solo en memoria (versión de la Sesión 4): el corazón de `PlaceCard` responde, pero se pierden al cerrar la app). El orden importa: primero el Paso 2 (repositorio), después el Paso 3 (favoritos) — ambos son independientes entre sí, pero seguir ese orden es el que sigue el instructivo.

## Comando de arranque

```bash
flutter pub get
flutter run
```
