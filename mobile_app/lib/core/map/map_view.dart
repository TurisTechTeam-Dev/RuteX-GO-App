import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../features/mission/domain/entity/poi_entity.dart';

class MapView extends StatelessWidget {
  final MapController? mapController;
  final List<LatLng> routePoints;
  final List<PointOfInterest> pointsOfInterest;
  final LatLng? currentPosition;

  const MapView({
    super.key,
    this.mapController,
    required this.routePoints,
    required this.pointsOfInterest,
    this.currentPosition,
  });

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: currentPosition ?? const LatLng(38.9161, -6.3437),
        initialZoom: 15.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.rutexgo.app',
        ),
        PolylineLayer(
          polylines: [
            Polyline(
              points: routePoints,
              color: Colors.blueAccent.withOpacity(0.8),
              strokeWidth: 6.0,
            ),
          ],
        ),
        MarkerLayer(
          markers: [
            ...pointsOfInterest.map((poi) => Marker(
              point: poi.localizacion,
              width: 40,
              height: 40,
              child: const Icon(Icons.location_on, color: Colors.red, size: 40),
            )),
            if (currentPosition != null)
              Marker(
                point: currentPosition!,
                width: 40,
                height: 40,
                child: const Icon(Icons.navigation, color: Colors.blue, size: 40),
              ),
          ],
        ),
      ],
    );
  }
}