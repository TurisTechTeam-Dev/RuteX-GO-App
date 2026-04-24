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
