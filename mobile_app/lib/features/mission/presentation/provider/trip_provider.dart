import 'dart:async';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/map/routing_service.dart';
import '../../domain/entity/poi_entity.dart';
import '../../domain/usecases/mission_use_cases.dart';

class TripSimulationProvider extends ChangeNotifier {
  final MissionUseCases missionUseCases;
  final RoutingService _routingService = RoutingService();

  // --- ESTADO ---
  List<PointOfInterest> _pointsOfInterest = [];
  List<PointOfInterest> get pointsOfInterest => _pointsOfInterest;

  List<LatLng> _routePoints = [];
  List<LatLng> get routePoints => _routePoints;

  LatLng? _currentPosition;
  LatLng? get currentPosition => _currentPosition;

  bool _isSimulating = false;
  bool get isSimulating => _isSimulating;

  StreamSubscription<Position>? _positionStream;

  TripSimulationProvider({required this.missionUseCases}) {
    _initData();
  }

  // 1. Carga inicial: Firebase + Ubicación Real inicial
  Future<void> _initData() async {
    try {
      // Cargar monumentos de Firebase
      _pointsOfInterest = await missionUseCases.execute();

      // Intentar obtener ubicación real al arrancar
      await updateToRealLocation();

      notifyListeners();
    } catch (e) {
      debugPrint("Error inicializando datos: $e");
    }
  }

  // 2. OBTENER UBICACIÓN REAL (GPS)
  Future<void> updateToRealLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    Position position = await Geolocator.getCurrentPosition();
    _currentPosition = LatLng(position.latitude, position.longitude);
    notifyListeners();
  }

  // 3. SEGUIMIENTO EN TIEMPO REAL (Opcional para la caminata)
  void startLocationTracking() {
    _positionStream?.cancel();
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 2),
    ).listen((Position position) {
      if (!_isSimulating) { // No sobreescribir si estamos simulando
        _currentPosition = LatLng(position.latitude, position.longitude);
        _checkProximity(_currentPosition!);
        notifyListeners();
      }
    });
  }

  // 4. LÓGICA DE RUTA Y SIMULACIÓN (OSRM)
  Future<void> calculateRoute(LatLng start, LatLng end) async {
    _routePoints = await _routingService.getRoute(start, end);
    notifyListeners();
  }

  Future<void> startSimulation() async {
    if (_pointsOfInterest.length < 2) return;

    _isSimulating = true;

    // Si no hay ruta calculada, calculamos una entre los dos primeros puntos de Mérida
    if (_routePoints.isEmpty) {
      await calculateRoute(
          _pointsOfInterest[0].localizacion,
          _pointsOfInterest[1].localizacion
      );
    }

    for (int i = 0; i < _routePoints.length; i++) {
      if (!_isSimulating) break;

      _currentPosition = _routePoints[i];
      _checkProximity(_currentPosition!);

      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 100)); // Velocidad simulación
    }

    _isSimulating = false;
    notifyListeners();
  }

  void stopSimulation() {
    _isSimulating = false;
    notifyListeners();
  }

  // 5. DETECCIÓN DE PROXIMIDAD
  void _checkProximity(LatLng pos) {
    for (var poi in _pointsOfInterest) {
      final distance = const Distance().as(LengthUnit.Meter, pos, poi.localizacion);

      if (distance <= poi.radioActivacion) {
        // Aquí podrías lanzar un diálogo en la UI
        debugPrint("Cerca de: ${poi.nombre}");
      }
    }
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }
}