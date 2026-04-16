import 'package:cloud_firestore/cloud_firestore.dart'; // 👈 IMPORTANTE: Necesitas esto para el GeoPoint
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

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
    // 1. Extraer el GeoPoint de Firebase (el campo se llama 'localizacion' en tu captura)
    final dynamic locData = data['localizacion'];

    double lat = 0.0;
    double lng = 0.0;

    // 2. Traducción correcta del GeoPoint a LatLng
    if (locData is GeoPoint) {
      lat = locData.latitude;
      lng = locData.longitude;
    } else {
      // Log de aviso por si algún punto en Firebase está mal creado
      debugPrint("⚠️ Alerta: El POI con ID $id no tiene un GeoPoint válido en Firebase.");
    }

    return PointOfInterest(
      id: id,
      // Usamos los nombres exactos que vimos en tu captura de imagen
      nombre: data['nombre'] ?? 'Sin nombre',
      descripcion: data['descripción'] ?? data['descripcion'] ?? '', // Con y sin tilde por seguridad
      qrCode: data['qr_code'] ?? '', // En Firebase es qr_code, no codigoQR
      localizacion: LatLng(lat, lng),
      radioActivacion: (data['radio_activacion'] ?? 40).toInt(),
    );
  }
}
