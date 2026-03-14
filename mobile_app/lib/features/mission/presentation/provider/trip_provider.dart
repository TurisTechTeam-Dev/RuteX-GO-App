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

  // --- ESTADO ---
  List<PointOfInterest> _pointsOfInterest = [];
  List<PointOfInterest> get pointsOfInterest => _pointsOfInterest;

  final List<int> _completedPoiIndices = [];
  List<int> get completedPoiIndices => _completedPoiIndices;

  List<LatLng> _routePoints = [];
  List<LatLng> get routePoints => _routePoints;

  LatLng _currentPosition = const LatLng(38.9161, -6.3437); // Mérida Centro
  LatLng get currentPosition => _currentPosition;

  int _currentPoiIndex = 0;
  int get currentPoiIndex => _currentPoiIndex;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _isSimulating = false;
  bool get isSimulating => _isSimulating;

  bool _hasReachedDestination = false;
  bool get hasReachedDestination => _hasReachedDestination;

  bool _allPoisCompleted = false;
  bool get allPoisCompleted => _allPoisCompleted;

  StreamSubscription<Position>? _positionStream;

  TripSimulationProvider({
    required this.missionUseCases,
    required this.routeId,
  }) {
    debugPrint("🚀 [Provider] Iniciando TripSimulationProvider para ruta: $routeId");
    _initData();
  }

  // --- LÓGICA DE DATOS ---
  Future<void> _initData() async {
    try {
      _isLoading = true;
      notifyListeners();

      debugPrint("🔍 [Provider] Cargando puntos desde Firebase...");
      _pointsOfInterest = await missionUseCases.executeGetOrderedPoints(routeId);

      if (_pointsOfInterest.isEmpty) {
        debugPrint("⚠️ [Provider] Firebase volvió vacío, cargando Fallback.");
        _loadFallbackPois();
      } else {
        debugPrint("✅ [Provider] Se cargaron ${_pointsOfInterest.length} puntos.");
      }

      await _startTracking();

      // Intentar calcular ruta inicial
      await _calculateNewRoute();

    } catch (e) {
      debugPrint("❌ [Provider] Error en _initData: $e");
      _loadFallbackPois();
      await _startTracking();
      await _calculateNewRoute();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _loadFallbackPois() {
    _pointsOfInterest = [
      PointOfInterest(
        id: "8XpMHfdHfsm5pHkNGPRd",
        nombre: "Teatro Romano",
        descripcion: "El gran teatro de Mérida, construido por Agripa.",
        localizacion: const LatLng(38.9140, -6.3385),
        qrCode: "MER_TEATRO_001",
        radioActivacion: 30,
      ),
      PointOfInterest(
        id: "1FUZ7RukpoUcG3uw5Rj9",
        nombre: "Anfiteatro Romano",
        descripcion: "Lugar de luchas de gladiadores y fieras.",
        localizacion: const LatLng(38.9150, -6.3375),
        qrCode: "MER_ANFI_001",
        radioActivacion: 30,
      ),
      PointOfInterest(
        id: "ip1G8FXbXrBUALezKXEk",
        nombre: "Circo Romano",
        descripcion: "Uno de los circos mejor conservados del Imperio.",
        localizacion: const LatLng(38.9195, -6.3325),
        qrCode: "MER_CIRCO_001",
        radioActivacion: 30,
      ),
    ];
  }

  // --- LÓGICA GPS ---
  Future<void> _startTracking() async {
    try {
      debugPrint("🛰️ [GPS] Verificando permisos...");
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint("🚫 [GPS] Permisos denegados.");
          return;
        }
      }

      Position? lastPos = await Geolocator.getLastKnownPosition();
      if (lastPos != null && lastPos.latitude != 0) {
        _currentPosition = LatLng(lastPos.latitude, lastPos.longitude);
        debugPrint("📍 [GPS] Última posición conocida: ${_currentPosition.latitude}, ${_currentPosition.longitude}");
      }

      _positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 2
        ),
      ).listen((Position pos) {
        if (!_isSimulating && pos.latitude != 0) {
          _currentPosition = LatLng(pos.latitude, pos.longitude);
          _checkProximity(_currentPosition);
          notifyListeners();
        }
      });
      debugPrint("✅ [GPS] Seguimiento activado.");
    } catch (e) {
      debugPrint("❌ [GPS] Error: $e");
    }
  }

  // --- CÁLCULO DE RUTA (OSRM) ---
  Future<void> _calculateNewRoute() async {
    if (_pointsOfInterest.isEmpty || _allPoisCompleted) {
      debugPrint("🛑 [OSRM] No hay puntos o ruta finalizada. Abortando.");
      return;
    }

    final destino = _pointsOfInterest[_currentPoiIndex].localizacion;
    debugPrint("🌐 [OSRM] Solicitando ruta: De (${_currentPosition.latitude}, ${_currentPosition.longitude}) -> A (${destino.latitude}, ${destino.longitude})");

    if (destino.latitude == 0 || _currentPosition.latitude == 0) {
      debugPrint("❌ [OSRM] Error: Coordenadas de origen o destino son 0.0");
      return;
    }

    final points = await _routingService.getRoute(_currentPosition, destino);

    if (points.isNotEmpty) {
      _routePoints = points;
      debugPrint("✅ [OSRM] Ruta obtenida con ${_routePoints.length} puntos.");
    } else {
      debugPrint("⚠️ [OSRM] Falló OSRM, usando línea recta de emergencia.");
      _routePoints = [_currentPosition, destino];
    }

    notifyListeners();
  }

  // --- NAVEGACIÓN ---
  double get distanceToNextPoi {
    if (_pointsOfInterest.isEmpty || _currentPoiIndex >= _pointsOfInterest.length) return 0.0;
    final target = _pointsOfInterest[_currentPoiIndex].localizacion;
    return const Distance().as(LengthUnit.Meter, _currentPosition, target);
  }

  void _checkProximity(LatLng pos) {
    if (_hasReachedDestination || _pointsOfInterest.isEmpty || _allPoisCompleted) return;

    double dist = distanceToNextPoi;
    if (dist <= _pointsOfInterest[_currentPoiIndex].radioActivacion) {
      debugPrint("🎯 [Llegada] Cerca de: ${_pointsOfInterest[_currentPoiIndex].nombre} (Dist: ${dist.toStringAsFixed(1)}m)");
      _hasReachedDestination = true;
      _isSimulating = false;
      notifyListeners();
    }
  }

  void markCurrentPoiAsCompleted() async {
    debugPrint("✔️ [Provider] Completando punto: $_currentPoiIndex");
    if (!_completedPoiIndices.contains(_currentPoiIndex)) {
      _completedPoiIndices.add(_currentPoiIndex);
    }

    if (_currentPoiIndex < _pointsOfInterest.length - 1) {
      _currentPoiIndex++;
      _hasReachedDestination = false;
      debugPrint("➡️ [Provider] Siguiente destino: ${_pointsOfInterest[_currentPoiIndex].nombre}");
      await _calculateNewRoute();
    } else {
      debugPrint("🏁 [Provider] ¡Ruta terminada!");
      _allPoisCompleted = true;
      _hasReachedDestination = true;
    }
    notifyListeners();
  }

  void skipToNext() {
    markCurrentPoiAsCompleted();
  }

  // --- SIMULACIÓN ---
  Future<void> startSimulation() async {
    if (_pointsOfInterest.isEmpty || _allPoisCompleted) return;

    debugPrint("🎬 [Simulación] Iniciando...");
    _isSimulating = true;
    _hasReachedDestination = false;

    await _calculateNewRoute();

    if (_routePoints.isEmpty) {
      debugPrint("❌ [Simulación] No hay puntos de ruta para simular.");
      _isSimulating = false;
      return;
    }

    for (int i = 0; i < _routePoints.length; i++) {
      if (!_isSimulating) {
        debugPrint("⏹️ [Simulación] Detenida por el usuario.");
        break;
      }

      _currentPosition = _routePoints[i];
      _checkProximity(_currentPosition);
      notifyListeners();

      // Log cada 10 puntos para no saturar la consola
      if (i % 10 == 0) debugPrint("🚗 [Simulación] En camino... punto $i de ${_routePoints.length}");

      await Future.delayed(const Duration(milliseconds: 50));
    }

    _isSimulating = false;
    notifyListeners();
    debugPrint("🏁 [Simulación] Finalizada.");
  }

  @override
  void dispose() {
    debugPrint("🗑️ [Provider] Disposing TripSimulationProvider.");
    _positionStream?.cancel();
    super.dispose();
  }
}