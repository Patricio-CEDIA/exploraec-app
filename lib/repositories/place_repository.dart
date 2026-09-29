import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';

import '../models/place.dart';
import '../services/places_api_service.dart';

/// Repositorio de lugares — Sesión 7. Antes de esta sesión, `PlacesController`
/// llamaba a `PlacesApiService` directamente: si la Overpass API fallaba
/// (sin conexión, tiempo de espera agotado), la app no tenía nada que
/// mostrar salvo el error. Este repositorio agrega una caché local con
/// Hive: si la llamada remota falla, devuelve lo último que sí se guardó,
/// en vez de dejar la pantalla vacía.
///
/// Serialización manual (`Place.toMap()`/`Place.fromMap()`) en vez de un
/// `TypeAdapter` generado con `build_runner`/`hive_generator`: para un
/// modelo tan simple (6 campos, todos tipos primitivos), un adapter
/// generado agrega un paso de compilación adicional
/// (`dart run build_runner build`) sin ahorrar código real frente a un
/// `toMap()`/`fromMap()` de pocas líneas. Si `Place` creciera con tipos
/// anidados o enums, ese sería el momento de reconsiderar el adapter
/// generado — no antes.
class PlaceRepository {
  final Box<Map> _cache;

  PlaceRepository(this._cache);

  /// Devuelve un registro `(lugares, desdeCache)`. `desdeCache` es `true`
  /// solo cuando la llamada remota falló y se usó lo último guardado en el
  /// dispositivo — la UI lo usa para mostrar un aviso, nunca para ocultar
  /// que los datos pueden estar desactualizados.
  Future<(List<Place>, bool)> obtenerLugaresCercanos(
    Position posicion, {
    bool forzarError = false,
    bool forzarVacio = false,
  }) async {
    try {
      final reales = await PlacesApiService.buscarLugaresCercanos(
        posicion,
        forzarError: forzarError,
        forzarVacio: forzarVacio,
      );
      // No se cachea el resultado de la simulación "vacío" de la práctica:
      // si se guardara, borraría la caché real solo por haber probado ese
      // botón de demostración. Un "vacío" real de la Overpass API (de
      // verdad no hay lugares en el radio) sí debería cachearse — esta
      // excepción es únicamente para el modo de simulación.
      if (!forzarVacio) {
        await _guardarEnCache(reales);
      }
      return (reales, false);
    } catch (e) {
      final cacheados = _leerCache();
      if (cacheados.isNotEmpty) return (cacheados, true);
      rethrow;
    }
  }

  Future<void> _guardarEnCache(List<Place> lugares) async {
    await _cache.clear();
    for (final lugar in lugares) {
      await _cache.put(lugar.id, lugar.toMap());
    }
  }

  List<Place> _leerCache() => _cache.values
      .map((mapa) => Place.fromMap(Map<String, dynamic>.from(mapa)))
      .toList();
}
