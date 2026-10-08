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
git remote add starter <GITHUB_REPOSITORY_URL>
git fetch starter
```

El flujo esperado en cada sesión (a partir de la Sesión 2):

1. Traer la rama de tu sesión actual, solo los archivos que este repo gestiona: `git fetch starter && git checkout starter/sesion-NN -- lib test pubspec.yaml PLACEHOLDERS.md` (más las carpetas extra que indique el `PLACEHOLDERS.md` de la rama: `mock-server`, `docs`, `.github`)`.
2. Ejecutar `flutter pub get`.
3. Ubicar los bloques `TODO(sesion-NN)` documentados en `PLACEHOLDERS.md` de esa rama (o buscarlos con tu editor), leer su comentario `// Por qué:`.
4. Descomentar el bloque real siguiendo el instructivo (desde la Sesión 8 todos los bloques son solo de descomentar; en las sesiones 2 a 7 además hay que borrar el bloque provisional).
5. Ejecutar y verificar.

**Importante:** este repo no incluye el esqueleto completo que genera `flutter create` (carpetas `android/`, `ios/`, `web/`, etc.) — esas las genera el propio Flutter SDK, una sola vez, en la Sesión 1, y no vuelven a tocarse. Este repo es una **capa superpuesta** con los archivos específicos de ExploraEC (`lib/`, `pubspec.yaml`) — el flujo completo, de punta a punta:

```bash
flutter create exploraec        # Sesión 1, una sola vez
cd exploraec
# Sesión 2 en adelante: git remote add starter <GITHUB_REPOSITORY_URL> (una sola vez)
#                       git fetch starter && git checkout starter/sesion-NN -- lib test pubspec.yaml PLACEHOLDERS.md
flutter pub get
flutter run
```

Sesiones con archivos adicionales fuera de `lib/`/`pubspec.yaml` (ver el `PLACEHOLDERS.md` de esa rama para el comando exacto): la Sesión 9 también trae la carpeta `mock-server/` y la Sesión 10 trae `docs/` y `.github/`.

Algunos cambios (permisos nativos de la Sesión 5) no viven en este repo porque son específicos de tu propio proyecto o de tu propia cuenta — cada rama documenta en su `PLACEHOLDERS.md` cuáles son y cómo aplicarlos a mano.

## Ramas disponibles

| Rama | Punto de partida para | Qué agrega/completa esa sesión |
|---|---|---|
| `sesion-02` | Sesión 2 — Widgets básicos y avanzados | Modelo `Place`, lista de lugares en memoria (`ListView`/`GridView`, `PlaceCard`), pantalla de detalle, formulario "Agregar lugar", navegación inferior |
| `sesion-03` | Sesión 3 — Interfaces y UX | Tema Material, estados de carga/vacío/error reutilizables, layout responsivo |
| `sesion-04` | Sesión 4 — Gestión de estado con GetX | `PlacesController`, `Obx`, navegación e inyección de dependencias con GetX |
| `sesion-05` | Sesión 5 — Mapas y geolocalización | Permisos de ubicación, posición actual, pantalla de Mapa con `flutter_map` |
| `sesion-06` | Sesión 6 — Programación asíncrona | «Gastos del viaje» contra el backend de gastos (`http`), estados loading/success/error |
| `sesion-07` | Sesión 7 — Almacenamiento de datos | Caché de gastos con Hive (`GastosRepository`) y favoritos persistentes |
| `sesion-08` | Sesión 8 — Backend propio: autenticación JWT y CRUD de gastos | `dio` con interceptores, token en `flutter_secure_storage`, `AuthController`, CRUD de gastos y errores del backend |
| `sesion-09` | Sesión 9 — IA y modelos LLM en Flutter | Pestaña «Asistente ExploraIA», `AiAssistantService`, proxy local `mock-server/` (sin claves de IA), confirmación humana antes de registrar un gasto |
| `sesion-10` | Sesión 10 — Cierre de calidad y entrega | Manejo de errores no controlados, pruebas de widgets, plantilla de README y lista de verificación, workflow de GitHub Actions que publica el APK |

No existe una rama `sesion-01`: en esa sesión el proyecto se crea desde cero con `flutter create` (ver `sesiones/sesion-01/instructivo-practica-sesion-01.md` del curso) y todavía no se conecta a este repo — la Sesión 2 es la primera vez que se agrega como remoto.

Cada rama se creó a partir de la anterior (`git checkout -b sesion-03 sesion-02`, etc.), así que `git log --oneline` refleja la progresión real de la práctica del curso.

## Estado de verificación

Las ramas `sesion-08`, `sesion-09` y `sesion-10` se ejecutaron paso a paso en un emulador Android contra el backend de gastos, y cada una trae pruebas (`flutter test`) cuyo número de aciertos sube a medida que se descomentan sus bloques (la tabla está en el `PLACEHOLDERS.md` de cada rama). Aun así, antes de dictar cada sesión conviene ejecutar `flutter pub get`, `flutter test` y `flutter run` sobre la rama correspondiente, porque las versiones de los paquetes pueden cambiar. El workflow de `sesion-10` (`.github/workflows/release-apk.yml`) debe probarse una vez en un repositorio de prueba antes de la clase.
