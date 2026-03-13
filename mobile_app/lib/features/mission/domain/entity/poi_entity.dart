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
}