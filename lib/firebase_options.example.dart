// Plantilla de referencia — Sesión 8.
//
// Este archivo NO se usa directamente. `flutterfire configure` genera tu
// propio `lib/firebase_options.dart` (con la forma que ves abajo, pero con
// los valores reales de TU proyecto de Firebase) — ese archivo generado
// está en `.gitignore` a propósito: sus valores son específicos de cada
// proyecto de Firebase (uno por estudiante o por equipo), no un secreto
// que haya que ocultar por seguridad (a diferencia de una API key de LLM,
// ver Sesión 9). Simplemente no tiene sentido compartir el mismo archivo
// entre proyectos de Firebase distintos.
//
// Para generar el tuyo:
//   dart pub global activate flutterfire_cli
//   flutterfire configure
//
// Eso reemplaza este archivo de ejemplo por tu `lib/firebase_options.dart`
// real, con las opciones de cada plataforma ya completas.

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions no está configurado para esta plataforma — '
          'este curso solo cubre Android e iOS.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_API_KEY',
    appId: 'YOUR_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_API_KEY',
    appId: 'YOUR_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
    iosBundleId: 'com.example.exploraec',
  );
}
