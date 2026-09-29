import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'bindings/places_binding.dart';
import 'firebase_options.dart';
import 'screens/assistant_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/home_screen.dart';
import 'screens/map_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  // Hive y Firebase necesitan el motor de Flutter listo antes de pedirle
  // algo al sistema operativo — por eso `main` es `async` y arranca con
  // `ensureInitialized()` antes que nada más.
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox<Map>('lugares_cache');
  await Hive.openBox<Map>('favoritos');
  // `firebase_options.dart` NO viene en este repo (mira `.gitignore`): lo
  // genera `flutterfire configure` con los datos de TU propio proyecto de
  // Firebase — Paso 2 de la práctica de la Sesión 8. Sin ese paso, este
  // archivo no existe y el proyecto no compila; es exactamente lo que se
  // espera hasta completarlo, no un error de este código.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ExploraEcApp());
}

/// `MaterialApp` → `GetMaterialApp` — Sesión 4. Sigue siendo Material por
/// debajo (mismo `theme`, mismos widgets); `GetMaterialApp` agrega encima
/// la navegación de GetX (`Get.to`, usada desde esta sesión en `PlaceCard`
/// y `MapScreen`) y `initialBinding`, que registra `PlacesController` (con
/// su `PlaceRepository`, Sesión 7) una sola vez, antes de que cualquier
/// pantalla lo necesite.
class ExploraEcApp extends StatelessWidget {
  const ExploraEcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'ExploraEC',
      theme: AppTheme.theme,
      initialBinding: PlacesBinding(),
      home: const RootShell(),
    );
  }
}

/// Contenedor raíz con la barra de navegación inferior — Sesión 2.
class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _indiceActual = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: switch (_indiceActual) {
        0 => const HomeScreen(),
        1 => const MapScreen(),
        2 => const FavoritesScreen(),
        _ => const AssistantScreen(),
      },
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indiceActual,
        type: BottomNavigationBarType.fixed,
        onTap: (i) => setState(() => _indiceActual = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Mapa'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favoritos'),
          BottomNavigationBarItem(icon: Icon(Icons.smart_toy_outlined), label: 'Asistente'),
        ],
      ),
    );
  }
}
