import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
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
    final dynamic locData = json['localizacion'];

    double lat = 0.0;
    double lng = 0.0;

    try {
      if (locData != null) {
        if (locData is GeoPoint) {
          lat = locData.latitude;
          lng = locData.longitude;
        } else if (locData is Map) {
          // A veces Firebase devuelve mapas en lugar de GeoPoints en modo offline
          lat = (locData['latitude'] ?? locData['lat'] ?? 0.0).toDouble();
          lng = (locData['longitude'] ?? locData['lng'] ?? 0.0).toDouble();
        }
      }

      // Si después de intentar mapear sigue siendo 0.0, lanzamos un aviso al log
      if (lat == 0.0 && lng == 0.0) {
        debugPrint("⚠️ [MODELO] El punto con ID $id se cargó como (0,0). Revisa el campo 'localizacion' en Firebase.");
      }
    } catch (e) {
      debugPrint("❌ [MODELO] Error parseando coordenadas en ID $id: $e");
    }

    return POIModel(
      id: id,
      nombre: json['nombre'] ?? 'Sin nombre',
      descripcion: json['descripción'] ?? json['descripcion'] ?? 'Sin descripción',
      localizacion: LatLng(lat, lng),
      qrCode: json['qr_code'] ?? '',
      radioActivacion: (json['radio_activacion'] as num?)?.toInt() ?? 50,
    );
  }

  // Método opcional para convertir el objeto de vuelta a un formato que Firebase entienda
  Map<String, dynamic> toFirestore() {
    return {
      'nombre': nombre,
      'descripción': descripcion,
      'localizacion': GeoPoint(localizacion.latitude, localizacion.longitude),
      'qr_code': qrCode,
      'radio_activacion': radioActivacion,
    };
  }
}
