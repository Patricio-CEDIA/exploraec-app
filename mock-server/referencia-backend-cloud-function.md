# Referencia: cómo se vería el backend real de IA

> Código de referencia — **no se despliega en este curso**. La práctica de la Sesión 9 usa `mock-server.js` (mismo directorio), que no llama a ningún proveedor de LLM real. Este archivo existe solo para que quede claro, con código concreto, dónde y cómo viviría la API key real si este backend se desplegara de verdad.

## El patrón, independiente del proveedor

Cualquier proveedor de LLM (Claude, GPT, u otro) se consume igual desde un backend: la API key vive en una variable de entorno **del servidor**, nunca en el código que se sube a un repositorio, y nunca en el cliente móvil.

## Ejemplo: Cloud Function de Firebase (Node.js)

```javascript
// functions/index.js — ejemplo de referencia, no desplegado en este curso.
const functions = require('firebase-functions');

exports.recomendacion = functions.https.onRequest(async (req, res) => {
  if (req.method !== 'POST') {
    res.status(405).send('Método no permitido');
    return;
  }

  const { consulta, lugares, ubicacionAprox } = req.body;

  // La API key vive SOLO aquí, del lado del servidor, leída de una
  // variable de entorno configurada en la consola de Firebase — nunca
  // escrita en este archivo ni en el repositorio.
  const apiKey = process.env.LLM_API_KEY;
  if (!apiKey) {
    res.status(500).json({ error: 'Backend mal configurado: falta LLM_API_KEY' });
    return;
  }

  try {
    // Llamada real al proveedor de LLM que corresponda (Claude, GPT, u
    // otro) — la forma exacta de la petición depende del proveedor, el
    // punto que importa aquí es que la key nunca sale de este servidor.
    const prompt = construirPrompt(consulta, lugares, ubicacionAprox);
    const respuestaLlm = await llamarProveedorLlm(prompt, apiKey);

    res.status(200).json({
      recomendacion: respuestaLlm.texto,
      lugarId: respuestaLlm.lugarIdSugerido ?? null,
    });
  } catch (error) {
    console.error('Error consultando al LLM:', error);
    res.status(502).json({ error: 'El asistente no está disponible en este momento.' });
  }
});

function construirPrompt(consulta, lugares, ubicacionAprox) {
  const listado = (lugares || [])
    .map((l) => `- ${l.nombre} (${l.categoria}, id: ${l.id})`)
    .join('\n');
  return [
    'Eres el asistente de la app ExploraEC. Recomienda UN lugar de la',
    'siguiente lista, en español, en 1-2 frases, y devuelve su id exacto.',
    `Ubicación aproximada del usuario: ${JSON.stringify(ubicacionAprox ?? 'no proporcionada')}`,
    `Lugares disponibles:\n${listado}`,
    `Pedido del usuario: "${consulta}"`,
  ].join('\n');
}

// La implementación real de esta función depende del SDK del proveedor de
// LLM elegido — se omite aquí a propósito, el punto de este ejemplo es el
// manejo de la API key, no un proveedor específico.
async function llamarProveedorLlm(prompt, apiKey) {
  throw new Error('Reemplazar con la llamada real al SDK del proveedor de LLM elegido.');
}
```

## Despliegue (fuera del alcance de este curso, solo para referencia)

```bash
firebase functions:config:set llm.api_key="TU_API_KEY_AQUI"
firebase deploy --only functions
```

La API key nunca aparece en el código fuente ni en el repositorio — se configura como variable de entorno del propio servicio en la nube (Firebase, o el proveedor de hosting de backend que se use), exactamente igual que `.env`/variables de entorno en cualquier otro backend.
