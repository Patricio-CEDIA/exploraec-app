import 'dart:async';
import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../models/place.dart';

/// URL del backend de IA — Sesión 9. Nunca apunta a un proveedor de LLM
/// directamente: es un backend propio (ver `mock-server/` para una versión
/// local de prueba, y `mock-server/referencia-backend-cloud-function.md`
/// para cómo se vería ese backend desplegado de verdad, con su API key del
/// lado del servidor). Cambia este valor por la URL de tu mock local
/// (Paso 3 de la práctica) — `10.0.2.2` es el loopback especial con el que
/// el emulador Android alcanza el `localhost` de tu propia máquina; el
/// simulador de iOS, en cambio, sí ve `localhost` directamente.
const String kAiBackendUrl = String.fromEnvironment(
  'LLM_BACKEND_URL',
  defaultValue: 'http://10.0.2.2:3000',
);

class RecomendacionIA {
  final String texto;
  final String? lugarId;
  RecomendacionIA({required this.texto, this.lugarId});

  factory RecomendacionIA.fromJson(Map<String, dynamic> json) => RecomendacionIA(
        texto: json['recomendacion'] as String? ?? 'El asistente no devolvió una recomendación.',
        lugarId: json['lugarId'] as String?,
      );
}

class AiAssistantException implements Exception {
  final String mensaje;
  AiAssistantException(this.mensaje);
  @override
  String toString() => mensaje;
}

class AiAssistantService {
  AiAssistantService._();

  /// Pide una recomendación al backend de IA, mandando solo lo necesario:
  /// la consulta del usuario, un resumen liviano de los lugares ya
  /// cargados (id/nombre/categoría — no la descripción completa), y una
  /// ubicación **aproximada** (redondeada a ~1 km) en vez de la posición
  /// exacta del GPS — el backend no necesita saber en qué esquina exacta
  /// está el usuario para sugerir "un café cerca"; enviar menos precisión
  /// de la necesaria es la forma más simple de aplicar el principio de
  /// privacidad visto en la teoría, no solo un párrafo aparte.
  static Future<RecomendacionIA> pedirRecomendacion({
    required String consulta,
    required List<Place> lugares,
    Position? posicion,
  }) async {
    final uri = Uri.parse('$kAiBackendUrl/recomendacion');
    final cuerpo = jsonEncode({
      'consulta': consulta,
      'lugares': lugares.map((l) => {'id': l.id, 'nombre': l.nombre, 'categoria': l.categoria}).toList(),
      if (posicion != null)
        'ubicacionAprox': {
          'lat': double.parse(posicion.latitude.toStringAsFixed(2)),
          'lng': double.parse(posicion.longitude.toStringAsFixed(2)),
        },
    });

    try {
      final respuesta = await http
          .post(uri, headers: {'Content-Type': 'application/json'}, body: cuerpo)
          .timeout(const Duration(seconds: 15));

      if (respuesta.statusCode != 200) {
        throw AiAssistantException('El asistente respondió con un error (${respuesta.statusCode}).');
      }
      return RecomendacionIA.fromJson(jsonDecode(respuesta.body) as Map<String, dynamic>);
    } on TimeoutException {
      throw AiAssistantException('El asistente tardó demasiado en responder. Intenta de nuevo.');
    } on http.ClientException {
      throw AiAssistantException(
        'No se pudo conectar con el backend de IA. ¿Está corriendo tu mock-server? (ver mock-server/README.md)',
      );
    } on FormatException {
      throw AiAssistantException('El backend respondió con un formato inesperado.');
    }
  }
}
