/// Modelo de datos de ExploraEC — Sesión 2.
class Place {
  final String id;
  final String nombre;
  final String categoria;
  final String descripcion;
  final double lat;
  final double lng;

  Place({
    required this.id,
    required this.nombre,
    required this.categoria,
    required this.descripcion,
    required this.lat,
    required this.lng,
  });

  /// Construye un [Place] a partir de un elemento `node` de la respuesta
  /// JSON de la Overpass API — Sesión 6. Un nodo real casi nunca trae todos
  /// los campos: `tags.name` en particular suele faltar (el lugar existe en
  /// el mapa pero nadie cargó su nombre en OpenStreetMap), así que se arma
  /// un nombre de reserva a partir de la categoría (`amenity`) antes que
  /// mostrar un lugar sin nombre.
  factory Place.fromOverpassElement(Map<String, dynamic> el) {
    final tags = (el['tags'] as Map?)?.cast<String, dynamic>() ?? const {};
    final categoria = (tags['amenity'] as String?) ?? 'lugar';
    final nombre = (tags['name'] as String?) ?? _capitalizar(categoria);
    return Place(
      id: 'osm-${el['id']}',
      nombre: nombre,
      categoria: _capitalizar(categoria),
      descripcion: (tags['description'] as String?) ??
          'Lugar cercano de tipo "$categoria", datos abiertos de OpenStreetMap.',
      lat: (el['lat'] as num).toDouble(),
      lng: (el['lon'] as num).toDouble(),
    );
  }

  /// Serialización manual para la caché local con Hive — Sesión 7. Todos
  /// los campos son tipos primitivos (`String`/`double`), así que un
  /// `Map<String, dynamic>` alcanza sin necesitar un `TypeAdapter` generado.
  Map<String, dynamic> toMap() => {
        'id': id,
        'nombre': nombre,
        'categoria': categoria,
        'descripcion': descripcion,
        'lat': lat,
        'lng': lng,
      };

  factory Place.fromMap(Map<String, dynamic> mapa) => Place(
        id: mapa['id'] as String,
        nombre: mapa['nombre'] as String,
        categoria: mapa['categoria'] as String,
        descripcion: mapa['descripcion'] as String,
        lat: (mapa['lat'] as num).toDouble(),
        lng: (mapa['lng'] as num).toDouble(),
      );
}

String _capitalizar(String texto) =>
    texto.isEmpty ? texto : '${texto[0].toUpperCase()}${texto.substring(1)}';

/// Lugares agregados a mano desde `AddPlaceScreen` — en memoria únicamente,
/// se pierden al reiniciar la app hasta que la Sesión 7 los persista con
/// Hive. Desde la Sesión 6, `PlacesController.cargarLugares()` los combina con
/// los lugares reales que trae la Overpass API (`PlacesApiService`).
final List<Place> lugaresEjemplo = [
  Place(
    id: '1',
    nombre: 'Parque El Ejido',
    categoria: 'Parques',
    descripcion: 'Parque urbano en el centro-norte de Quito, con ferias de arte los fines de semana.',
    lat: -0.2073,
    lng: -78.4900,
  ),
  Place(
    id: '2',
    nombre: 'Café Galletti',
    categoria: 'Cafeterías',
    descripcion: 'Cafetería de especialidad con opciones de trabajo remoto y buen wifi.',
    lat: -0.1938,
    lng: -78.4869,
  ),
  Place(
    id: '3',
    nombre: 'Museo Casa del Alabado',
    categoria: 'Museos',
    descripcion: 'Museo de arte precolombino en el Centro Histórico de Quito.',
    lat: -0.2201,
    lng: -78.5125,
  ),
  Place(
    id: '4',
    nombre: 'Mercado Central',
    categoria: 'Restaurantes',
    descripcion: 'Mercado tradicional con puestos de comida típica ecuatoriana.',
    lat: -0.2185,
    lng: -78.5110,
  ),
  Place(
    id: '5',
    nombre: 'Parque La Carolina',
    categoria: 'Parques',
    descripcion: 'Parque metropolitano con jardín botánico, canchas deportivas y lago para botes.',
    lat: -0.1807,
    lng: -78.4859,
  ),
  Place(
    id: '6',
    nombre: 'Vista Hermosa',
    categoria: 'Restaurantes',
    descripcion: 'Restaurante con terraza y vista panorámica del Centro Histórico.',
    lat: -0.2199,
    lng: -78.5122,
  ),
];
