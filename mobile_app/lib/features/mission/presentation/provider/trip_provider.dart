import 'dart:async';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/map/routing_service.dart';
import '../../domain/entity/poi_entity.dart';
import '../../domain/usescases/mission_uses_cases.dart';

class TripSimulationProvider extends ChangeNotifier {
  final MissionUseCases missionUseCases;
  final String routeId;
  final RoutingService _routingService = RoutingService();

  List<PointOfInterest> _pointsOfInterest = [];
  List<PointOfInterest> get pointsOfInterest => _pointsOfInterest;

  List<LatLng> _routePoints = [];
  List<LatLng> get routePoints => _routePoints;

  LatLng? _currentPosition;
  LatLng? get currentPosition => _currentPosition;

  int _currentPoiIndex = 0;
  int get currentPoiIndex => _currentPoiIndex;

  bool _isSimulating = false;
  bool get isSimulating => _isSimulating;

  bool _hasReachedDestination = false;
  bool get hasReachedDestination => _hasReachedDestination;

  StreamSubscription<Position>? _positionStream;

  // El constructor ahora obliga a pasar el routeId
  TripSimulationProvider({
    required this.missionUseCases,
    required this.routeId,
  }) {
    _initData();
  }

  Future<void> _initData() async {
    try {
      // Pasamos el routeId que viene de Firebase
      _pointsOfInterest = await missionUseCases.executeGetOrderedPoints(routeId);
      await _startTracking();
      notifyListeners();
    } catch (e) {
      debugPrint("Error cargando puntos: $e");
    }
  }

  Future<void> _startTracking() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 2),
    ).listen((Position position) {
      _currentPosition = LatLng(position.latitude, position.longitude);
      if (!_isSimulating) _checkProximity(_currentPosition!);
      notifyListeners();
    });
  }

  double get distanceToNextPoi {
    if (_currentPosition == null || _pointsOfInterest.isEmpty) return 0.0;
    if (_currentPoiIndex >= _pointsOfInterest.length) return 0.0;

    final target = _pointsOfInterest[_currentPoiIndex].localizacion;
    return const Distance().as(LengthUnit.Meter, _currentPosition!, target);
  }

  void skipToNext() {
    if (_currentPoiIndex < _pointsOfInterest.length - 1) {
      _currentPoiIndex++;
      _hasReachedDestination = false;
      if (_currentPosition != null) {
        _calculateNewRoute();
      }
      notifyListeners();
    }
  }

  Future<void> _calculateNewRoute() async {
    _routePoints = await _routingService.getRoute(
        _currentPosition!,
        _pointsOfInterest[_currentPoiIndex].localizacion
    );
    notifyListeners();
  }

  void _checkProximity(LatLng pos) {
    if (_hasReachedDestination || _pointsOfInterest.isEmpty) return;

    final currentPoi = _pointsOfInterest[_currentPoiIndex];
    if (distanceToNextPoi <= currentPoi.radioActivacion) {
      _hasReachedDestination = true;
      _isSimulating = false;
      notifyListeners();
    }
  }

  Future<void> startSimulation() async {
    if (_pointsOfInterest.isEmpty || _currentPosition == null) return;
    _isSimulating = true;
    _hasReachedDestination = false;
    await _calculateNewRoute();

    for (var point in _routePoints) {
      if (!_isSimulating) break;
      _currentPosition = point;
      _checkProximity(_currentPosition!);
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 50));
    }
    _isSimulating = false;
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }
}