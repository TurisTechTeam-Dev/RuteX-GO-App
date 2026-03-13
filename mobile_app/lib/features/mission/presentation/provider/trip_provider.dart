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

  List<PointOfInterest> _pointsOfInterest = [];
  List<PointOfInterest> get pointsOfInterest => _pointsOfInterest;

  List<LatLng> _routePoints = [];
  List<LatLng> get routePoints => _routePoints;

  LatLng? _currentPosition;
  LatLng? get currentPosition => _currentPosition;

  bool _isSimulating = false;
  bool get isSimulating => _isSimulating;

  // --- NUEVO: Gestión de Paradas ---
  PointOfInterest? _activePOI;
  PointOfInterest? get activePOI => _activePOI;

  bool _isNearPOI = false;
  bool get isNearPOI => _isNearPOI;

  int _currentIndex = 0; // Índice del monumento actual

  StreamSubscription<Position>? _positionStreamSubscription;

  TripSimulationProvider({required this.missionUseCases}) {
    _initData();
  }

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

  Future<void> updateToRealLocation() async {
    Position position = await Geolocator.getCurrentPosition();
    _currentPosition = LatLng(position.latitude, position.longitude);
    notifyListeners();
  }

  void startRealTimeTracking() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 2),
    ).listen((Position position) {
      if (!_isSimulating) {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _checkProximity(_currentPosition!);
        notifyListeners();
      }
    });
  }

  void movePositionManual(double dx, double dy) {
    if (_currentPosition == null) return;
    const double step = 0.00018;
    _currentPosition = LatLng(_currentPosition!.latitude - (dy * step), _currentPosition!.longitude + (dx * step));
    _checkProximity(_currentPosition!);
    notifyListeners();
  }

  Future<void> startSimulation() async {
    if (_pointsOfInterest.isEmpty || _currentIndex >= _pointsOfInterest.length) return;
    if (_currentPosition == null) await updateToRealLocation();

    _isSimulating = true;
    _isNearPOI = false; // Reset al empezar

    try {
      // Calculamos ruta hasta el siguiente punto pendiente
      List<LatLng> points = await _routingService.getRoute(
          _currentPosition!,
          _pointsOfInterest[_currentIndex].localizacion
      );

      if (points.isNotEmpty) {
        _routePoints = points;
        notifyListeners();

        for (int i = 0; i < _routePoints.length; i++) {
          if (!_isSimulating || _isNearPOI) break; // Si detecta proximidad, para el coche
          _currentPosition = _routePoints[i];
          _checkProximity(_currentPosition!);
          notifyListeners();
          await Future.delayed(const Duration(milliseconds: 50));
        }
      }
    } finally {
      _isSimulating = false;
      notifyListeners();
    }
  }

  void _checkProximity(LatLng pos) {
    if (_currentIndex >= _pointsOfInterest.length) return;

    final target = _pointsOfInterest[_currentIndex];
    final distance = const Distance().as(LengthUnit.Meter, pos, target.localizacion);

    // Si estamos a menos de su radio de activación
    if (distance <= target.radioActivacion && !_isNearPOI) {
      _isNearPOI = true;
      _activePOI = target;
      _isSimulating = false; // Paramos el coche para que el usuario elija
      notifyListeners();
    }
  }

  // Lógica para saltar al siguiente punto y arrancar automáticamente
  void nextMission() {
    _currentIndex++; // Pasamos al siguiente monumento
    _isNearPOI = false; // Cerramos el panel de información
    _activePOI = null;
    _routePoints = []; // Limpiamos la ruta vieja

    notifyListeners();

    // Si aún quedan monumentos en la lista, arrancamos la siguiente ruta solo
    if (_currentIndex < _pointsOfInterest.length) {
      debugPrint("Calculando automáticamente siguiente parada...");
      startSimulation();
    } else {
      debugPrint("¡Gymkhana finalizada!");
      _currentIndex = 0; // Opcional: resetear para poder empezar de nuevo
    }
  }

  void clearRoute() {
    _routePoints = [];
    _isSimulating = false;
    _isNearPOI = false;
    _currentIndex = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }
}