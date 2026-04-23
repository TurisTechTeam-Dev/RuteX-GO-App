import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_contract.dart';

class RouteItem {
  final String id;
  final String title;
  final String description;
  final String difficulty;
  final String time;
  final List<String> pointIds;
  final int totalPois;
  final int totalPoints;
  final String image;

  const RouteItem({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.time,
    required this.pointIds,
    required this.totalPois,
    required this.totalPoints,
    required this.image,
  });

  String get pointsLabel => "$totalPoints puntos";

  factory RouteItem.fromDoc(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final pointsOfInterest = data[RouteFields.idPuntosInteres] as List?;
    final pointIds = pointsOfInterest?.map((point) => point.toString()).toList() ??
        const <String>[];
    final totalPois = pointsOfInterest?.length ?? 0;

    return RouteItem(
      id: doc.id,
      title: data[RouteFields.nombre]?.toString() ?? 'Ruta',
      description: data[RouteFields.descripcion]?.toString() ?? '',
      difficulty: data[RouteFields.dificultad]?.toString() ?? 'Media',
      time: _routeDurationLabel(data),
      pointIds: pointIds,
      totalPois: totalPois,
      totalPoints:
          (data[RouteFields.puntosTotales] as num?)?.toInt() ??
          _routeTotalPoints(totalPois),
      image: _routeImage(data),
    );
  }

  static int _routeTotalPoints(int totalStops) {
    if (totalStops <= 0) return 0;
    return (totalStops * 30) + 10;
  }

  static String _routeDurationLabel(Map<String, dynamic> data) {
    const fallbackKeys = [
      RouteFields.duracion,
      'duracion_estimada',
      'duracionEstimada',
      'tiempo',
      'time',
    ];

    for (final key in fallbackKeys) {
      final value = data[key]?.toString().trim();
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }

    for (final entry in data.entries) {
      final normalizedKey = entry.key.trim().toLowerCase();
      if (normalizedKey == RouteFields.duracion ||
          normalizedKey == 'duración' ||
          normalizedKey == 'duracion_estimada' ||
          normalizedKey == 'duracionestimada' ||
          normalizedKey == 'tiempo' ||
          normalizedKey == 'time') {
        final value = entry.value?.toString().trim();
        if (value != null && value.isNotEmpty) {
          return value;
        }
      }
    }

    return '--';
  }

  static String _routeImage(Map<String, dynamic> data) {
    const fallbackKeys = [
      RouteFields.imagen,
      RouteFields.imagenAsset,
      'image',
      'imagen_url',
    ];

    for (final key in fallbackKeys) {
      final value = data[key]?.toString().trim();
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }

    return "assets/merida_monumental.png";
  }
}
