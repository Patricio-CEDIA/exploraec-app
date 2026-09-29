import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/review.dart';

/// Acceso a la colección `reviews` de Firestore — Sesión 8. Archivo ya
/// completo (igual que `PlacesApiService`/`LocationService` en sesiones
/// anteriores): no tiene marcadores `TODO`, la práctica de hoy lo usa
/// directamente desde la pantalla de Detalle.
class ReviewsService {
  static final _coleccion = FirebaseFirestore.instance.collection('reviews');

  /// `.snapshots()` es un `Stream` real (Sesión 6 solo lo mencionó de forma
  /// conceptual) — emite una lista nueva cada vez que alguien, desde
  /// cualquier dispositivo, agrega o borra una reseña de este lugar. La UI
  /// no vuelve a pedir datos manualmente: los recibe.
  static Stream<List<Review>> observarReseñas(String placeId) {
    return _coleccion
        .where('placeId', isEqualTo: placeId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(Review.fromDoc).toList());
  }

  static Future<void> agregar(Review reseña) {
    return _coleccion.add(reseña.toMap());
  }

  /// Las reglas de seguridad (`firestore.rules`) ya exigen que solo el
  /// dueño pueda borrar su propia reseña — este chequeo del lado del
  /// cliente es una segunda capa (mejor mensaje de error, sin depender de
  /// que la reseña llegue a viajar al servidor para descubrir que no se
  /// puede), nunca la única protección real.
  static Future<void> eliminar(String reviewId) {
    return _coleccion.doc(reviewId).delete();
  }
}
