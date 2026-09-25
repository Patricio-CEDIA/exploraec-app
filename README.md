# exploraec-app

Repo de referencia ("starter") de *ExploraEC* para el curso *MOD3: Desarrolla Aplicaciones Móviles Robustas con Flutter e IA*.

## Cómo se usa este repo

Cada rama `sesion-NN` es el punto de partida de la práctica de esa sesión: contiene el código ya construido en la práctica de la sesión **anterior**, más el código provisional (que ya compila y corre) de la sesión actual, con el bloque real comentado justo debajo, precedido por:

```dart
// TODO(sesion-NN): borra la línea de abajo y descomenta el bloque completo.
```

Justo debajo de cada `TODO`, un comentario `// Por qué:` explica qué hace ese bloque y por qué está construido así — léelo antes de descomentar, no solo el código.

**No clones este repo aparte para copiar archivos a mano.** El flujo es: tu proyecto real `exploraec` (creado con `flutter create` en la Sesión 1) agrega este repo como un remoto de solo lectura, y cada sesión trae únicamente `lib/`, `pubspec.yaml` y `PLACEHOLDERS.md` de la rama correspondiente — sin tocar `android/`, `ios/` ni ningún otro archivo de tu proyecto.

Configuración (una sola vez, al abrir la Sesión 2):
```bash
cd exploraec
git remote add starter https://github.com/Patricio-CEDIA/exploraec-app.git
git fetch starter
```

El flujo esperado en cada sesión (a partir de la Sesión 2):

1. Traer la rama de tu sesión actual, solo los archivos que este repo gestiona: `git fetch starter && git checkout starter/sesion-NN -- lib pubspec.yaml PLACEHOLDERS.md`.
2. Ejecutar `flutter pub get`.
3. Ubicar los bloques `TODO(sesion-NN)` documentados en `PLACEHOLDERS.md` de esa rama (o buscarlos con tu editor), leer su comentario `// Por qué:`.
4. Borrar el bloque provisional activo y descomentar el bloque real, siguiendo la práctica de clase o el instructivo correspondiente.
5. Ejecutar y verificar.

**Importante:** este repo no incluye el esqueleto completo que genera `flutter create` (carpetas `android/`, `ios/`, `web/`, etc.) — esas las genera el propio Flutter SDK, una sola vez, en la Sesión 1, y no vuelven a tocarse. Este repo es una **capa superpuesta** con los archivos específicos de ExploraEC (`lib/`, `pubspec.yaml`) — el flujo completo, de punta a punta:

```bash
flutter create exploraec        # Sesión 1, una sola vez
cd exploraec
# Sesión 2 en adelante: git remote add starter https://github.com/Patricio-CEDIA/exploraec-app.git (una sola vez)
#                       git fetch starter && git checkout starter/sesion-NN -- lib pubspec.yaml PLACEHOLDERS.md
flutter pub get
flutter run
```

Sesiones con archivos adicionales fuera de `lib/`/`pubspec.yaml` (ver el `PLACEHOLDERS.md` de esa rama para el comando exacto): la Sesión 8 también trae `firestore.rules`, la Sesión 9 también trae la carpeta `mock-server/`.

Algunos cambios (permisos nativos de la Sesión 4, configuración de Firebase de la Sesión 8) no viven en este repo porque son específicos de tu propio proyecto o de tu propia cuenta — cada rama documenta en su `PLACEHOLDERS.md` cuáles son y cómo aplicarlos a mano.

## Ramas disponibles

| Rama | Punto de partida para | Qué agrega/completa esa sesión |
|---|---|---|
| `sesion-02` | Sesión 2 — Widgets básicos y avanzados | Modelo `Place`, lista de lugares en memoria (`ListView`/`GridView`, `PlaceCard`), pantalla de detalle, formulario "Agregar lugar", navegación inferior |
| `sesion-03` | Sesión 3 — Interfaces y UX Avanzada | Tema Material, estados de carga/vacío/error reutilizables, layout responsivo |
| `sesion-04` | Sesión 4 — Mapas y geolocalización | Permisos de ubicación, posición actual, pantalla de Mapa con `flutter_map` |
| `sesion-05` | Sesión 5 — Programación asíncrona | Lugares reales desde la Overpass API, estados loading/success/error |
| `sesion-06` | Sesión 6 — Gestión de estado con GetX | `PlacesController`, `Obx`, navegación e inyección de dependencias con GetX |
| `sesion-07` | Sesión 7 — Almacenamiento de datos | Favoritos persistentes con Hive, `PlaceRepository` |
| `sesion-08` | Sesión 8 — Integración con Firebase | Authentication, Firestore (reseñas), reglas de seguridad |
| `sesion-09` | Sesión 9 — IA y modelos LLM en Flutter | Pantalla "Asistente ExploraIA", consumo del backend de IA |
| `sesion-10` | Sesión 10 — Proyecto final | Punto de partida para pulido final — sin `TODO` pendientes, base para la entrega |

No existe una rama `sesion-01`: en esa sesión el proyecto se crea desde cero con `flutter create` (ver `sesiones/sesion-01/instructivo-practica-sesion-01.md` del curso) y todavía no se conecta a este repo — la Sesión 2 es la primera vez que se agrega como remoto.

Cada rama se creó a partir de la anterior (`git checkout -b sesion-03 sesion-02`, etc.), así que `git log --oneline` refleja la progresión real de la práctica del curso.

## Advertencia de verificación

El código de este repo fue escrito y revisado cuidadosamente contra la documentación oficial de cada paquete, pero **no fue compilado ni ejecutado contra un SDK de Flutter real** (el entorno donde se generó este curso no tiene Flutter/Dart instalado). Antes de dictar cada sesión, ejecuta `flutter pub get`, `flutter analyze` y `flutter run` sobre la rama correspondiente y corrige cualquier detalle de API que haya cambiado de versión. Esto aplica también al comando `git checkout starter/sesion-NN -- lib pubspec.yaml PLACEHOLDERS.md` en sí: pruébalo una vez de punta a punta antes de la primera clase.
