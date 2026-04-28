import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_contract.dart';
import '../../../../core/utils/text_normalizer.dart';

class AdminCityModel {
  final String? id;
  final String name;
  final String province;
  final String imageUrl;
  final bool isActive;

  const AdminCityModel({
    this.id,
    required this.name,
    required this.province,
    required this.imageUrl,
    required this.isActive,
  });

  factory AdminCityModel.fromFirestore(Map<String, dynamic> data, String id) {
    final name = (data[CityFields.nombre] ?? '').toString();
    return AdminCityModel(
      id: id,
      name: name,
      province: (data[CityFields.provincia] ?? '').toString(),
      imageUrl:
          _firstTextValue(data, const [
            CityFields.imagen,
            'imagen_asset',
            'imagen_url',
            'image',
          ]) ??
          _cityImagePath(name),
      isActive: data[CityFields.isActive] == true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      CityFields.nombre: name.trim(),
      CityFields.provincia: province.trim(),
      CityFields.imagen: imageUrl.trim(),
      CityFields.isActive: isActive,
    };
  }
}

class AdminPoiModel {
  final String? id;
  final String name;
  final String description;
  final String imageUrl;
  final String qrCode;
  final int activationRadius;
  final String cityId;
  final double? latitude;
  final double? longitude;

  const AdminPoiModel({
    this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.qrCode,
    required this.activationRadius,
    required this.cityId,
    this.latitude,
    this.longitude,
  });

  factory AdminPoiModel.fromFirestore(Map<String, dynamic> data, String id) {
    final dynamic rawLocation = data[PointInterestFields.localizacion];
    final name = (data[PointInterestFields.nombre] ?? '').toString();
    final qrCode = (data[PointInterestFields.qrCode] ?? '').toString();
    final cityId = _cityIdFromData(data);
    double? lat;
    double? lng;

    if (rawLocation is GeoPoint) {
      lat = rawLocation.latitude;
      lng = rawLocation.longitude;
    } else if (rawLocation is Map) {
      lat = double.tryParse(
        (rawLocation['latitude'] ?? rawLocation['lat'] ?? '').toString(),
      );
      lng = double.tryParse(
        (rawLocation['longitude'] ?? rawLocation['lng'] ?? '').toString(),
      );
    }

    return AdminPoiModel(
      id: id,
      name: name,
      description:
          _firstTextValue(data, const [
            PointInterestFields.descripcion,
            'descripci\u00F3n',
            'description',
          ]) ??
          '',
      imageUrl:
          _firstTextValue(data, const [
            PointInterestFields.imagen,
            'imagen_asset',
            'imagen_url',
            'image',
          ]) ??
          _pointImagePath(name, qrCode, cityId),
      qrCode: qrCode,
      activationRadius:
          (data[PointInterestFields.radioActivacion] as num?)?.toInt() ?? 20,
      cityId: cityId,
      latitude: lat,
      longitude: lng,
    );
  }

  Map<String, dynamic> toFirestore() {
    final data = <String, dynamic>{
      PointInterestFields.nombre: name.trim(),
      PointInterestFields.descripcion: description.trim(),
      PointInterestFields.imagen: imageUrl.trim(),
      PointInterestFields.qrCode: qrCode.trim(),
      PointInterestFields.radioActivacion: activationRadius,
      PointInterestFields.idCiudad: cityId,
    };

    if (latitude != null && longitude != null) {
      data[PointInterestFields.localizacion] = GeoPoint(latitude!, longitude!);
    }

    return data;
  }
}

class AdminMissionQuestion {
  final String text;
  final List<String> answers;
  final int correctIndex;

  const AdminMissionQuestion({
    required this.text,
    required this.answers,
    required this.correctIndex,
  });

