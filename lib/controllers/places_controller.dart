import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import '../models/place.dart';
import '../services/location_service.dart';
import '../services/places_api_service.dart';

enum EstadoCarga { cargando, exito, error }

/// Fuente única de verdad de los lugares y de la posición del usuario —
/// Sesiones 4, 5 y 6. Desde la Sesión 6, `cargarLugares()` consulta la
/// Overpass API con la posición real en vez de la carga simulada de la
/// Sesión 3: la interfaz (`Obx`, `LoadingView`/`EmptyView`/`ErrorView`) no
/// cambia una sola línea, solo cambia de dónde vienen los datos.
class PlacesController extends GetxController {
  final RxList<Place> lugares = <Place>[].obs;
  final Rx<EstadoCarga> estado = EstadoCarga.cargando.obs;
  final RxString mensajeError = ''.obs;
  final Rx<Position?> posicion = Rx<Position?>(null);
  final Rx<EstadoCarga> estadoPosicion = EstadoCarga.cargando.obs;
  final RxString mensajeErrorPosicion = ''.obs;

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
    cargarLugares();
  }

  /// Simula uno de los 3 estados a propósito, solo para esta práctica —
  /// mismo recurso que `HomeScreen` traía desde la Sesión 3, ahora
  /// centralizado aquí para que cualquier pantalla pueda mostrarlos.
  void simular(String modo) {
    _modoDebugError = modo == 'error';
    _modoDebugVacio = modo == 'vacio';
    cargarLugares();
  }

  Future<void> cargarLugares() async {
    estado.value = EstadoCarga.cargando;

    // TODO(sesion-06): borra las dos líneas de abajo y descomenta el bloque completo. (Paso 3 — datos reales)
    // Por qué: las 2 líneas de abajo fuerzan éxito con una lista vacía,
    // sin llamar a nada real. El bloque try/catch real toma la posición
    // que el controller ya guarda desde la Sesión 5 (pidiéndola si aún no
    // existe), consulta la Overpass API con `PlacesApiService` y traduce
    // el resultado —o la excepción— a los mismos 3 estados de siempre, así
    // que `HomeScreen` y `MapScreen` no cambian.
    lugares.value = [];
    estado.value = EstadoCarga.exito;
    // try {
    //   if (posicion.value == null) {
    //     await cargarPosicion();
    //   }
    //   final pos = posicion.value;
    //   if (pos == null) {
    //     throw LocationException(mensajeErrorPosicion.value);
    //   }
    //   final reales = await PlacesApiService.buscarLugaresCercanos(
    //     pos,
    //     forzarError: _modoDebugError,
    //     forzarVacio: _modoDebugVacio,
    //   );
    //   lugares.value = [...reales, ...lugaresEjemplo];
    //   estado.value = EstadoCarga.exito;
    // } catch (e) {
    //   mensajeError.value = '$e';
    //   estado.value = EstadoCarga.error;
    // }
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
  /// únicamente hasta que la Sesión 7 lo persista con Hive. `lugares.add`
  /// (en vez de reconstruir toda la lista) ya notifica a cualquier `Obx`
  /// que esté escuchando, en Inicio y en el Mapa a la vez.
  void agregarLugar(Place lugar) {
    lugaresEjemplo.add(lugar);
    lugares.add(lugar);
  }

  double? distanciaA(Place lugar) {
    final pos = posicion.value;
    return pos == null ? null : distanciaAPlaceEnMetros(pos, lugar);
  }
}
