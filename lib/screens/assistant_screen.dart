import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/places_controller.dart';
import '../models/place.dart';
import '../services/ai_assistant_service.dart';
import 'detail_screen.dart';

/// Asistente ExploraIA — Sesión 9. Solo recomienda entre los lugares que
/// `PlacesController` ya tiene cargados (Overpass, Sesión 6) — no es un
/// chatbot de propósito general. La consulta y un resumen liviano de esos
/// lugares viajan a `<LLM_BACKEND_URL>`, nunca a un proveedor de LLM
/// directamente desde este archivo (ver `AiAssistantService`).
class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final _consultaCtrl = TextEditingController();
  final PlacesController _places = Get.find<PlacesController>();

  bool _cargando = false;
  String? _error;
  RecomendacionIA? _resultado;

  Future<void> _preguntar() async {
    if (_consultaCtrl.text.trim().isEmpty) return;
    setState(() {
      _cargando = true;
      _error = null;
      _resultado = null;
    });

    // TODO(sesion-09): borra el bloque de abajo (stub) y descomenta el bloque real. (Paso 4 — conectar el backend)
    // Por qué: el stub de abajo espera un poco y siempre muestra el
    // mismo mensaje fijo, sin llamar a nada — el bloque real llama a
    // AiAssistantService, que a su vez llama al backend propio (nunca
    // directo a un proveedor de LLM), pasándole la consulta, los
    // lugares ya cargados y la posición, para que la recomendación
    // salga de datos reales de la app, no de texto inventado.
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() {
      _cargando = false;
      _error = 'Conecta AiAssistantService (Paso 4) para obtener una recomendación real.';
    });
    // try {
    //   final recomendacion = await AiAssistantService.pedirRecomendacion(
    //     consulta: _consultaCtrl.text.trim(),
    //     lugares: _places.lugares,
    //     posicion: _places.posicion.value,
    //   );
    //   setState(() => _resultado = recomendacion);
    // } on AiAssistantException catch (e) {
    //   setState(() => _error = e.mensaje);
    // } finally {
    //   setState(() => _cargando = false);
    // }
  }

  Place? _buscarLugar(String? id) {
    if (id == null) return null;
    for (final lugar in _places.lugares) {
      if (lugar.id == id) return lugar;
    }
    return null;
  }

  @override
  void dispose() {
    _consultaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Asistente ExploraIA')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Cuéntale qué buscas entre los lugares ya cargados. '
              'Esto es una sugerencia generada por IA — verifica la información antes de decidir.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _consultaCtrl,
              decoration: const InputDecoration(
                hintText: 'Ej. tengo 20 minutos y quiero tomar algo cerca',
              ),
              onSubmitted: (_) => _preguntar(),
            ),
            const SizedBox(height: 12),
            // TODO(sesion-09): OPCIONAL — descomenta el bloque de abajo (Paso 7 — preguntas sugeridas). No borres nada.
            // Por qué: una caja de texto vacía obliga a inventar qué preguntar
            // (el "problema de la página en blanco" de la UX de un asistente).
            // Cada chip escribe una consulta de ejemplo en el campo y reutiliza
            // el mismo `_preguntar()` de siempre: no hay un segundo camino hacia
            // el backend. Se deshabilitan mientras hay una consulta en curso.
            // Wrap(
            //   spacing: 8,
            //   children: [
            //     'Tengo 20 minutos y quiero tomar algo cerca',
            //     'Un lugar para comer',
            //     'Qué puedo visitar hoy',
            //   ]
            //       .map(
            //         (texto) => ActionChip(
            //           label: Text(texto),
            //           onPressed: _cargando
            //               ? null
            //               : () {
            //                   _consultaCtrl.text = texto;
            //                   _preguntar();
            //                 },
            //         ),
            //       )
            //       .toList(),
            // ),
            // const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _cargando ? null : _preguntar,
              child: _cargando
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Preguntar'),
            ),
            const SizedBox(height: 24),
            if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
            if (_resultado != null) ...[
              Text(_resultado!.texto, style: const TextStyle(fontSize: 16)),
              if (_resultado!.lugarId != null && _buscarLugar(_resultado!.lugarId) != null) ...[
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => Get.to(() => DetailScreen(place: _buscarLugar(_resultado!.lugarId)!)),
                  child: const Text('Ver lugar recomendado'),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
