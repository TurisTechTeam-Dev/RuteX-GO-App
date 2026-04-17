import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/constants/firestore_contract.dart';

class PointOfInterest {
  final String id;
  final String nombre;
  final String descripcion;
  final LatLng localizacion;
  final String qrCode;
  final int radioActivacion;

  PointOfInterest({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.localizacion,
    required this.qrCode,
    required this.radioActivacion,
  });

  factory PointOfInterest.fromFirestore(Map<String, dynamic> data, String id) {
    final locData = data[PointInterestFields.localizacion];

    double lat = 0;
    double lng = 0;

    if (locData is GeoPoint) {
      lat = locData.latitude;
      lng = locData.longitude;
    } else {
      debugPrint(
        "Alerta: el POI con ID $id no tiene un GeoPoint valido en Firebase.",
      );
    }

    return PointOfInterest(
      id: id,
      nombre: data[PointInterestFields.nombre]?.toString() ?? 'Sin nombre',
      descripcion:
          data[PointInterestFields.descripcion]?.toString() ??
          data['descripci\u00F3n']?.toString() ??
          '',
      qrCode: data[PointInterestFields.qrCode]?.toString() ?? '',
      localizacion: LatLng(lat, lng),
      radioActivacion:
          (data[PointInterestFields.radioActivacion] as num?)?.toInt() ?? 40,
    );
  }
}
