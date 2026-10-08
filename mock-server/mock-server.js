// Proxy del asistente ExploraIA — Sesión 9 (MODO MOCK).
//
// La app NO habla con ningún modelo de IA: habla con este proxy. Aquí el proxy
// responde con reglas simples (sin llamar a ningún proveedor), pero cumple el
// mismo contrato que tendría uno real. Una clave de un proveedor de IA, si
// existiera, viviría SOLO aquí (variable de entorno del servidor), nunca en la
// app. Sin dependencias externas: solo Node.js 18 o superior.
//
// Contrato:  POST /asistente   (Authorization: Bearer <token> en la cabecera)
//   cuerpo:    { "consulta": "...", "resumen": { "categorias": [...], "total_general": 0 } }
//   respuesta: { "respuesta": "...", "accion": { tipo, descripcion, monto, categoria } }   (accion es opcional)

const http = require('http');

const PUERTO = Number(process.env.PORT) || 3000;
const CATEGORIAS = ['comida', 'transporte', 'entretenimiento', 'otros'];

const dinero = (n) => Number(n).toFixed(2);

function normalizar(texto) {
  return String(texto).toLowerCase().normalize('NFD').replace(/[̀-ͯ]/g, '');
}

function categoriaMencionada(texto) {
  return CATEGORIAS.find((c) => texto.includes(normalizar(c)));
}

/** Reglas del modo mock: lo que un LLM real haría con un prompt, aquí con if. */
function responder(consulta, resumen) {
  const texto = normalizar(consulta);
  const filas = Array.isArray(resumen && resumen.categorias) ? resumen.categorias : [];

  // «registra un almuerzo de 6.50 en comida» -> propone una acción (la app pide confirmación)
  const registro = texto.match(/registra(?:r)?\s+(?:un|una)?\s*([a-z ]+?)\s+de\s+(\d+(?:[.,]\d+)?)\s+en\s+([a-z]+)/);
  if (registro) {
    const categoria = categoriaMencionada(registro[3]);
    if (categoria) {
      const monto = Number(registro[2].replace(',', '.'));
      const descripcion = registro[1].trim().replace(/^./, (c) => c.toUpperCase());
      return {
        respuesta: `Puedo registrar «${descripcion}» por ${dinero(monto)} en ${categoria}. Confírmalo para guardarlo.`,
        accion: { tipo: 'registrar_gasto', descripcion, monto, categoria },
      };
    }
  }

  // «¿cuánto me queda en comida?» -> campo `disponible` de esa categoría
  if (texto.includes('queda')) {
    const categoria = categoriaMencionada(texto);
    const fila = filas.find((f) => f.categoria === categoria);
    if (fila) {
      return { respuesta: `Te quedan ${dinero(fila.disponible)} en ${categoria} (límite de 500 por categoría).` };
    }
  }

  // «¿en qué categoría gasto más?» -> la categoría con mayor total
  if (texto.includes('categoria') && (texto.includes('mas') || texto.includes('mayor'))) {
    const conGasto = filas.filter((f) => Number(f.total) > 0).sort((a, b) => b.total - a.total);
    if (conGasto.length === 0) return { respuesta: 'Aún no tienes gastos registrados, así que no hay una categoría que destaque.' };
    return { respuesta: `Gastas más en ${conGasto[0].categoria}: ${dinero(conGasto[0].total)} en ${conGasto[0].cantidad} gasto(s).` };
  }

  // «¿qué lugar barato de comida me recomiendas?» -> respuesta genérica (el mock no conoce los lugares)
  if (texto.includes('lugar') && texto.includes('barato')) {
    return { respuesta: 'Los mercados y las fondas del centro suelen ser la opción más económica para comer. (Respuesta genérica del modo mock: no conoce los lugares de la app.)' };
  }

  return { respuesta: 'No entendí tu pregunta. En modo mock solo reconozco: «¿en qué categoría gasto más?», «¿cuánto me queda en <categoría>?» y «registra un <descripción> de <monto> en <categoría>».' };
}

const servidor = http.createServer((req, res) => {
  const enviar = (codigo, cuerpo) => {
    res.writeHead(codigo, { 'Content-Type': 'application/json; charset=utf-8' });
    res.end(JSON.stringify(cuerpo));
  };

  if (req.method !== 'POST' || req.url !== '/asistente') {
    return enviar(404, { detail: 'Ruta no encontrada. Usa POST /asistente.' });
  }

  const trozos = [];
  req.on('data', (t) => trozos.push(t));
  req.on('end', () => {
    const bruto = Buffer.concat(trozos);
    let cuerpo;
    try {
      cuerpo = JSON.parse(bruto.toString('utf8'));
    } catch (_) {
      return enviar(400, { detail: 'El cuerpo no es un JSON válido.' });
    }
    if (typeof cuerpo.consulta !== 'string' || cuerpo.consulta.trim() === '') {
      return enviar(422, { detail: 'Falta el campo «consulta».' });
    }
    // Registro de lo que llegó: tamaño y NOMBRES de campos. Nunca el contenido ni la cabecera Authorization.
    const filas = cuerpo.resumen && Array.isArray(cuerpo.resumen.categorias) ? cuerpo.resumen.categorias.length : 0;
    console.log(`Petición: ${bruto.length} bytes · campos: ${Object.keys(cuerpo).join(', ')} · categorías en el resumen: ${filas}`);
    enviar(200, responder(cuerpo.consulta, cuerpo.resumen));
  });
});

servidor.listen(PUERTO, () => {
  console.log(`Proxy del asistente (modo MOCK, sin clave de IA) escuchando en http://localhost:${PUERTO}`);
  console.log(`Desde el emulador Android, la app debe apuntar a http://10.0.2.2:${PUERTO}`);
});
