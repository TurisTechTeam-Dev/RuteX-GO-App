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
import 'admin_model_helpers.dart';

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
    final cityId = adminCityIdFromData(data);
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
          adminFirstTextValue(data, const [
            PointInterestFields.descripcion,
            'descripci\u00F3n',
            'description',
          ]) ??
          '',
      imageUrl:
          adminFirstTextValue(data, const [
            PointInterestFields.imagen,
            'imagen_asset',
            'imagen_url',
            'image',
          ]) ??
          adminPointImagePath(name, qrCode, cityId),
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
    };

    // Añadimos id_ciudad solo si tiene un valor significativo (no cadena vacía).
    final trimmedCityId = cityId.trim();
    if (trimmedCityId.isNotEmpty) {
      data[PointInterestFields.idCiudad] = trimmedCityId;
    }

    if (latitude != null && longitude != null) {
      data[PointInterestFields.localizacion] = GeoPoint(latitude!, longitude!);
    }

    return data;
  }
}
