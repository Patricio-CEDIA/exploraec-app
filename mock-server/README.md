# mock-server — Asistente ExploraIA (Sesión 9)

Servidor local de prueba para la pantalla "Asistente" de la app. Simula el backend real de IA sin llamar a ningún proveedor de LLM ni necesitar ninguna API key — devuelve una recomendación armada con una heurística simple de palabras clave.

No es parte de la app Flutter: es un pequeño servidor aparte que corres en tu computadora mientras pruebas la app en el emulador/dispositivo.

## Requisitos

- Node.js instalado (18 o superior) — `node --version` para confirmar. No hace falta `npm install`: el script solo usa el módulo `http` incluido en Node.

## Cómo correrlo

```bash
node mock-server.js
```

Deja esta terminal abierta mientras usas la app — vas a ver en consola cada consulta que llega desde ExploraEC.

## A qué URL debe apuntar la app

El servidor escucha en `http://localhost:3000` en tu computadora, pero "localhost" significa algo distinto según dónde corre la app:

| Dónde corre la app | URL que usa `kAiBackendUrl` |
|---|---|
| Emulador Android | `http://10.0.2.2:3000` (dirección especial que el emulador traduce al `localhost` de tu computadora) |
| Simulador iOS | `http://localhost:3000` (el simulador SÍ comparte la red de tu Mac directamente) |
| Dispositivo físico (Android o iOS) en la misma red Wi-Fi | `http://<IP-de-tu-computadora-en-la-red>:3000` (ej. `http://192.168.1.50:3000` — obtén tu IP con `ipconfig` en Windows o `ifconfig`/`ip addr` en Mac/Linux) |

Ver `instructivo-practica-sesion-09.md` (Paso 3) para cómo cambiar este valor sin editar el código: `flutter run --dart-define=LLM_BACKEND_URL=http://192.168.1.50:3000`.

## Referencia (no se ejecuta en este curso)

`referencia-backend-cloud-function.md` muestra cómo se vería el backend real desplegado, con una API key de verdad — léelo, no lo corras.
