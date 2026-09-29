import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../models/place.dart';

/// Lugares reales cercanos — Sesión 6. Consulta la Overpass API de
/// OpenStreetMap (datos abiertos, sin API key) por nodos `amenity` dentro
/// de un radio alrededor de una posición.
///
/// Se limita a `type == "node"` a propósito: `way`/`relation` no traen
/// `lat`/`lon` directos (habría que calcular su centroide), y ese cálculo
/// queda fuera del alcance de este curso — se menciona en la teoría, no se
/// implementa.
class PlacesApiService {
  PlacesApiService._();

  static const _endpoint = 'https://overpass-api.de/api/interpreter';
  static const _categorias = ['cafe', 'restaurant', 'park', 'pharmacy'];
  static const _radioMetros = 1500;

  /// [forzarError]/[forzarVacio] existen solo para la práctica, para poder
  /// demostrar los 3 estados sin depender de que Overpass responda distinto
  /// cada vez — no forman parte de la versión final de la app.
  static Future<List<Place>> buscarLugaresCercanos(
    Position posicion, {
    bool forzarError = false,
    bool forzarVacio = false,
  }) async {
    if (forzarError) {
      throw Exception('No se pudo conectar con Overpass (simulado para la práctica)');
    }
    if (forzarVacio) return <Place>[];

    final query = _construirQuery(posicion);
    late final http.Response respuesta;
    try {
      respuesta = await http
          .post(Uri.parse(_endpoint), body: {'data': query})
          .timeout(const Duration(seconds: 15));
    } on SocketException {
      throw Exception('Sin conexión a internet. Verifica tu red e intenta de nuevo.');
    } on TimeoutException {
      throw Exception('Overpass tardó demasiado en responder. Puede estar saturada — intenta en un momento.');
    }

    if (respuesta.statusCode == 429) {
      throw Exception('Demasiadas solicitudes a Overpass — espera unos segundos antes de reintentar.');
    }
    if (respuesta.statusCode != 200) {
      throw Exception('Overpass respondió con un error (código ${respuesta.statusCode}).');
    }

    final Map<String, dynamic> cuerpo;
    try {
      cuerpo = jsonDecode(respuesta.body) as Map<String, dynamic>;
    } on FormatException {
      throw Exception('La respuesta de Overpass no se pudo interpretar como JSON.');
    }

    final elementos = (cuerpo['elements'] as List? ?? const []).cast<Map<String, dynamic>>();
    return elementos
        .where((el) => el['type'] == 'node')
        .map(Place.fromOverpassElement)
        .toList();
  }

  /// Overpass QL: nodos cuyo tag `amenity` coincide con alguna de
  /// [_categorias] (regex de alternancia `^(cafe|restaurant|...)$`), dentro
  /// de `around:radio,lat,lon`. `out;` sin `center` porque un `node` ya trae
  /// `lat`/`lon` directos — `center` solo hace falta para `way`/`relation`,
  /// que esta consulta ni siquiera pide.
  static String _construirQuery(Position posicion) {
    final alternativas = _categorias.join('|');
    return '''
[out:json][timeout:15];
node["amenity"~"^($alternativas)\$"](around:$_radioMetros,${posicion.latitude},${posicion.longitude});
out;
''';
  }
}
