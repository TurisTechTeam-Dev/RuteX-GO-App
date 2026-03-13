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

  // Este es el traductor: convierte el mapa de Firebase en este objeto
  factory PointOfInterest.fromFirestore(Map<String, dynamic> data, String id) {
    return PointOfInterest(
      id: id,
      nombre: data['nombre'] ?? '',
      descripcion: data['descripcion'] ?? '',
      qrCode: data['codigoQR'] ?? '',
      localizacion: LatLng(
          (data['latitud'] ?? 0.0).toDouble(),
          (data['longitud'] ?? 0.0).toDouble()
      ),
      radioActivacion: (data['radio_activacion'] ?? 40).toInt(),
    );
  }
}