  factory AdminMissionQuestion.fromMap(Map<String, dynamic> data) {
    String? preguntaKey;
    for (final key in data.keys) {
      if (key.startsWith('pregunta_')) {
        preguntaKey = key;
        break;
      }
    }

    final rawAnswers = data[MissionFields.respuestas];
    final answersData = rawAnswers is List
        ? rawAnswers.map((e) => e.toString()).toList()
        : <String>[];

    return AdminMissionQuestion(
      text: preguntaKey == null ? '' : (data[preguntaKey] ?? '').toString(),
      answers: answersData,
      correctIndex: (data[MissionFields.indiceCorrecto] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap(int index) {
    return {
      'pregunta_${index + 1}': text.trim(),
      MissionFields.respuestas: answers.map((e) => e.trim()).toList(),
      MissionFields.indiceCorrecto: correctIndex,
    };
  }
}

class AdminMissionModel {
  final String? id;
  final String pointId;
  final String title;
  final List<AdminMissionQuestion> questions;

  const AdminMissionModel({
    this.id,
    required this.pointId,
    required this.title,
    required this.questions,
  });

  factory AdminMissionModel.fromFirestore(
    Map<String, dynamic> data,
    String id,
  ) {
    final rawQuestions = data[MissionFields.preguntas];
    final questionsData = rawQuestions is List
        ? rawQuestions
              .whereType<Map>()
              .map(
                (e) =>
                    AdminMissionQuestion.fromMap(Map<String, dynamic>.from(e)),
              )
              .toList()
        : <AdminMissionQuestion>[];

    return AdminMissionModel(
      id: id,
      pointId: _idFromFirestoreValue(
        data[MissionFields.puntosInteresId] ??
            data[MissionFields.puntoInteresId] ??
            data['id_punto_interes'] ??
            data['pointId'] ??
            data['punto_interes'] ??
            data['punto_interes_ref'] ??
            data['pointId'] ??
            data['poiId'],
      ),
      title: (data[MissionFields.titulo] ?? '').toString(),
      questions: questionsData,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      MissionFields.puntosInteresId: pointId,
      MissionFields.titulo: title.trim(),
      MissionFields.preguntas: questions
          .asMap()
          .entries
          .map((entry) => entry.value.toMap(entry.key))
          .toList(),
    };
  }
}

class AdminRouteModel {
  final String? id;
  final String name;
  final String description;
  final String difficulty;
  final String duration;
  final String cityId;
  final List<String> pointIds;
  final String imageAsset;
  final bool isActive;
  final int totalPoints;

  const AdminRouteModel({
    this.id,
    required this.name,
    required this.description,
    required this.difficulty,
    required this.duration,
    required this.cityId,
    required this.pointIds,
    required this.imageAsset,
    required this.isActive,
    required this.totalPoints,
  });

  factory AdminRouteModel.fromFirestore(Map<String, dynamic> data, String id) {
    final pointsRaw = data[RouteFields.idPuntosInteres];
    final name = (data[RouteFields.nombre] ?? '').toString();
    return AdminRouteModel(
      id: id,
      name: name,
      description: (data[RouteFields.descripcion] ?? '').toString(),
      difficulty: (data[RouteFields.dificultad] ?? '').toString(),
      duration: (data[RouteFields.duracion] ?? '').toString(),
      cityId: _idFromFirestoreValue(
        data[RouteFields.idCiudad] ??
            data['idCiudad'] ??
            data['ciudad_id'] ??
            data['ciudadId'] ??
            data['id_ciudades'] ??
            data['ciudad'] ??
            data['cityId'] ??
            data['city_id'] ??
            data['city'],
      ),
      pointIds: pointsRaw is List
          ? pointsRaw.map(_idFromFirestoreValue).where(_isNotEmpty).toList()
          : <String>[],
      imageAsset:
          _firstTextValue(data, const [
            RouteFields.imagenAsset,
            RouteFields.imagen,
            'imagen_url',
            'image',
          ]) ??
          _routeImagePath(name),
      isActive:
          data[RouteFields.isActive] == true ||
          data[RouteFields.isActive] == 'true',
      totalPoints:
          int.tryParse(data[RouteFields.puntosTotales]?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      RouteFields.nombre: name.trim(),
      RouteFields.descripcion: description.trim(),
      RouteFields.dificultad: difficulty.trim(),
      RouteFields.duracion: duration.trim(),
      RouteFields.idCiudad: cityId,
      RouteFields.idPuntosInteres: pointIds,
      RouteFields.imagenAsset: imageAsset.trim(),
      RouteFields.isActive: isActive,
      RouteFields.puntosTotales: totalPoints,
    };
  }
}

String _idFromFirestoreValue(dynamic value) {
  if (value == null) return '';

  if (value is DocumentReference) {
    return value.id.trim();
  }

  if (value is Map) {
    const keys = ['id', 'uid', 'path', 'ref', 'reference'];
    for (final key in keys) {
      final nestedValue = _idFromFirestoreValue(value[key]);
      if (nestedValue.isNotEmpty) return nestedValue;
    }
  }

  final rawValue = value.toString().trim();
  if (rawValue.isEmpty) return '';

  final pathSegments = rawValue.split('/');
  final lastSegment = pathSegments.last.trim();
  return lastSegment.isEmpty ? rawValue : lastSegment;
}

String _normalizedIdFromFirestoreValue(dynamic value) {
  return TextNormalizer.toAsciiSlug(_idFromFirestoreValue(value));
}

bool _isNotEmpty(String value) {
  return value.isNotEmpty;
}

String? _firstTextValue(Map<String, dynamic> data, List<String> keys) {
  for (final key in keys) {
    final value = data[key]?.toString().trim();
    if (value != null && value.isNotEmpty) return value;
  }

  return null;
}

String _cityIdFromData(Map<String, dynamic> data) {
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
    final cityId = _normalizedIdFromFirestoreValue(data[key]);
    if (cityId.isNotEmpty) return cityId;
  }

  for (final entry in data.entries) {
    final key = TextNormalizer.toAsciiSlug(entry.key);
    if (!key.contains('ciudad') && !key.contains('city')) continue;

    final cityId = _normalizedIdFromFirestoreValue(entry.value);
    if (cityId.isNotEmpty) return cityId;
  }

  return _cityIdFromText([
    data[PointInterestFields.qrCode],
    data[PointInterestFields.nombre],
    data[PointInterestFields.descripcion],
  ]);
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

String _cityImagePath(String cityName) {
  final imageName = TextNormalizer.toAsciiSlug(cityName);
  return imageName.isEmpty ? '' : 'Contenido/Ciudades/$imageName.jpg';
}

String _routeImagePath(String routeName) {
  final imageName = TextNormalizer.toAsciiSlug(routeName);
  return imageName.isEmpty ? '' : 'Contenido/Rutas/$imageName.jpg';
}

String _pointImagePath(String pointName, String qrCode, String cityId) {
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
