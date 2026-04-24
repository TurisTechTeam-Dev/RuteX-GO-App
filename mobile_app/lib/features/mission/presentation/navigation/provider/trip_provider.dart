import 'dart:async';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../../core/map/routing_service.dart';
import '../../../domain/entities/poi_entity.dart';
import '../../../domain/usecases/mission_use_cases.dart';
import '../models/route_completion_summary.dart';
import '../../quiz/quiz_route_progress.dart';

class TripSimulationProvider extends ChangeNotifier {
  static const int _routeCompletionBonus = 10;

  final MissionUseCases missionUseCases;
  final String routeId;
  final RoutingService _routingService = RoutingService();
  final DateTime _startedAt = DateTime.now();
  LatLng? _lastRoutedPosition;
  int _routeCalculationVersion = 0;

  // --- State ---
  List<PointOfInterest> _pointsOfInterest = [];
  List<PointOfInterest> get pointsOfInterest => _pointsOfInterest;

  final List<int> _completedPoiIndices = [];
  List<int> get completedPoiIndices => _completedPoiIndices;

  List<LatLng> _routePoints = [];
  List<LatLng> get routePoints => _routePoints;

  LatLng _currentPosition = const LatLng(
    38.9161,
    -6.3437,
  ); // Default Merida position.
  LatLng get currentPosition => _currentPosition;

  int _currentPoiIndex = -1;
  int get currentPoiIndex => _currentPoiIndex;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _isSimulating = false;
  bool get isSimulating => _isSimulating;

  bool _isCalculatingRoute = false;
  bool get isCalculatingRoute => _isCalculatingRoute;

  bool _hasReachedDestination = false;
  bool get hasReachedDestination => _hasReachedDestination;

  bool _allPoisCompleted = false;
  bool get allPoisCompleted => _allPoisCompleted;

  StreamSubscription<Position>? _positionStream;

  TripSimulationProvider({
    required this.missionUseCases,
    required this.routeId,
  }) {
    debugPrint("[TRIP_PROVIDER] Initializing proximity-based navigation.");
    _initializeTrip();
  }

