import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/place.dart';
import '../screens/detail_screen.dart';
import '../theme/app_theme.dart';

/// Tarjeta reutilizable que representa un [Place] en cualquier lista de
/// la app (Inicio, resultados de categoría, etc.) — Sesión 2.
/// Accesibilidad y colores de marca aplicados en la Sesión 3. Navegación
/// con GetX (`Get.to`) desde la Sesión 4, en vez de `Navigator.push` +
/// `MaterialPageRoute` — Flutter sigue usando `Navigator` por debajo,
/// `Get.to` solo evita repetir `MaterialPageRoute(builder: ...)` en cada
/// lugar que navega, y no pide `context` para hacerlo.
class PlaceCard extends StatelessWidget {
  final Place place;
  const PlaceCard({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: InkWell(
        onTap: () => Get.to(() => DetailScreen(place: place)),
        child: Semantics(
          label: '${place.nombre}, categoría ${place.categoria}',
          hint: 'Toca dos veces para ver el detalle',
          button: true,
          excludeSemantics: true,
          child: _buildContenido(context),
        ),
      ),
    );
  }

  Widget _buildContenido(BuildContext context) {
    final estilos = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.place, size: 32, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  place.nombre,
                  style: estilos.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(place.categoria, style: estilos.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  place.descripcion,
                  style: estilos.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
