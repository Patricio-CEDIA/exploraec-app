import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import '../controllers/places_controller.dart';
import '../models/place.dart';
import '../theme/app_theme.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';
import 'detail_screen.dart';

/// Pantalla de Mapa real — Sesión 5. Comparte el mismo `PlacesController`
/// que `HomeScreen` (Sesión 4): la posición y los lugares se piden una sola
/// vez (en el controller), no una vez por pantalla.
class MapScreen extends GetView<PlacesController> {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mapa')),
      body: Obx(() {
        if (controller.estado.value == EstadoCarga.cargando || controller.posicion.value == null) {
          return const LoadingView(mensaje: 'Obteniendo tu ubicación...');
        }
        if (controller.estado.value == EstadoCarga.error) {
          return ErrorView(
            mensaje: controller.mensajeError.value,
            onReintentar: controller.cargarLugares,
          );
        }
        return _buildMapa(context, controller.posicion.value!, controller.lugares);
      }),
    );
  }

  Widget _buildMapa(BuildContext context, Position posicion, List<Place> lugares) {
    final miUbicacion = LatLng(posicion.latitude, posicion.longitude);
    return FlutterMap(
      options: MapOptions(initialCenter: miUbicacion, initialZoom: 15),
      children: [
        // La política de uso de tiles de OSM exige un userAgentPackageName
        // real que identifique la app — no dejar el valor de ejemplo del
        // paquete en una app publicada.
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.tmo.exploraec',
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: miUbicacion,
              width: 40,
              height: 40,
              child: const Icon(Icons.my_location, color: Colors.blue, size: 32),
            ),
            ...lugares.map(
              (lugar) => Marker(
                point: LatLng(lugar.lat, lugar.lng),
                width: 40,
                height: 40,
                child: GestureDetector(
                  onTap: () => Get.to(() => DetailScreen(
                        place: lugar,
                        distanciaMetros: controller.distanciaA(lugar),
                      )),
                  child: Icon(Icons.place, color: AppTheme.colorPrimario, size: 36),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
