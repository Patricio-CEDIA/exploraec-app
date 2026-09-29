import 'package:cloud_firestore/cloud_firestore.dart';

/// Reseña de un lugar — Sesión 8. A diferencia de [Place] (caché local con
/// Hive, Sesión 7), una reseña es información **colaborativa**: cualquier
/// usuario debe poder ver las reseñas de todos los demás, así que vive en
/// Firestore (la nube), no en el dispositivo.
class Review {
  final String id;
  final String placeId;
  final String userId;
  final String userEmail;
  final String texto;
  final int calificacion; // 1 a 5
  final DateTime timestamp;

  Review({
    required this.id,
    required this.placeId,
    required this.userId,
    required this.userEmail,
    required this.texto,
    required this.calificacion,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
        'placeId': placeId,
        'userId': userId,
        'userEmail': userEmail,
        'texto': texto,
        'calificacion': calificacion,
        // `serverTimestamp()` pide la hora al servidor de Firestore, no al
        // reloj del celular — evita que una reseña quede "primero" solo
        // porque el dispositivo que la escribió tenía la hora mal puesta.
        'timestamp': FieldValue.serverTimestamp(),
      };

  factory Review.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final datos = doc.data()!;
    return Review(
      id: doc.id,
      placeId: datos['placeId'] as String,
      userId: datos['userId'] as String,
      userEmail: datos['userEmail'] as String,
      texto: datos['texto'] as String,
      calificacion: datos['calificacion'] as int,
      // `serverTimestamp()` llega como `null` en la primera lectura local
      // (antes de que el servidor confirme la escritura) — se usa "ahora"
      // como valor de reserva solo para ese instante muy breve.
      timestamp: (datos['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
