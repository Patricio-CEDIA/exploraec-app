# Proxy del asistente ExploraIA (modo mock)

Servidor local de la Sesión 9. **No forma parte de la app Flutter.** Responde con reglas simples, sin llamar a ningún proveedor de IA y sin ninguna clave.

## Cómo se usa

```bash
cd mock-server
node mock-server.js
```

Requiere Node.js 18 o superior. Si el puerto 3000 está ocupado, usa otro con la variable `PORT` (`PORT=3001 node mock-server.js`; en PowerShell: `$env:PORT=3001; node mock-server.js`) y apunta la app al mismo puerto.

## Contrato

`POST /asistente`, con la cabecera `Authorization: Bearer <token>` (el proxy no la lee ni la registra: en un proxy real se reenviaría al backend si hiciera falta actuar en nombre de la persona).

Petición:

```json
{ "consulta": "¿cuánto me queda en comida?",
  "resumen": { "categorias": [ { "categoria": "comida", "total": 20.0, "cantidad": 2, "disponible": 480.0 } ],
               "total_general": 20.0 } }
```

Respuesta (`accion` es opcional):

```json
{ "respuesta": "Te quedan 480.00 en comida (límite de 500 por categoría).",
  "accion": { "tipo": "registrar_gasto", "descripcion": "Almuerzo", "monto": 6.5, "categoria": "comida" } }
```

## Probar el proxy sin la app

Con el proxy encendido, desde la carpeta raíz del proyecto (en PowerShell usa `curl.exe` en vez de `curl`):

```bash
curl -X POST -H "Content-Type: application/json" -d @mock-server/ejemplo-consulta.json http://localhost:3000/asistente
curl -X POST -H "Content-Type: application/json" -d @mock-server/ejemplo-registro.json http://localhost:3000/asistente
```

## URL según dónde corre la app

| Entorno | `LLM_BACKEND_URL` |
|---|---|
| Emulador Android | `http://10.0.2.2:3000` (valor por defecto, sin flag) |
| Simulador iOS | `http://localhost:3000` |
| Dispositivo físico | `http://<IP-de-tu-computador>:3000` (misma red Wi-Fi) |

Se cambia con `--dart-define=LLM_BACKEND_URL=...`. El backend de gastos tiene su propia URL (`API_BASE_URL`, puerto 8000).

## Qué reconoce el modo mock

| Escribes | Responde |
|---|---|
| ¿En qué categoría gasto más? | La categoría con mayor total del resumen |
| ¿Cuánto me queda en comida? | El campo `disponible` de esa categoría |
| Registra un almuerzo de 6.50 en comida | Propone una `accion` (la app pide confirmación antes de crear nada) |
| ¿Qué lugar barato de comida me recomiendas? | Una respuesta genérica |
| Cualquier otra cosa | «No entendí tu pregunta…» |

## Qué cambiaría con una IA real

El proxy armaría un *prompt* con la consulta y el resumen, y llamaría al modelo con una clave guardada en una variable de entorno **del servidor**. La app, el contrato y el resto del código no cambian. Este proxy del curso **no incluye** esa llamada: no hay claves en este repositorio.
