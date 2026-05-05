/*
  -----------------------------------------------------------------------------
  Proyecto: RuteX Go
  Desarrollado por: TurisTechTeam
  Descripción: Esta aplicación y su código fuente son propiedad intelectual de
  TurisTechTeam. Queda prohibida su copia, distribución o uso no autorizado.
  Año: 2026
  -----------------------------------------------------------------------------
*/import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_contract.dart';
import '../../../../core/utils/text_normalizer.dart';

String adminIdFromFirestoreValue(dynamic value) {
  if (value == null) return '';

  if (value is DocumentReference) {
    return value.id.trim();
  }

  if (value is Map) {
    const keys = ['id', 'uid', 'path', 'ref', 'reference'];
    for (final key in keys) {
      final nestedValue = adminIdFromFirestoreValue(value[key]);
      if (nestedValue.isNotEmpty) return nestedValue;
    }
  }

  final rawValue = value.toString().trim();
  if (rawValue.isEmpty) return '';

  final pathSegments = rawValue.split('/');
  final lastSegment = pathSegments.last.trim();
  return lastSegment.isEmpty ? rawValue : lastSegment;
}

String adminNormalizedIdFromFirestoreValue(dynamic value) {
  return TextNormalizer.toAsciiSlug(adminIdFromFirestoreValue(value));
}

bool adminIsNotEmpty(String value) {
  return value.isNotEmpty;
}

String? adminFirstTextValue(Map<String, dynamic> data, List<String> keys) {
  for (final key in keys) {
    final value = data[key]?.toString().trim();
    if (value != null && value.isNotEmpty) return value;
  }

  return null;
}

String adminCityIdFromData(Map<String, dynamic> data) {
  const cityKeys = [
    PointInterestFields.idCiudad,
    'idCiudad',
    'ciudad_id',
    'ciudadId',
    'id_ciudades',
    'ciudad',
    'ciudad_ref',
    'ciudadRef',
    'city',
    'cityId',
    'city_id',
  ];

  for (final key in cityKeys) {
    final cityId = adminNormalizedIdFromFirestoreValue(data[key]);
    if (cityId.isNotEmpty) return cityId;
  }

  for (final entry in data.entries) {
    final key = TextNormalizer.toAsciiSlug(entry.key);
    if (!key.contains('ciudad') && !key.contains('city')) continue;

    final cityId = adminNormalizedIdFromFirestoreValue(entry.value);
    if (cityId.isNotEmpty) return cityId;
  }

  return _cityIdFromText([
    data[PointInterestFields.qrCode],
    data[PointInterestFields.nombre],
    data[PointInterestFields.descripcion],
  ]);
}

String adminCityImagePath(String cityName) {
  final imageName = TextNormalizer.toAsciiSlug(cityName);
  return imageName.isEmpty ? '' : 'Contenido/Ciudades/$imageName.jpg';
}

String adminRouteImagePath(String routeName) {
  final imageName = TextNormalizer.toAsciiSlug(routeName);
  return imageName.isEmpty ? '' : 'Contenido/Rutas/$imageName.jpg';
}

String adminPointImagePath(String pointName, String qrCode, String cityId) {
  final qrImageName = TextNormalizer.toAsciiSlug(qrCode);
  if (qrImageName.isNotEmpty) {
    return 'Contenido/Puntos de Interes/$qrImageName.jpg';
  }

  final pointImageName = TextNormalizer.toAsciiSlug(pointName);
  if (pointImageName.isNotEmpty) {
    return 'Contenido/Puntos de Interes/$pointImageName.jpg';
  }

  final cityImageName = TextNormalizer.toAsciiSlug(cityId);
  return cityImageName.isEmpty
      ? ''
      : 'Contenido/Puntos de Interes/$cityImageName.jpg';
}

String _cityIdFromText(List<dynamic> values) {
  final text = values
      .where((value) => value != null)
      .map((value) => TextNormalizer.toAsciiSlug(value.toString()))
      .join('_');

  if (text.contains('badajoz') || text.startsWith('bad_')) return 'badajoz';
  if (text.contains('caceres') || text.startsWith('cac_')) return 'caceres';
  if (text.contains('merida') || text.startsWith('mer_')) return 'merida';
  return '';
}
