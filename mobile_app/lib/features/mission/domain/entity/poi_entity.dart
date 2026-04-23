import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart' as osm;
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;

class PointOfInterest {
  final String id;
  final String nombre;
  final String descripcion;
  final osm.LatLng localizacion;
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

  // Propiedad para obtener las coordenadas en formato LatLng de Google Maps
  gmaps.LatLng get googleLatLng => gmaps.LatLng(localizacion.latitude, localizacion.longitude);

  factory PointOfInterest.fromFirestore(Map<String, dynamic> data, String id) {
    // 1. Extraer el GeoPoint de Firebase (el campo se llama 'localizacion' en tu captura)
    final dynamic locData = data['localizacion'];

    double lat = 0.0;
    double lng = 0.0;

    // 2. Traducción correcta del GeoPoint a LatLng
    if (locData is GeoPoint) {
      lat = locData.latitude;
      lng = locData.longitude;
    }

    return PointOfInterest(
      id: id,
      nombre: data['nombre'] ?? 'Sin nombre',
      descripcion: data['descripción'] ?? data['descripcion'] ?? '',
      qrCode: data['qr_code'] ?? '',
      localizacion: osm.LatLng(lat, lng),
      radioActivacion: (data['radio_activacion'] ?? 40).toInt(),
    );
  }
}