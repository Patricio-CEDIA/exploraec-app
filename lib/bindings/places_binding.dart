import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../controllers/places_controller.dart';
import '../repositories/place_repository.dart';

/// Registra las dependencias que la app necesita desde el arranque —
/// Sesión 4 (`PlacesController`), Sesión 7 (`PlaceRepository`, que envuelve
/// la caja de Hive ya abierta en `main.dart` antes de correr la app).
class PlacesBinding extends Bindings {
  @override
  void dependencies() {
    final repositorio = PlaceRepository(Hive.box<Map>('lugares_cache'));
    Get.put(PlacesController(repositorio));
  }
}
