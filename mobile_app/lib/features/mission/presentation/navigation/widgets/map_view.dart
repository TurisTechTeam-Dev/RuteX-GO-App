import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as google_maps;
import 'package:latlong2/latlong.dart';

import '../../../domain/entities/poi_entity.dart';

class MapView extends StatefulWidget {
  static const bool useGoogleMaps = bool.fromEnvironment(
    'USE_GOOGLE_MAPS',
    defaultValue: false,
  );

  final List<LatLng> routePoints;
  final List<PointOfInterest> pointsOfInterest;
  final LatLng? currentPosition;

  const MapView({
    super.key,
    required this.routePoints,
    required this.pointsOfInterest,
    this.currentPosition,
  });

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final MapController _flutterMapController = MapController();
  google_maps.GoogleMapController? _googleMapController;

  @override
  void didUpdateWidget(covariant MapView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.currentPosition == null ||
        widget.currentPosition == oldWidget.currentPosition) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final centerToUse = _centerToUse();
      if (MapView.useGoogleMaps && _googleMapController != null) {
        _googleMapController!.animateCamera(
          google_maps.CameraUpdate.newLatLng(_toGoogleLatLng(centerToUse)),
        );
      } else {
        _flutterMapController.move(
          centerToUse,
          _flutterMapController.camera.zoom,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final centerToUse = _centerToUse();

    if (MapView.useGoogleMaps) {
      return _buildGoogleMap(centerToUse);
    }

    return _buildTestMap(centerToUse);
  }

  Widget _buildGoogleMap(LatLng centerToUse) {
    return google_maps.GoogleMap(
      initialCameraPosition: google_maps.CameraPosition(
        target: _toGoogleLatLng(centerToUse),
        zoom: 16,
      ),
      mapType: google_maps.MapType.normal,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      compassEnabled: true,
      rotateGesturesEnabled: true,
      markers: _buildGoogleMarkers(centerToUse),
      polylines: _buildGooglePolylines(),
      onMapCreated: (controller) {
        _googleMapController = controller;
      },
    );
  }

  Widget _buildTestMap(LatLng centerToUse) {
    return FlutterMap(
      mapController: _flutterMapController,
      options: MapOptions(
        initialCenter: centerToUse,
        initialZoom: 16,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.rutexgo.mobile_app',
        ),
        if (widget.routePoints.isNotEmpty)
          PolylineLayer(
            polylines: [
              Polyline(
                points: widget.routePoints,
                color: Colors.blue.withValues(alpha: 0.8),
                strokeWidth: 5,
              ),
            ],
          ),
        MarkerLayer(markers: _buildFlutterMarkers(centerToUse)),
      ],
    );
  }

  List<Marker> _buildFlutterMarkers(LatLng centerToUse) {
    final markers = <Marker>[];

    for (final poi in widget.pointsOfInterest) {
      markers.add(
        Marker(
          point: poi.location,
          width: 50,
          height: 50,
          child: const Icon(
            Icons.location_on,
            color: Colors.red,
            size: 40,
            shadows: [Shadow(color: Colors.black26, blurRadius: 10)],
          ),
        ),
      );
    }

    markers.add(_buildCurrentPositionMarker(centerToUse));
    return markers;
  }

  Marker _buildCurrentPositionMarker(LatLng centerToUse) {
    return Marker(
      point: centerToUse,
      width: 60,
      height: 60,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 25,
            height: 25,
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
          ),
          const Icon(Icons.navigation, color: Colors.blue, size: 35),
        ],
      ),
    );
  }

  LatLng _centerToUse() {
    const meridaCenter = LatLng(38.9161, -6.3437);
    final currentPosition = widget.currentPosition;

    if (currentPosition == null || currentPosition.latitude == 0) {
      return meridaCenter;
    }

    return currentPosition;
  }

  Set<google_maps.Marker> _buildGoogleMarkers(LatLng centerToUse) {
    final markers = <google_maps.Marker>{};

    for (final poi in widget.pointsOfInterest) {
      markers.add(
        google_maps.Marker(
          markerId: google_maps.MarkerId('poi_${poi.id}'),
          position: _toGoogleLatLng(poi.location),
          icon: google_maps.BitmapDescriptor.defaultMarkerWithHue(
            google_maps.BitmapDescriptor.hueRed,
          ),
          infoWindow: google_maps.InfoWindow(title: poi.name),
        ),
      );
    }

    markers.add(
      google_maps.Marker(
        markerId: const google_maps.MarkerId('current_position'),
        position: _toGoogleLatLng(centerToUse),
        icon: google_maps.BitmapDescriptor.defaultMarkerWithHue(
          google_maps.BitmapDescriptor.hueAzure,
        ),
        infoWindow: const google_maps.InfoWindow(title: 'Tu posición'),
      ),
    );

    return markers;
  }

  Set<google_maps.Polyline> _buildGooglePolylines() {
    if (widget.routePoints.isEmpty) return {};

    return {
      google_maps.Polyline(
        polylineId: const google_maps.PolylineId('active_route'),
        points: _buildGoogleRoutePoints(),
        color: Colors.blue.withValues(alpha: 0.8),
        width: 5,
      ),
    };
  }

  List<google_maps.LatLng> _buildGoogleRoutePoints() {
    final routePoints = <google_maps.LatLng>[];

    for (final point in widget.routePoints) {
      routePoints.add(_toGoogleLatLng(point));
    }

    return routePoints;
  }

  google_maps.LatLng _toGoogleLatLng(LatLng point) {
    return google_maps.LatLng(point.latitude, point.longitude);
  }
}
