import 'dart:async';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/map/routing_service.dart';
import '../../domain/entity/poi_entity.dart';
import '../../domain/usescases/mission_uses_cases.dart';

class TripSimulationProvider extends ChangeNotifier {
  final MissionUseCases missionUseCases;
  final RoutingService _routingService = RoutingService();

  // --- Estado de la Misión ---
  List<PointOfInterest> _pointsOfInterest = [];
  List<PointOfInterest> get pointsOfInterest => _pointsOfInterest;

  // --- Estado del Mapa y Navegación ---
  List<LatLng> _routePoints = [];
  List<LatLng> get routePoints => _routePoints;

  LatLng? _currentPosition; // La flecha azul
  LatLng? get currentPosition => _currentPosition;

  bool _isSimulating = false;
  bool get isSimulating => _isSimulating;

  // Suscripción al GPS real
  StreamSubscription<Position>? _positionStreamSubscription;

  TripSimulationProvider({required this.missionUseCases}) {
    _initData();
  }

  /// 1. CARGA INICIAL
  Future<void> _initData() async {
    try {
      _pointsOfInterest = await missionUseCases.execute();
      await updateToRealLocation();
      startRealTimeTracking();
      notifyListeners();
    } catch (e) {
      debugPrint("Error en carga inicial: $e");
    }
  }

  /// 2. GPS REAL (UBICACIÓN ACTUAL)
  Future<void> updateToRealLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    Position position = await Geolocator.getCurrentPosition();
    _currentPosition = LatLng(position.latitude, position.longitude);
    notifyListeners();
  }

  void startRealTimeTracking() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 2,
      ),
    ).listen((Position position) {
      if (!_isSimulating) {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _checkProximity(_currentPosition!);
        notifyListeners();
      }
    });
  }

  /// 3. MOVIMIENTO MANUAL (JOYSTICK)
  void movePositionManual(double dx, double dy) {
    if (_currentPosition == null) return;

    // Sensibilidad: Ajusta este valor si vas muy rápido o lento
    const double step = 0.00018;

    _currentPosition = LatLng(
      _currentPosition!.latitude - (dy * step),
      _currentPosition!.longitude + (dx * step),
    );

    _checkProximity(_currentPosition!);
    notifyListeners();
  }

  /// 4. SIMULACIÓN AUTOMÁTICA (OSRM)
  Future<void> startSimulation() async {
    if (_pointsOfInterest.isEmpty) return;
    if (_currentPosition == null) await updateToRealLocation();

    _isSimulating = true;

    try {
      List<LatLng> points = await _routingService.getRoute(
          _currentPosition!,
          _pointsOfInterest[0].localizacion
      );

      if (points.isNotEmpty) {
        _routePoints = points;
        notifyListeners();

        for (int i = 0; i < _routePoints.length; i++) {
          if (!_isSimulating) break;
          _currentPosition = _routePoints[i];
          _checkProximity(_currentPosition!);
          notifyListeners();
          await Future.delayed(const Duration(milliseconds: 50));
        }
      }
    } catch (e) {
      debugPrint("Error en simulación: $e");
    } finally {
      _isSimulating = false;
      notifyListeners();
    }
  }

  /// 5. LÓGICA DE PROXIMIDAD
  void _checkProximity(LatLng pos) {
    for (var poi in _pointsOfInterest) {
      final distance = const Distance().as(LengthUnit.Meter, pos, poi.localizacion);
      if (distance <= poi.radioActivacion) {
        debugPrint("📍 ¡Cerca de: ${poi.nombre}!");
      }
    }
  }

  /// 6. LIMPIEZA
  void clearRoute() {
    _routePoints = [];
    _isSimulating = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }
}