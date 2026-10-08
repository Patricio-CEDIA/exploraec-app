# Placeholders de esta rama (sesion-10)

Punto de partida: ExploraEC con la Sesión 9 resuelta (Asistente ExploraIA con proxy, confirmación humana y preguntas sugeridas). Tráela con:

```bash
git fetch starter
git checkout starter/sesion-10 -- lib test pubspec.yaml PLACEHOLDERS.md docs .github
flutter pub get
```

El objetivo de esta sesión es el **cierre de calidad** de ExploraEC: capturar los errores que nadie esperaba, probar con pruebas de widgets, auditar secretos, generar el APK con GitHub Actions y preparar la entrega del Proyecto Final. No agrega funcionalidad nueva ni dependencias nuevas.

**Todos los bloques son solo de descomentar**: nada que borrar ni copiar. Selecciona las líneas comentadas que están **debajo** de `TODO(sesion-10) Paso N` (no el `TODO` ni el «Por qué») y presiona `Ctrl + /` (`Cmd + /` en Mac).

## Archivos ya completos (sin `TODO`)
- `lib/widgets/error_pantalla_view.dart` — la vista amistosa que reemplaza a la pantalla roja.
- `lib/screens/pantalla_con_fallo.dart` — pantalla que falla a propósito (solo práctica).
- `lib/screens/gastos_screen.dart` — el menú «⋮» suma, solo en modo depuración, «Provocar error de pantalla» y «Provocar error asíncrono».
- `lib/main.dart` — llama a `ReporteErrores.instalar()` antes de `runApp`.
- `.github/workflows/release-apk.yml` — compila, prueba y publica el APK al subir una etiqueta `v*`.
- `docs/README-plantilla.md` y `docs/lista-de-verificacion.md` — plantilla de `README.md` y la rúbrica del Proyecto Final convertida en preguntas.

## Qué descomentar

| Archivo | Bloque | Paso |
|---|---|---|
| `lib/utils/reporte_errores.dart` | `instalar()`: capturar errores no controlados | 2 |
| `test/sesion_10_test.dart` | Tres pruebas de widgets | 3 |
| `lib/screens/gastos_screen.dart` | Opción «Acerca de» y la línea que abre las licencias (2 bloques) | 8 (opcional) |

## Pruebas

`test/sesion_10_test.dart` usa un servidor falso. Junto con las 22 de las Sesiones 8 y 9 suman 25 con la rama recién traída; al terminar cada paso:

| Después del Paso | Pasan | Fallan |
|---|---|---|
| 1 (rama recién traída) | 24 | 1 |
| 2 | 25 | 0 |
| 3 | 28 | 0 |

Ejecutarlas: `flutter test`.
