import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart'; // Import que te funciona

import '../../features/mission/domain/entity/poi_entity.dart';

class MapView extends StatefulWidget {
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
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  @override
  void didUpdateWidget(covariant MapView oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Si cambia la posición del usuario, movemos la cámara para que siga al icono azul
    if (widget.mapController != null &&
        widget.currentPosition != null &&
        widget.currentPosition != oldWidget.currentPosition) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        widget.mapController!.move(
          widget.currentPosition!,
          widget.mapController!.camera.zoom,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Definimos el centro de Mérida como constante de seguridad
    const LatLng meridaCentro = LatLng(38.9161, -6.3437);

    // Lógica de validación: si la posición es nula o es (0,0), usamos Mérida
    final LatLng centerToUse =
    (widget.currentPosition == null || widget.currentPosition!.latitude == 0)
        ? meridaCentro
        : widget.currentPosition!;

    return FlutterMap(
      mapController: widget.mapController,
      options: MapOptions(
        initialCenter: centerToUse,
        initialZoom: 16.0,
        // Permitir rotación para que sea más inmersivo
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all,
        ),
      ),
      children: [
        // Capa de mapa (OpenStreetMap)
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.rutexgo.mobile_app',
        ),

        // Capa de la ruta calculada por OSRM
        if (widget.routePoints.isNotEmpty)
          PolylineLayer(
            polylines: [
              Polyline(
                points: widget.routePoints,
                color: Colors.blue.withValues(alpha: 0.8),
                strokeWidth: 5.0,
              ),
            ],
          ),

        // Capa de Marcadores
        MarkerLayer(
          markers: [
            // 1. Puntos de Interés (Monumentos)
            ...widget.pointsOfInterest.map(
                  (poi) => Marker(
                point: poi.localizacion,
                width: 50,
                height: 50,
                child: const Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 40,
                  shadows: [Shadow(color: Colors.black26, blurRadius: 10)],
                ),
              ),
            ),

            // 2. Marcador del Usuario / Simulación
            Marker(
              point: centerToUse,
              width: 60,
              height: 60,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Aura de pulsación
                  Container(
                    width: 25,
                    height: 25,
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                  ),
                  // Icono de navegación
                  const Icon(Icons.navigation, color: Colors.blue, size: 35),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
