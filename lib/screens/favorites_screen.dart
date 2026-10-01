import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../controllers/places_controller.dart';
import '../widgets/empty_view.dart';
import '../widgets/place_card.dart';
import 'login_screen.dart';

/// Favoritos persistentes con Hive — Sesión 7. Reemplaza el placeholder
/// fijo de la Sesión 2: ahora lee `controller.favoritos`, la lista
/// reactiva respaldada por la caja de Hive que sobrevive reiniciar la app
/// (ver `PlacesController`). Desde la Sesión 8, exige sesión iniciada: los
/// favoritos no cambian de dueño, así que sin saber quién es el usuario no
/// tendría sentido mostrarlos (ni tenerlos, en una futura versión con
/// favoritos sincronizados en la nube por usuario).
class FavoritesScreen extends GetView<PlacesController> {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favoritos'),
        // Por qué: `AuthController.cerrarSesion()` ya existe desde el Paso 3,
        // pero ninguna pantalla lo llama. Este botón lo conecta: al cerrar
        // sesión, `authStateChanges()` emite un usuario nulo, `usuario` cambia
        // y el `Obx` de abajo vuelve solo al aviso "Inicia sesión" — sin
        // código extra. El propio botón desaparece porque también está
        // dentro de un `Obx`.
        actions: [
          Obx(
            () => auth.estaAutenticado
                ? IconButton(
                    icon: const Icon(Icons.logout),
                    tooltip: 'Cerrar sesión',
                    onPressed: () async {
                      await auth.cerrarSesion();
                      Get.snackbar('Sesión cerrada', 'Vuelve a iniciar sesión para guardar favoritos.');
                    },
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
      body: Obx(() {
        if (!auth.estaAutenticado) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Inicia sesión para ver y guardar tus favoritos.'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => Get.to(() => const LoginScreen()),
                    child: const Text('Iniciar sesión'),
                  ),
                ],
              ),
            ),
          );
        }
        if (controller.favoritos.isEmpty) {
          return const EmptyView(
            mensaje: 'Todavía no marcaste ningún lugar como favorito.\n'
                'Toca el corazón en cualquier tarjeta para guardarlo aquí.',
            icono: Icons.favorite_border,
          );
        }
        return ListView.builder(
          itemCount: controller.favoritos.length,
          itemBuilder: (context, index) => PlaceCard(place: controller.favoritos[index]),
        );
      }),
    );
  }
}
