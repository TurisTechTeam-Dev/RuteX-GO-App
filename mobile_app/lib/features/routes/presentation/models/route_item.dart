import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_contract.dart';

class RouteItem {
  final String id;
  final String title;
  final String description;
  final String difficulty;
  final String time;
  final int totalPois;
  final int totalPoints;
  final String image;

  const RouteItem({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.time,
    required this.totalPois,
    required this.totalPoints,
    required this.image,
  });

  String get pointsLabel => "$totalPoints puntos";

  factory RouteItem.fromDoc(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final pointsOfInterest = data[RouteFields.idPuntosInteres] as List?;
    final totalPois = pointsOfInterest?.length ?? 0;

    return RouteItem(
      id: doc.id,
      title: data[RouteFields.nombre]?.toString() ?? 'Ruta',
      description: data[RouteFields.descripcion]?.toString() ?? '',
      difficulty: data[RouteFields.dificultad]?.toString() ?? 'Media',
      time: data[RouteFields.duracion]?.toString() ?? '--',
      totalPois: totalPois,
      totalPoints:
          (data[RouteFields.puntosTotales] as num?)?.toInt() ??
          _routeTotalPoints(totalPois),
      image:
          data[RouteFields.imagenAsset]?.toString() ??
          "assets/merida_monumental.png",
    );
  }

  static int _routeTotalPoints(int totalStops) {
    if (totalStops <= 0) return 0;
    return (totalStops * 30) + 10;
  }
}
