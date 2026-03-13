import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapView extends StatelessWidget {
  final List<LatLng> routePoints;
  final List<Marker> markers;
  final LatLng initialCenter;

  const MapView({
    super.key,
    required this.routePoints,
    required this.markers,
    this.initialCenter = const LatLng(38.915, -6.337), // Mérida por defecto
  });

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: initialCenter,
        initialZoom: 15.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.rutexgo.app',
        ),
        // Dibujamos la línea de la ruta
        PolylineLayer(
          polylines: [
            Polyline(
              points: routePoints,
              color: Colors.blueAccent,
              strokeWidth: 6.0,
            ),
          ],
        ),
        // Dibujamos los marcadores (Monumentos + Coche)
        MarkerLayer(markers: markers),
      ],
    );
  }
}