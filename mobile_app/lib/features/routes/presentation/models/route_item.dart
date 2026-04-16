import 'package:cloud_firestore/cloud_firestore.dart';

class RouteItem {
  final String id;
  final String title;
  final String description;
  final String difficulty;
  final String time;
  final int totalPois;
  final String image;

  const RouteItem({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.time,
    required this.totalPois,
    required this.image,
  });

  String get pointsLabel => "$totalPois puntos";

  factory RouteItem.fromDoc(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final pointsOfInterest = data['id_puntos_interes'] as List?;

    return RouteItem(
      id: doc.id,
      title: data['nombre']?.toString() ?? 'Ruta',
      description: data['descripcion']?.toString() ?? '',
      difficulty: data['dificultad']?.toString() ?? 'Media',
      time: data['duracion']?.toString() ?? '--',
      totalPois: pointsOfInterest?.length ?? 0,
      image: data['imagen_asset']?.toString() ?? "assets/merida_monumental.png",
    );
  }
}
