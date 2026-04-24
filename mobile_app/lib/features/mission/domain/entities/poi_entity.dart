import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/constants/firestore_contract.dart';

class PointOfInterest {
  final String id;
  final String name;
  final String description;
  final LatLng location;
  final String qrCode;
  final int activationRadius;

  PointOfInterest({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.qrCode,
    required this.activationRadius,
  });

  factory PointOfInterest.fromFirestore(Map<String, dynamic> data, String id) {
    final locationData = data[PointInterestFields.localizacion];

    double latitude = 0;
    double longitude = 0;

    if (locationData is GeoPoint) {
      latitude = locationData.latitude;
      longitude = locationData.longitude;
    } else {
      debugPrint('Warning: point $id does not have a valid Firebase GeoPoint.');
    }

    return PointOfInterest(
      id: id,
      name: data[PointInterestFields.nombre]?.toString() ?? 'Sin nombre',
      description:
          data[PointInterestFields.descripcion]?.toString() ??
          data['descripci\u00F3n']?.toString() ??
          '',
      qrCode: data[PointInterestFields.qrCode]?.toString() ?? '',
      location: LatLng(latitude, longitude),
      activationRadius:
          (data[PointInterestFields.radioActivacion] as num?)?.toInt() ?? 40,
    );
  }
}
