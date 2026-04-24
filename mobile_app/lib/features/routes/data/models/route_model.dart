import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_contract.dart';
import '../../../../core/utils/text_normalizer.dart';
import '../../domain/entities/tourist_route.dart';

class RouteModel extends TouristRoute {
  const RouteModel({
    required super.id,
    required super.cityId,
    required super.title,
    required super.description,
    required super.difficulty,
    required super.time,
    required super.pointIds,
    required super.totalPois,
    required super.totalPoints,
    required super.image,
  });

  factory RouteModel.fromSnapshot(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final pointIds = _stringList(data[RouteFields.idPuntosInteres]);
    final totalPois = pointIds.length;

    return RouteModel(
      id: doc.id,
      cityId: _cityId(data),
      title: data[RouteFields.nombre]?.toString() ?? 'Ruta',
      description: data[RouteFields.descripcion]?.toString() ?? '',
      difficulty: data[RouteFields.dificultad]?.toString() ?? 'Media',
      time: _routeDurationLabel(data),
      pointIds: pointIds,
      totalPois: totalPois,
      totalPoints:
          _intValue(data[RouteFields.puntosTotales]) ??
          _routeTotalPoints(totalPois),
      image: _routeImage(data),
    );
  }

  static List<String> _stringList(dynamic rawValue) {
    if (rawValue == null) return const <String>[];

    if (rawValue is Iterable) {
      return rawValue
          .map(_stringValue)
          .where((value) => value.isNotEmpty)
          .toList();
    }

    final singleValue = _stringValue(rawValue);
    return singleValue.isEmpty ? const <String>[] : <String>[singleValue];
  }

  static String _stringValue(dynamic rawValue) {
    if (rawValue == null) return '';

    if (rawValue is DocumentReference) {
      return rawValue.id.trim();
    }

    if (rawValue is Map) {
      const nestedKeys = ['id', 'uid', 'path', 'ref', 'reference'];
      for (final key in nestedKeys) {
        final value = _stringValue(rawValue[key]);
        if (value.isNotEmpty) return value;
      }
    }

    final value = rawValue.toString().trim();
    if (value.isEmpty) return '';

    final segments = value.split('/');
    final lastSegment = segments.last.trim();
    return lastSegment.isEmpty ? value : lastSegment;
  }

  static int? _intValue(dynamic rawValue) {
    if (rawValue is num) return rawValue.toInt();
    if (rawValue is String) return int.tryParse(rawValue.trim());
    return null;
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

  static String _cityId(Map<String, dynamic> data) {
    const cityFieldKeys = [
      RouteFields.idCiudad,
      'idCiudad',
      'ciudad_id',
      'ciudadId',
      'id_ciudades',
      'idCiudadRef',
      'ciudad',
      'ciudad_ref',
      'ciudadRef',
      'cityId',
      'city_id',
      'city',
    ];

    for (final key in cityFieldKeys) {
      final normalized = _cityIdFromValue(data[key]);
      if (normalized.isNotEmpty) return normalized;
    }

    for (final entry in data.entries) {
      final key = TextNormalizer.toAsciiSlug(entry.key);
      if (!key.contains('ciudad') && !key.contains('city')) continue;

      final normalized = _cityIdFromValue(entry.value);
      if (normalized.isNotEmpty) return normalized;
    }

    return _cityIdFromRouteText(data);
  }

  static String _cityIdFromRouteText(Map<String, dynamic> data) {
    final searchableText = [
      data[RouteFields.nombre],
      data[RouteFields.descripcion],
      data['titulo'],
      data['title'],
      data['name'],
    ].whereType<Object>().map((value) {
      return TextNormalizer.toAsciiSlug(value.toString());
    }).join('_');

    const knownCityIds = ['merida', 'badajoz', 'caceres'];
    for (final cityId in knownCityIds) {
      if (searchableText.contains(cityId)) return cityId;
    }

    return '';
  }

  static String _cityIdFromValue(dynamic rawValue) {
    if (rawValue == null) return '';

    if (rawValue is DocumentReference) {
      return TextNormalizer.toAsciiSlug(rawValue.id);
    }

    if (rawValue is Map) {
      const nestedKeys = [
        'id',
        'uid',
        'path',
        'nombre',
        'name',
        'title',
        'ref',
        'reference',
      ];
      for (final key in nestedKeys) {
        final normalized = _cityIdFromValue(rawValue[key]);
        if (normalized.isNotEmpty) return normalized;
      }
    }

    final value = rawValue.toString().trim();
    if (value.isEmpty) return '';

    final segments = value.split('/');
    final lastSegment = segments.last.trim();
    if (segments.length > 1 && lastSegment.isNotEmpty) {
      return TextNormalizer.toAsciiSlug(lastSegment);
    }

    return TextNormalizer.toAsciiSlug(value);
  }
}
