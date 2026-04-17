import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/constants/firestore_contract.dart';
import '../../domain/entity/poi_entity.dart';

class POIModel extends PointOfInterest {
  POIModel({
    required super.id,
    required super.nombre,
    required super.descripcion,
    required super.localizacion,
    required super.qrCode,
    required super.radioActivacion,
  });

  factory POIModel.fromFirestore(Map<String, dynamic> json, String id) {
    final locData = json[PointInterestFields.localizacion];

    double lat = 0;
    double lng = 0;

    try {
      if (locData is GeoPoint) {
        lat = locData.latitude;
        lng = locData.longitude;
      } else if (locData is Map) {
        lat = (locData['latitude'] ?? locData['lat'] ?? 0).toDouble();
        lng = (locData['longitude'] ?? locData['lng'] ?? 0).toDouble();
      }

      if (lat == 0 && lng == 0) {
        debugPrint(
          "Alerta: el punto con ID $id se cargo como (0,0). Revisa localizacion en Firebase.",
        );
      }
    } catch (e) {
      debugPrint("Error parseando coordenadas en ID $id: $e");
    }

    return POIModel(
      id: id,
      nombre: json[PointInterestFields.nombre]?.toString() ?? 'Sin nombre',
      descripcion:
          json[PointInterestFields.descripcion]?.toString() ??
          json['descripci\u00F3n']?.toString() ??
          'Sin descripcion',
      localizacion: LatLng(lat, lng),
      qrCode: json[PointInterestFields.qrCode]?.toString() ?? '',
      radioActivacion:
          (json[PointInterestFields.radioActivacion] as num?)?.toInt() ?? 50,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      PointInterestFields.nombre: nombre,
      PointInterestFields.descripcion: descripcion,
      PointInterestFields.localizacion: GeoPoint(
        localizacion.latitude,
        localizacion.longitude,
      ),
      PointInterestFields.qrCode: qrCode,
      PointInterestFields.radioActivacion: radioActivacion,
    };
  }
}
