import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/constants/firestore_contract.dart';
import '../../domain/entities/poi_entity.dart';

class POIModel extends PointOfInterest {
  POIModel({
    required super.id,
    required super.name,
    required super.description,
    required super.location,
    required super.qrCode,
    required super.activationRadius,
  });

  factory POIModel.fromFirestore(Map<String, dynamic> json, String id) {
    final locationData = json[PointInterestFields.localizacion];

    double latitude = 0;
    double longitude = 0;

    try {
      if (locationData is GeoPoint) {
        latitude = locationData.latitude;
        longitude = locationData.longitude;
      } else if (locationData is Map) {
        latitude = (locationData['latitude'] ?? locationData['lat'] ?? 0)
            .toDouble();
        longitude = (locationData['longitude'] ?? locationData['lng'] ?? 0)
            .toDouble();
      }

      if (latitude == 0 && longitude == 0) {
        debugPrint(
          'Warning: point $id was loaded as (0,0). Check its Firebase location.',
        );
      }
    } catch (error) {
      debugPrint('Error parsing coordinates for point $id: $error');
    }

    return POIModel(
      id: id,
      name: json[PointInterestFields.nombre]?.toString() ?? 'Sin nombre',
      description:
          json[PointInterestFields.descripcion]?.toString() ??
          json['descripci\u00F3n']?.toString() ??
          'Sin descripcion',
      location: LatLng(latitude, longitude),
      qrCode: json[PointInterestFields.qrCode]?.toString() ?? '',
      activationRadius:
          (json[PointInterestFields.radioActivacion] as num?)?.toInt() ?? 50,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      PointInterestFields.nombre: name,
      PointInterestFields.descripcion: description,
      PointInterestFields.localizacion: GeoPoint(
        location.latitude,
        location.longitude,
      ),
      PointInterestFields.qrCode: qrCode,
      PointInterestFields.radioActivacion: activationRadius,
    };
  }
}
