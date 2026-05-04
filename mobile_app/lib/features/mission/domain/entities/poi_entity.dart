/*
  -----------------------------------------------------------------------------
  Proyecto: RuteX Go
  Desarrollado por: TurisTechTeam
  Descripción: Esta aplicación y su código fuente son propiedad intelectual de
  TurisTechTeam. Queda prohibida su copia, distribución o uso no autorizado.
  Año: 2026
  -----------------------------------------------------------------------------
*/
import 'package:latlong2/latlong.dart';

class PointOfInterest {
  final String id;
  final String name;
  final String description;
  final String image;
  final LatLng location;
  final String qrCode;
  final int activationRadius;

  PointOfInterest({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.location,
    required this.qrCode,
    required this.activationRadius,
  });
}
