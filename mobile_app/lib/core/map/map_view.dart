import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapView extends StatelessWidget {
  final MapController? mapController;
  final List<LatLng> routePoints;
  final List<Marker> markers;
  final LatLng? currentLocation; // Cambiamos initialCenter por currentLocation

  const MapView({
    super.key,
    this.mapController,
    required this.routePoints,
    required this.markers,
    this.currentLocation, // Ahora recibimos la ubicación real
  });

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        // Si currentLocation es nulo (ej. GPS tardando), usamos Mérida de respaldo
        initialCenter: currentLocation ?? const LatLng(38.9161, -6.3437),
        initialZoom: 15.0,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all,
        ),
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
              color: Colors.blueAccent.withValues(alpha: 0.8),
              strokeWidth: 6.0,
              borderStrokeWidth: 2.0, // El grosor del borde
              borderColor: Colors.white, // El color del borde
            ),
          ],
        ),
        MarkerLayer(markers: markers),
      ],
    );
  }
}