  Future<void> _initializeTrip() async {
    try {
      _isLoading = true;
      notifyListeners();

      debugPrint("[DB] Loading points for route: $routeId");
      _pointsOfInterest = await missionUseCases.executeGetPointsForRoute(
        routeId,
      );
      debugPrint("[DB] Loaded ${_pointsOfInterest.length} points.");

      await _initGpsTracking();

      // Start with the closest pending point to the current position.
      _selectNearestTargetPoi();
      await _calculateStreetRoute();
    } catch (e) {
      debugPrint("[TRIP_PROVIDER] Critical initialization error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Selects the closest unvisited point to the user.
  void _selectNearestTargetPoi() {
    if (_pointsOfInterest.isEmpty) return;

    final pendingPois = _pointsOfInterest
        .where(
          (poi) =>
              !_completedPoiIndices.contains(_pointsOfInterest.indexOf(poi)),
        )
        .toList();

    if (pendingPois.isEmpty) {
      debugPrint("[ROUTE] No pending points left. Route completed.");
      _allPoisCompleted = true;
      _currentPoiIndex = -1;
      return;
    }

    debugPrint(
      "[ROUTE] Calculating proximity across ${pendingPois.length} pending points.",
    );

    pendingPois.sort((a, b) {
      double distA = const Distance().as(
        LengthUnit.Meter,
        _currentPosition,
        a.location,
      );
      double distB = const Distance().as(
        LengthUnit.Meter,
        _currentPosition,
        b.location,
      );
      return distA.compareTo(distB);
    });

    _currentPoiIndex = _pointsOfInterest.indexOf(pendingPois.first);
    debugPrint(
      "[ROUTE] New dynamic target: ${_pointsOfInterest[_currentPoiIndex].name}",
    );
  }

  /// Calculates the street route to the current target with OSRM.
  Future<void> _calculateStreetRoute() async {
    if (_allPoisCompleted || _currentPoiIndex == -1) {
      _routePoints = [];
      notifyListeners();
      return;
    }

    final calculationVersion = ++_routeCalculationVersion;
    final targetIndex = _currentPoiIndex;

    _isCalculatingRoute = true;
    _routePoints = [];
    notifyListeners();

    final target = _pointsOfInterest[targetIndex].location;
    debugPrint(
      "[OSRM] Building route to: ${_pointsOfInterest[targetIndex].name}",
    );

    late final List<LatLng> nextRoutePoints;
    try {
      final points = await _routingService.getRoute(_currentPosition, target);
      nextRoutePoints = points.isNotEmpty ? points : [_currentPosition, target];
    } catch (e) {
      debugPrint("[OSRM] Connection error. Falling back to a straight line.");
      nextRoutePoints = [_currentPosition, target];
    }

    final isStaleCalculation =
        calculationVersion != _routeCalculationVersion ||
        targetIndex != _currentPoiIndex;
    if (isStaleCalculation) {
      if (calculationVersion == _routeCalculationVersion) {
        _isCalculatingRoute = false;
        notifyListeners();
      }
      return;
    }

    _routePoints = nextRoutePoints;
    _lastRoutedPosition = _currentPosition;
    _isCalculatingRoute = false;
    notifyListeners();
  }

  /// Marks the current point as visited and recalculates the closest target.
  bool markCurrentPoiAsCompleted() {
    if (_currentPoiIndex == -1) return _allPoisCompleted;

    debugPrint(
      "[PROGRESS] '${_pointsOfInterest[_currentPoiIndex].name}' marked as completed.",
    );

    if (!_completedPoiIndices.contains(_currentPoiIndex)) {
      _completedPoiIndices.add(_currentPoiIndex);
    }

    _hasReachedDestination = false;
    _isSimulating = false;

    _selectNearestTargetPoi();

    if (!_allPoisCompleted) {
      unawaited(_calculateStreetRoute());
    }
    notifyListeners();
    return _allPoisCompleted;
  }

  // --- GPS control ---

  Future<void> _initGpsTracking() async {
    debugPrint("[GPS] Configuring position stream.");
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    Position pos = await Geolocator.getCurrentPosition();
    _currentPosition = LatLng(pos.latitude, pos.longitude);

    _positionStream =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10,
          ),
        ).listen((Position pos) {
          if (!_isSimulating) {
            _currentPosition = LatLng(pos.latitude, pos.longitude);
            _checkArrivalProximity(_currentPosition);
            _refreshStreetRouteIfNeeded();
            notifyListeners();
          }
        });
  }

  void _refreshStreetRouteIfNeeded() {
    if (_allPoisCompleted || _currentPoiIndex == -1 || _hasReachedDestination) {
      return;
    }

    final lastPosition = _lastRoutedPosition;
    if (lastPosition == null) return;

    final movedDistance = const Distance().as(
      LengthUnit.Meter,
      lastPosition,
      _currentPosition,
    );

    if (movedDistance >= 25) {
      unawaited(_calculateStreetRoute());
    }
  }

  void _checkArrivalProximity(LatLng pos) {
    if (_hasReachedDestination || _allPoisCompleted || _currentPoiIndex == -1) {
      return;
    }

    final target = _pointsOfInterest[_currentPoiIndex];
    double distance = const Distance().as(
      LengthUnit.Meter,
      pos,
      target.location,
    );

    if (distance <= target.activationRadius) {
      debugPrint(
        "[ARRIVAL] Reached ${target.name}. Distance: ${distance.toInt()}m",
      );
      _hasReachedDestination = true;
      _isSimulating = false;
      notifyListeners();
    }
  }

  // --- Test simulation ---

  Future<void> startSimulation() async {
    if (_allPoisCompleted || _currentPoiIndex == -1) return;
    if (_isCalculatingRoute) return;

    if (_routePoints.isEmpty) {
      await _calculateStreetRoute();
      if (_routePoints.isEmpty || _allPoisCompleted || _currentPoiIndex == -1) {
        return;
      }
    }

    debugPrint(
      "[SIM] Starting automatic route to ${_pointsOfInterest[_currentPoiIndex].name}.",
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
    if (_isSimulating && !_hasReachedDestination) {
      final target = _pointsOfInterest[_currentPoiIndex];
      double finalDist = const Distance().as(
        LengthUnit.Meter,
        _currentPosition,
        target.location,
      );

      debugPrint(
        "[SIM] End of route points. Final distance: ${finalDist.toInt()}m",
      );

      if (finalDist < 200) {
        debugPrint("[SIM] Forcing arrival by final proximity.");
        _hasReachedDestination = true;
      }
    }

    _isSimulating = false;
    notifyListeners();
  }

  // --- UI helpers ---

  double get distanceToNextPoi {
    if (_currentPoiIndex == -1 || _allPoisCompleted) return 0.0;
    return const Distance().as(
      LengthUnit.Meter,
      _currentPosition,
      _pointsOfInterest[_currentPoiIndex].location,
    );
  }

  Future<RouteCompletionSummary> finishRoute() async {
    final completedAllMissions =
        QuizRouteProgress.visitedMonuments >= _pointsOfInterest.length;
    final currentAttemptPoints = completedAllMissions
        ? QuizRouteProgress.pointsWithCompletionBonus(_routeCompletionBonus)
        : QuizRouteProgress.routePoints;
    final visitedPois = _completedPoiIndices.length;
    final skippedPois = _skippedPois();
    final elapsedTime = DateTime.now().difference(_startedAt);
    final routeName = await missionUseCases.getRouteName(routeId);
    final answers = List<QuizAnswerResult>.from(
      QuizRouteProgress.answerResults,
    );
    final completedMissions = QuizRouteProgress.visitedMonuments;
    final saveResult = await missionUseCases.saveBestRouteProgress(
      routeId: routeId,
      currentAttemptPoints: currentAttemptPoints,
      visitedPois: visitedPois,
      completedMissions: completedMissions,
      skippedPois: skippedPois,
    );
    final correctAnswers = answers.where((answer) => answer.isCorrect).length;
    final totalAnswers = answers.length;

    QuizRouteProgress.reset();

    return RouteCompletionSummary(
      currentAttemptPoints: currentAttemptPoints,
      previousBestPoints: saveResult.previousBestPoints,
      savedBestPoints: saveResult.savedBestPoints,
      visitedPois: visitedPois,
      completedMissions: completedMissions,
      totalPois: _pointsOfInterest.length,
      totalPossiblePoints: (_pointsOfInterest.length * 30) + 10,
      correctAnswers: correctAnswers,
      totalAnswers: totalAnswers,
      routeName: routeName,
      elapsedTime: elapsedTime,
      answerResults: answers,
      skippedPoiNames: skippedPois.map((poi) => poi.name).toList(),
    );
  }

  List<PointOfInterest> _skippedPois() {
    return _completedPoiIndices
        .map((index) => _pointsOfInterest[index])
        .where((poi) => !QuizRouteProgress.visitedPointIds.contains(poi.id))
        .toList();
  }

  @override
  void dispose() {
    debugPrint("[TRIP_PROVIDER] Disposing GPS stream.");
    _positionStream?.cancel();
    super.dispose();
  }
}
