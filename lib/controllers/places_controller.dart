import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../models/place.dart';
import '../repositories/place_repository.dart';
import '../services/location_service.dart';
import '../services/places_api_service.dart';

enum EstadoCarga { cargando, exito, error }

/// Fuente única de verdad de los lugares, la posición y los favoritos del
/// usuario — Sesión 4 (lugares/posición) y Sesión 7 (favoritos + caché).
/// Antes de la Sesión 4, el estado de la lista vivía atrapado dentro de
/// `HomeScreen`. Ahora todas las pantallas leen del mismo
/// `PlacesController`, registrado una sola vez por `PlacesBinding` y
/// obtenido con `Get.find()` (vía `GetView`, ver `HomeScreen`/`MapScreen`).
class PlacesController extends GetxController {
  final PlaceRepository _repository;
  PlacesController(this._repository);

  final RxList<Place> lugares = <Place>[].obs;
  final Rx<EstadoCarga> estado = EstadoCarga.cargando.obs;
  final RxString mensajeError = ''.obs;
  final Rx<Position?> posicion = Rx<Position?>(null);
  final Rx<EstadoCarga> estadoPosicion = EstadoCarga.cargando.obs;
  final RxString mensajeErrorPosicion = ''.obs;

  /// `true` solo cuando la última carga exitosa vino de la caché local de
  /// la Sesión 7 (la llamada remota falló) — la UI lo usa para mostrar un
  /// aviso de "datos guardados", nunca para ocultar que pueden estar
  /// desactualizados.
  final RxBool desdeCache = false.obs;

  /// Favoritos persistentes — Sesión 7. `_favoritosBox` es el almacenamiento
  /// (sobrevive reiniciar la app); `favoritos` es el espejo reactivo que la
  /// UI observa con `Obx` — el mismo patrón de "Hive guarda, Rx notifica"
  /// que usa `PlaceRepository` para la caché de lugares.
  final RxList<Place> favoritos = <Place>[].obs;
  late final Box<Map> _favoritosBox;

  /// Estado derivado (Sesión 4, Paso 5): se calcula a partir de `lugares`.
  int get total => lugares.length;

  /// Worker (Sesión 4, Paso 5): reacciona a cada cambio de `estado`.
  void _observarErrores() {
    ever(estado, (EstadoCarga e) {
      if (e == EstadoCarga.error) {
        Get.snackbar('Error', mensajeError.value);
      }
    });
  }

  bool _modoDebugError = false;
  bool _modoDebugVacio = false;

  @override
  void onInit() {
    _observarErrores();
    super.onInit();
    _favoritosBox = Hive.box<Map>('favoritos');
    favoritos.value = _favoritosBox.values
        .map((mapa) => Place.fromMap(Map<String, dynamic>.from(mapa)))
        .toList();
    cargarLugares();
  }

  /// Simula uno de los 3 estados a propósito, solo para esta práctica —
  /// mismo recurso que ya traía `HomeScreen` desde la Sesión 3, ahora
  /// centralizado aquí porque el Mapa también necesita poder mostrarlos.
  void simular(String modo) {
    _modoDebugError = modo == 'error';
    _modoDebugVacio = modo == 'vacio';
    cargarLugares();
  }

  Future<void> cargarLugares() async {
    estado.value = EstadoCarga.cargando;
    try {
      // Reutiliza la posición ya guardada (Sesión 5): pedirla al sistema en
      // cada carga fallaría justo sin conexión, que es cuando la caché ayuda.
      if (posicion.value == null) {
        await cargarPosicion();
      }
      final pos = posicion.value;
      if (pos == null) {
        throw LocationException(mensajeErrorPosicion.value);
      }

      // TODO(sesion-07): borra el bloque de abajo y descomenta el bloque completo. (Paso 2 — repositorio con caché)
      // Por qué: el bloque de abajo llama a PlacesApiService directo,
      // igual que en la Sesión 6 — si no hay red, cargarLugares() falla
      // sin más. El bloque real pasa por _repository.obtenerLugaresCercanos,
      // que primero intenta la red y, si falla, devuelve la última copia
      // guardada en Hive (marcando desdeCache = true) en vez de fallar.
      final reales = await PlacesApiService.buscarLugaresCercanos(
        pos,
        forzarError: _modoDebugError,
        forzarVacio: _modoDebugVacio,
      );
      lugares.value = [...reales, ...lugaresEjemplo];
      desdeCache.value = false;
      estado.value = EstadoCarga.exito;
      // final (resultado, cache) = await _repository.obtenerLugaresCercanos(
      //   pos,
      //   forzarError: _modoDebugError,
      //   forzarVacio: _modoDebugVacio,
      // );
      // lugares.value = [...resultado, ...lugaresEjemplo];
      // desdeCache.value = cache;
      // estado.value = EstadoCarga.exito;
    } catch (e) {
      mensajeError.value = '$e';
      estado.value = EstadoCarga.error;
    }
  }

  /// Pide la posición real al sistema operativo una sola vez y la deja en
  /// [posicion]; si ya la tiene, no vuelve a pedirla salvo que se pida con
  /// [forzar] (por ejemplo, desde el botón "Reintentar" del Mapa).
  Future<void> cargarPosicion({bool forzar = false}) async {
    if (posicion.value != null && !forzar) {
      estadoPosicion.value = EstadoCarga.exito;
      return;
    }
    estadoPosicion.value = EstadoCarga.cargando;
    try {
      posicion.value = await LocationService.obtenerPosicionActual();
      estadoPosicion.value = EstadoCarga.exito;
    } on LocationException catch (e) {
      mensajeErrorPosicion.value = e.mensaje;
      estadoPosicion.value = EstadoCarga.error;
    } catch (e) {
      mensajeErrorPosicion.value = '$e';
      estadoPosicion.value = EstadoCarga.error;
    }
  }

  /// Agrega un lugar creado a mano (`AddPlaceScreen`) — en memoria
  /// únicamente; no se guarda en la caché de la Sesión 7 a propósito, para
  /// mantener separadas dos cosas distintas: la caché es una copia de lo
  /// que devuelve la Overpass API, no un lugar inventado por el usuario.
  void agregarLugar(Place lugar) {
    lugaresEjemplo.add(lugar);
    lugares.add(lugar);
  }

  bool esFavorito(Place lugar) => favoritos.any((p) => p.id == lugar.id);

  // TODO(sesion-07): borra la línea de abajo y descomenta el bloque completo. (Paso 3 — favoritos persistentes)
  // Por qué: el método vacío de abajo no guarda ni quita nada — la
  // versión real agrega o elimina el lugar de _favoritosBox (Hive, lo
  // que sobrevive reiniciar la app) y de la lista reactiva favoritos
  // (lo que Obx observa para actualizar el ícono al instante).
  void alternarFavorito(Place lugar) {}
  // void alternarFavorito(Place lugar) {
  //   if (esFavorito(lugar)) {
  //     _favoritosBox.delete(lugar.id);
  //     favoritos.removeWhere((p) => p.id == lugar.id);
  //   } else {
  //     _favoritosBox.put(lugar.id, lugar.toMap());
  //     favoritos.add(lugar);
  //   }
  // }

  double? distanciaA(Place lugar) {
    final pos = posicion.value;
    return pos == null ? null : distanciaAPlaceEnMetros(pos, lugar);
  }
}
