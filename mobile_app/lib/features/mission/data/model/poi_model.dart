import 'package:cloud_firestore/cloud_firestore.dart';
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

  // En tus capturas, la localización es una lista: [latitud, longitud]
  factory POIModel.fromFirestore(Map<String, dynamic> json, String id) {
    // 1. Extraemos el GeoPoint directamente (así es como viene de Firebase)
    final GeoPoint loc = json['localizacion'];

    return POIModel(
      id: id,
      nombre: json['nombre'] ?? 'Monumento sin nombre',
      descripcion: json['descripcion'] ?? '',
      // 2. Usamos .latitude y .longitude del objeto GeoPoint
      localizacion: LatLng(
          loc.latitude,
          loc.longitude
      ),
      qrCode: json['qr_code'] ?? '',
      radioActivacion: (json['radio_activacion'] as num?)?.toInt() ?? 50,
    );
  }
}