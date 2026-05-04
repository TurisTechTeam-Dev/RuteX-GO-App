import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class PoiSelectionMap extends StatelessWidget {
  final MapController mapController;
  final LatLng center;
  final LatLng? selectedPosition;
  final Function(LatLng) onTap;

  const PoiSelectionMap({
    super.key,
    required this.mapController,
    required this.center,
    this.selectedPosition,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 320,
        child: FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter: selectedPosition ?? center,
            initialZoom: selectedPosition == null ? 13 : 16,
            onTap: (_, latLng) => onTap(latLng),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.rutexgo.mobile_app',
            ),
            if (selectedPosition != null)
              MarkerLayer(
                markers: [
                  Marker(
                    point: selectedPosition!,
                    width: 44,
                    height: 44,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
