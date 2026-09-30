import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../models/place.dart';
import '../models/review.dart';
import '../services/location_service.dart';
import '../services/reviews_service.dart';
import 'login_screen.dart';

/// Pantalla de Detalle: recibe un [Place] completo por su constructor,
/// sin volver a consultar ninguna lista — Sesión 2. Desde la Sesión 5,
/// cuando se llega desde el Mapa, recibe además la distancia ya calculada
/// (no vuelve a pedir la ubicación: el Mapa ya la tenía). Desde la Sesión 8
/// agrega la sección de reseñas colaborativas (Firestore).
class DetailScreen extends StatelessWidget {
  final Place place;
  final double? distanciaMetros;
  const DetailScreen({super.key, required this.place, this.distanciaMetros});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(place.nombre)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            place.nombre,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              Chip(label: Text(place.categoria)),
              if (distanciaMetros != null)
                Chip(
                  avatar: const Icon(Icons.near_me, size: 16),
                  label: Text('A ${formatearDistancia(distanciaMetros!)} de ti'),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(place.descripcion, style: const TextStyle(fontSize: 16)),
          const Divider(height: 32),
          Text('Reseñas', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          _ReviewsSection(placeId: place.id),
        ],
      ),
    );
  }
}

/// Widget aparte (no todo `DetailScreen`) porque necesita su propio
/// `TextEditingController` para el formulario de reseña — con `Stateless`
/// alcanzaba para el resto de la pantalla, pero un campo de texto sí
/// necesita un `State` que lo sostenga entre reconstrucciones.
class _ReviewsSection extends StatefulWidget {
  final String placeId;
  const _ReviewsSection({required this.placeId});

  @override
  State<_ReviewsSection> createState() => _ReviewsSectionState();
}

class _ReviewsSectionState extends State<_ReviewsSection> {
  final _textoCtrl = TextEditingController();
  int _calificacion = 5;
  final AuthController _auth = Get.find<AuthController>();

  Future<void> _enviarReseña() async {
    final usuario = _auth.usuario.value;
    if (usuario == null) return; // el botón ya está oculto sin sesión, pero se valida igual
    if (_textoCtrl.text.trim().isEmpty) return;
    await ReviewsService.agregar(Review(
      id: '', // Firestore genera el id real al hacer .add()
      placeId: widget.placeId,
      userId: usuario.uid,
      userEmail: usuario.email ?? '(sin correo)',
      texto: _textoCtrl.text.trim(),
      calificacion: _calificacion,
      timestamp: DateTime.now(),
    ));
    _textoCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Obx(() {
          if (!_auth.estaAutenticado) {
            return OutlinedButton(
              onPressed: () => Get.to(() => const LoginScreen()),
              child: const Text('Inicia sesión para dejar una reseña'),
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _textoCtrl,
                decoration: const InputDecoration(hintText: 'Escribe tu reseña...'),
                maxLines: 2,
              ),
              Row(
                children: [
                  DropdownButton<int>(
                    value: _calificacion,
                    items: [1, 2, 3, 4, 5]
                        .map((n) => DropdownMenuItem(value: n, child: Text('$n ★')))
                        .toList(),
                    onChanged: (n) => setState(() => _calificacion = n ?? 5),
                  ),
                  const Spacer(),
                  ElevatedButton(onPressed: _enviarResena, child: const Text('Publicar')),
                ],
              ),
            ],
          );
        }),
        const SizedBox(height: 12),
        StreamBuilder<List<Review>>(
          stream: ReviewsService.observarResenas(widget.placeId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final resenas = snapshot.data ?? [];
            if (resenas.isEmpty) {
              return const Text('Todavía no hay reseñas de este lugar.');
            }
            return Column(
              children: resenas.map((r) {
                final esPropia = r.userId == _auth.usuario.value?.uid;
                return ListTile(
                  title: Text('${'★' * r.calificacion} — ${r.userEmail}'),
                  subtitle: Text(r.texto),
                  trailing: esPropia
                      ? IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => ReviewsService.eliminar(r.id),
                        )
                      : null,
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
