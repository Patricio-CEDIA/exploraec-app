// Mock del backend de IA — Sesión 9. Usa SOLO el módulo `http` incluido en
// Node.js (sin `npm install`, sin dependencias) a propósito: para esta
// práctica de 50 minutos, levantar un servidor real de un proveedor de LLM
// no aporta nada que un servidor de mentira, con una respuesta ya escrita,
// no enseñe igual de bien sobre el lado de Flutter (que es lo que importa
// hoy). El backend REAL de un proveedor de LLM se ve en
// `referencia-backend-cloud-function.md`, al lado de este archivo — ese sí
// necesitaría una API key, nunca hardcodeada, siempre desde una variable de
// entorno del servidor.
//
// Cómo correrlo:
//   node mock-server.js
// Escucha en http://localhost:3000

const http = require('node:http');

const PUERTO = 3000;

// Heurística simple por palabra clave — no es IA de verdad, es un mock.
// Si la consulta menciona "café"/"tomar algo", prioriza una categoría de
// tipo cafetería/restaurante entre los lugares recibidos; si no encuentra
// ninguno, cae a un texto genérico.
function generarRecomendacion(consulta, lugares) {
  const texto = (consulta || '').toLowerCase();
  const buscaComida = /caf[eé]|comer|tomar algo|restaurante|hambre/.test(texto);

  if (buscaComida && Array.isArray(lugares)) {
    const candidato = lugares.find((l) =>
      /caf|restaurant/i.test(l.categoria || ''),
    );
    if (candidato) {
      return {
        recomendacion: `Te recomiendo "${candidato.nombre}" (${candidato.categoria}) — está entre los lugares que ya tienes cargados y encaja con lo que buscas.`,
        lugarId: candidato.id,
      };
    }
  }

  if (Array.isArray(lugares) && lugares.length > 0) {
    const primero = lugares[0];
    return {
      recomendacion: `No encontré una coincidencia exacta para "${consulta}", pero "${primero.nombre}" es una opción cercana que ya tienes cargada.`,
      lugarId: primero.id,
    };
  }

  return {
    recomendacion: 'No hay lugares cargados todavía para poder recomendarte algo — vuelve a la pantalla de Inicio primero.',
    lugarId: null,
  };
}

const servidor = http.createServer((req, res) => {
  if (req.method !== 'POST' || req.url !== '/recomendacion') {
    res.writeHead(404, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ error: 'Ruta no encontrada. Usa POST /recomendacion.' }));
    return;
  }

  let cuerpo = '';
  req.on('data', (fragmento) => {
    cuerpo += fragmento;
  });

  req.on('end', () => {
    try {
      const datos = JSON.parse(cuerpo || '{}');
      // Simula la latencia real de un proveedor de LLM (medio segundo) —
      // así la práctica también ejercita el estado de carga de la app.
      setTimeout(() => {
        const resultado = generarRecomendacion(datos.consulta, datos.lugares);
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify(resultado));
      }, 500);
    } catch (error) {
      res.writeHead(400, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ error: 'JSON inválido en el cuerpo de la petición.' }));
    }
  });
});

servidor.listen(PUERTO, () => {
  console.log(`Mock del backend de IA escuchando en http://localhost:${PUERTO}`);
  console.log('Desde el emulador Android, la app debe apuntar a http://10.0.2.2:3000');
});
