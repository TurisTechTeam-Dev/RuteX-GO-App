import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../../core/constants/firestore_contract.dart';
import '../../../../../core/map/routing_service.dart';
import '../../../domain/entity/poi_entity.dart';
import '../../../domain/usecases/mission_use_cases.dart';
import '../../quiz/quiz_route_progress.dart';

class RouteCompletionSummary {
  final int currentAttemptPoints;
  final int savedBestPoints;
  final int visitedPois;

  const RouteCompletionSummary({
    required this.currentAttemptPoints,
    required this.savedBestPoints,
    required this.visitedPois,
  });
}

class TripSimulationProvider extends ChangeNotifier {
  static const int _routeCompletionBonus = 10;

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

  LatLng _currentPosition = const LatLng(
    38.9161,
    -6.3437,
  ); // Mérida por defecto
  LatLng get currentPosition => _currentPosition;

  int _currentPoiIndex = -1;
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
    debugPrint(
      "🚀 [TRIP_PROVIDER] Inicializando Navegación Dinámica por Proximidad...",
    );
    _initializeTrip();
  }

  Future<void> _initializeTrip() async {
    try {
      _isLoading = true;
      notifyListeners();

      debugPrint("📡 [DB] Descargando puntos para la ruta: $routeId");
      _pointsOfInterest = await missionUseCases.executeGetPointsForRoute(
        routeId,
      );
      debugPrint(
        "✅ [DB] ${_pointsOfInterest.length} puntos cargados correctamente.",
      );

      await _initGpsTracking();

      // Al iniciar, buscamos el más cercano a nuestra posición actual
      _selectNearestTargetPoi();
      await _calculateStreetRoute();
    } catch (e) {
      debugPrint("❌ [TRIP_PROVIDER] Error crítico en inicialización: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// LÓGICA DINÁMICA: Selecciona el monumento no visitado más cercano al usuario.
  /// Esto resuelve el conflicto Teatro-Anfiteatro por exclusión.
  void _selectNearestTargetPoi() {
    if (_pointsOfInterest.isEmpty) return;

    // Filtramos solo los que NO han sido completados
    final pendingPois = _pointsOfInterest
        .where(
          (poi) =>
              !_completedPoiIndices.contains(_pointsOfInterest.indexOf(poi)),
        )
        .toList();

    if (pendingPois.isEmpty) {
      debugPrint("🏁 [LÓGICA] No quedan puntos pendientes. ¡Ruta finalizada!");
      _allPoisCompleted = true;
      _currentPoiIndex = -1;
      return;
    }

    debugPrint(
      "⚖️ [LÓGICA] Calculando proximidad entre ${pendingPois.length} monumentos restantes...",
    );

    // Ordenamos la lista de pendientes por distancia real al GPS actual
    pendingPois.sort((a, b) {
      double distA = const Distance().as(
        LengthUnit.Meter,
        _currentPosition,
        a.localizacion,
      );
      double distB = const Distance().as(
        LengthUnit.Meter,
        _currentPosition,
        b.localizacion,
      );
      return distA.compareTo(distB);
    });

    // El nuevo objetivo es el primero de la lista (el más cercano)
    _currentPoiIndex = _pointsOfInterest.indexOf(pendingPois.first);
    debugPrint(
      "🎯 [DESTINO] Nuevo objetivo dinámico: ${_pointsOfInterest[_currentPoiIndex].nombre}",
    );
  }

  /// Calcula la ruta por calles usando OSRM hacia el objetivo actual
  Future<void> _calculateStreetRoute() async {
    if (_allPoisCompleted || _currentPoiIndex == -1) {
      _routePoints = [];
      notifyListeners();
      return;
    }

    final target = _pointsOfInterest[_currentPoiIndex].localizacion;
    debugPrint(
      "🌐 [OSRM] Trazando camino hacia: ${_pointsOfInterest[_currentPoiIndex].nombre}",
    );

    try {
      final points = await _routingService.getRoute(_currentPosition, target);
      _routePoints = points.isNotEmpty ? points : [_currentPosition, target];
    } catch (e) {
      debugPrint("⚠️ [OSRM] Error de conexión. Usando línea recta temporal.");
      _routePoints = [_currentPosition, target];
    }
    notifyListeners();
  }

  /// Marca el punto actual como visitado y fuerza el recálculo al siguiente más cercano
  bool markCurrentPoiAsCompleted() {
    if (_currentPoiIndex == -1) return _allPoisCompleted;

    debugPrint(
      "✅ [PROGRESO] '${_pointsOfInterest[_currentPoiIndex].nombre}' marcado como completado.",
    );

    if (!_completedPoiIndices.contains(_currentPoiIndex)) {
      _completedPoiIndices.add(_currentPoiIndex);
    }

    _hasReachedDestination = false;

    // Recalcular cuál es el más cercano AHORA (excluyendo el que acabamos de terminar)
    _selectNearestTargetPoi();

    if (!_allPoisCompleted) {
      unawaited(_calculateStreetRoute());
    }
    notifyListeners();
    return _allPoisCompleted;
  }

  // --- CONTROL GPS ---

  Future<void> _initGpsTracking() async {
    debugPrint("🛰️ [GPS] Configurando sensor...");
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    // Posición inicial
    Position pos = await Geolocator.getCurrentPosition();
    _currentPosition = LatLng(pos.latitude, pos.longitude);

    // Escucha activa de movimiento
    _positionStream =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10, // Actualiza cada 3 metros para suavidad
          ),
        ).listen((Position pos) {
          if (!_isSimulating) {
            _currentPosition = LatLng(pos.latitude, pos.longitude);
            _checkArrivalProximity(_currentPosition);
            notifyListeners();
          }
        });
  }

  void _checkArrivalProximity(LatLng pos) {
    if (_hasReachedDestination || _allPoisCompleted || _currentPoiIndex == -1) {
      return;
    }

    final target = _pointsOfInterest[_currentPoiIndex];
    double distance = const Distance().as(
      LengthUnit.Meter,
      pos,
      target.localizacion,
    );

    // Comprobamos contra el radio de Firebase (recomendado 20m)
    if (distance <= target.radioActivacion) {
      debugPrint(
        "📍 [LLEGADA] ¡Has llegado a ${target.nombre}! Distancia: ${distance.toInt()}m",
      );
      _hasReachedDestination = true;
      _isSimulating = false;
      notifyListeners();
    }
  }

  // --- SIMULACIÓN PARA PRUEBAS ---

  Future<void> startSimulation() async {
    if (_allPoisCompleted || _currentPoiIndex == -1) return;

    debugPrint(
      "🎬 [SIM] Iniciando recorrido automático hacia ${_pointsOfInterest[_currentPoiIndex].nombre}...",
    );
    _isSimulating = true;
    _hasReachedDestination = false;

    for (var point in _routePoints) {
      if (!_isSimulating) break;
      _currentPosition = point;
      _checkArrivalProximity(_currentPosition);
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 90));
    }
    // Si terminó la simulación y NO saltó el popup por pocos metros, lo forzamos
    if (_isSimulating && !_hasReachedDestination) {
      final target = _pointsOfInterest[_currentPoiIndex];
      double finalDist = const Distance().as(
        LengthUnit.Meter,
        _currentPosition,
        target.localizacion,
      );

      debugPrint(
        "🏁 [SIM] Fin de puntos. Distancia final al monumento: ${finalDist.toInt()}m",
      );

      // Si al terminar estamos a menos de 100 metros, asumimos llegada para que el usuario no se quede bloqueado
      if (finalDist < 200) {
        debugPrint("🎯 [SIM] Forzando llegada por proximidad final.");
        _hasReachedDestination = true;
      }
    }

    _isSimulating = false;
    notifyListeners();
  }

  // --- HELPERS PARA UI ---

  double get distanceToNextPoi {
    if (_currentPoiIndex == -1 || _allPoisCompleted) return 0.0;
    return const Distance().as(
      LengthUnit.Meter,
      _currentPosition,
      _pointsOfInterest[_currentPoiIndex].localizacion,
    );
  }

  void skipToNext() => markCurrentPoiAsCompleted();

  Future<RouteCompletionSummary> finishRoute() async {
    final completedAllMissions =
        QuizRouteProgress.visitedMonuments >= _pointsOfInterest.length;
    final currentAttemptPoints = completedAllMissions
        ? QuizRouteProgress.pointsWithCompletionBonus(_routeCompletionBonus)
        : QuizRouteProgress.routePoints;
    final visitedPois = _completedPoiIndices.length;
    final savedBestPoints = await _saveBestRouteProgress(
      currentAttemptPoints: currentAttemptPoints,
      visitedPois: visitedPois,
    );

    QuizRouteProgress.reset();

    return RouteCompletionSummary(
      currentAttemptPoints: currentAttemptPoints,
      savedBestPoints: savedBestPoints,
      visitedPois: visitedPois,
    );
  }

  Future<int> _saveBestRouteProgress({
    required int currentAttemptPoints,
    required int visitedPois,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return currentAttemptPoints;

    final userRef = FirebaseFirestore.instance
        .collection(FirestoreCollections.usuarios)
        .doc(user.uid);

    return FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(userRef);
      final data = snapshot.data() ?? {};
      final completedRoutes = List<dynamic>.from(
        data[UserFields.rutasCompletadas] ?? [],
      );
      final normalizedRoutes = List<dynamic>.from(completedRoutes);

      var existingIndex = -1;
      var previousBestPoints = 0;

      for (var i = 0; i < normalizedRoutes.length; i++) {
        final route = normalizedRoutes[i];

        if (route is String && route == routeId) {
          existingIndex = i;
          break;
        }

        if (route is Map) {
          final savedRouteId =
              route[CompletedRouteFields.rutaId] ??
              route[CompletedRouteFields.idRuta] ??
              route[CompletedRouteFields.routeId];

          if (savedRouteId?.toString() == routeId) {
            existingIndex = i;
            previousBestPoints = _asInt(
              route[CompletedRouteFields.puntosObtenidos] ??
                  route[CompletedRouteFields.puntos],
            );
            break;
          }
        }
      }

      if (existingIndex != -1 && previousBestPoints >= currentAttemptPoints) {
        return previousBestPoints;
      }

      final routeProgress = {
        CompletedRouteFields.rutaId: routeId,
        CompletedRouteFields.puntosObtenidos: currentAttemptPoints,
        CompletedRouteFields.monumentosVisitados: visitedPois,
        CompletedRouteFields.misionesCompletadas:
            QuizRouteProgress.visitedMonuments,
      };

      if (existingIndex == -1) {
        normalizedRoutes.add(routeProgress);
      } else {
        normalizedRoutes[existingIndex] = routeProgress;
      }

      final updates = <String, dynamic>{
        UserFields.rutasCompletadas: normalizedRoutes,
      };

      final pointsDelta = currentAttemptPoints - previousBestPoints;
      if (pointsDelta > 0) {
        updates[UserFields.puntos] = FieldValue.increment(pointsDelta);
      }

      transaction.update(userRef, updates);
      return currentAttemptPoints;
    });
  }

  int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;

    return 0;
  }

  @override
  void dispose() {
    debugPrint("🗑️ [TRIP_PROVIDER] Limpiando recursos y cerrando GPS Stream.");
    _positionStream?.cancel();
    super.dispose();
  }
}
