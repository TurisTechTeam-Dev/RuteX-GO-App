import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlong2/latlong.dart' as osm;

import '../../features/mission/domain/entity/poi_entity.dart';

class MapView extends StatefulWidget {
  final GoogleMapController? mapController;
  final List<osm.LatLng> routePoints;
  final List<PointOfInterest> pointsOfInterest;
  final osm.LatLng? currentPosition;
  final Function(GoogleMapController)? onMapCreated;

  const MapView({
    super.key,
    this.mapController,
    required this.routePoints,
    required this.pointsOfInterest,
    this.currentPosition,
    this.onMapCreated,
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
      widget.mapController!.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(widget.currentPosition!.latitude, widget.currentPosition!.longitude),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Definimos el centro de Mérida como constante de seguridad
    const LatLng meridaCentro = LatLng(38.9161, -6.3437);

    // Convertimos los puntos de la ruta de OSRM a LatLng de Google Maps
    final List <LatLng> googleRoutePoints = widget.routePoints
        .map((point) => LatLng(point.latitude, point.longitude))
        .toList();

    // Convertimos la posición actual para el marcador
    final LatLng userPos = (widget.currentPosition == null || widget.currentPosition!.latitude == 0)
        ? meridaCentro
        : LatLng(widget.currentPosition!.latitude, widget.currentPosition!.longitude);

    return GoogleMap(
      onMapCreated: widget.onMapCreated,
      initialCameraPosition: CameraPosition(
        target: userPos,
        zoom: 15,
      ),
      myLocationEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      compassEnabled: false,

      // Capa de Lineas (Ruta)
      polylines: {
        Polyline(
          polylineId: const PolylineId("ruttexgo_route"),
          points: googleRoutePoints,
          color: Colors.blue.withAlpha(170),
          width: 6,
          jointType: JointType.round
        )
      },

      // Capa de Marcadores (POIs y posición actual)
      markers: {
        // Marcador de posicion actual (icono azul)
        Marker(
          markerId: const MarkerId("user_marker"),
          position: userPos,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: const InfoWindow(
            title: 'Tu posición',
          ),
        ),
        // Marcadores de POIs
        ...widget.pointsOfInterest.map(
          (poi) => Marker(
            markerId: MarkerId(poi.id),
            position: LatLng(poi.localizacion.latitude, poi.localizacion.longitude),
            infoWindow: InfoWindow(
                title: poi.nombre,
              snippet: "Pulsa para ver detalles"
            ),
          ),
        ),
      },
    );
  }
}
