/*
  -----------------------------------------------------------------------------
  Proyecto: RuteX Go
  Desarrollado por: TurisTechTeam
  Descripción: Esta aplicación y su código fuente son propiedad intelectual de
  TurisTechTeam. Queda prohibida su copia, distribución o uso no autorizado.
  Año: 2026
  -----------------------------------------------------------------------------
*/
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../../core/map/routing_service.dart';
import '../../../domain/entities/poi_entity.dart';
import '../../../domain/entities/route_result_record.dart';
import '../../../domain/usecases/mission_use_cases.dart';
import '../models/route_completion_summary.dart';
import '../utils/navigation_distance_utils.dart';
import '../utils/route_duration_formatter.dart';
import '../utils/route_target_selector.dart';
import '../../quiz/quiz_route_progress.dart';

class TripSimulationProvider extends ChangeNotifier {
  static const int _routeCompletionBonus = 10;
  static const Duration _simulationStepDelay = Duration(milliseconds: 260);

  final MissionUseCases missionUseCases;
  final String routeId;
  final bool useGoogleDirections;
  final RoutingService _routingService = RoutingService();
  final DateTime _startedAt = DateTime.now();
  LatLng? _lastRoutedPosition;
  int _routeCalculationVersion = 0;
  bool _isDisposed = false;

  List<PointOfInterest> _pointsOfInterest = [];
  List<PointOfInterest> get pointsOfInterest => _pointsOfInterest;

  final List<int> _completedPoiIndices = [];
  List<int> get completedPoiIndices => _completedPoiIndices;

  List<LatLng> _routePoints = [];
  List<LatLng> get routePoints => _routePoints;

  List<NavigationStep> _navigationSteps = [];
  int _currentStepIndex = 0;
  NavigationStep? get currentNavigationStep {
    if (_navigationSteps.isEmpty ||
        _currentStepIndex >= _navigationSteps.length) {
      return null;
    }

    return _navigationSteps[_currentStepIndex];
  }

  LatLng _currentPosition = const LatLng(38.9161, -6.3437);
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
    required this.useGoogleDirections,
  }) {
    debugPrint("[TRIP_PROVIDER] Initializing proximity-based navigation.");
    _initializeTrip();
  }

  Future<void> _initializeTrip() async {
    try {
      _isLoading = true;
      _notifyListeners();

      debugPrint("[DB] Loading points for route: $routeId");
      _pointsOfInterest = await missionUseCases.executeGetPointsForRoute(
        routeId,
      );
      if (_isDisposed) return;
      debugPrint("[DB] Loaded ${_pointsOfInterest.length} points.");

      await _initGpsTracking();
      if (_isDisposed) return;

      _selectNearestTargetPoi();
      await _calculateStreetRoute();
    } catch (e) {
      debugPrint("[TRIP_PROVIDER] Critical initialization error: $e");
    } finally {
      if (!_isDisposed) {
        _isLoading = false;
        _notifyListeners();
      }
    }
  }

  /// Selecciona el punto pendiente más cercano al usuario.
  void _selectNearestTargetPoi() {
    if (_pointsOfInterest.isEmpty) return;

    final nextPoiIndex = RouteTargetSelector.nearestPendingPoiIndex(
      pointsOfInterest: _pointsOfInterest,
      completedPoiIndices: _completedPoiIndices,
      currentPosition: _currentPosition,
    );

    if (nextPoiIndex == -1) {
      debugPrint("[ROUTE] No pending points left. Route completed.");
      _allPoisCompleted = true;
      _currentPoiIndex = -1;
      return;
    }

    _currentPoiIndex = nextPoiIndex;
    debugPrint(
      "[ROUTE] New dynamic target: ${_pointsOfInterest[_currentPoiIndex].name}",
    );
  }

  /// Calcula una ruta de calle hacia el objetivo actual.
  Future<void> _calculateStreetRoute() async {
    if (_allPoisCompleted || _currentPoiIndex == -1) {
      _routePoints = [];
      _navigationSteps = [];
      _currentStepIndex = 0;
      _notifyListeners();
      return;
    }

    final calculationVersion = ++_routeCalculationVersion;
    final targetIndex = _currentPoiIndex;

    _isCalculatingRoute = true;
    _routePoints = [];
    _navigationSteps = [];
    _currentStepIndex = 0;
    _notifyListeners();

    final target = _pointsOfInterest[targetIndex].location;
    debugPrint(
      "[OSRM] Building route to: ${_pointsOfInterest[targetIndex].name}",
    );

    late final NavigationRoute nextRoute;
    try {
      final route = await _routingService.getNavigationRoute(
        _currentPosition,
        target,
        source: useGoogleDirections
            ? NavigationRouteSource.googleWalking
            : NavigationRouteSource.appWalking,
      );
      if (_isDisposed) return;
      nextRoute = route.points.isNotEmpty
          ? route
          : NavigationRoute(points: [_currentPosition, target]);
    } catch (e) {
      if (_isDisposed) return;
      debugPrint("[OSRM] Connection error. Falling back to a straight line.");
      nextRoute = NavigationRoute(points: [_currentPosition, target]);
    }

    final isStaleCalculation =
        calculationVersion != _routeCalculationVersion ||
        targetIndex != _currentPoiIndex;
    if (isStaleCalculation) {
      // La posición GPS puede cambiar mientras llega la respuesta de ruta; si
      // el objetivo ya cambió, descartamos el resultado para no pintar rutas viejas.
      if (calculationVersion == _routeCalculationVersion) {
        _isCalculatingRoute = false;
        _notifyListeners();
      }
      return;
    }

    _routePoints = nextRoute.points;
    _navigationSteps = nextRoute.steps;
    _currentStepIndex = 0;
    _updateCurrentNavigationStep();
    _lastRoutedPosition = _currentPosition;
    _isCalculatingRoute = false;
    _notifyListeners();
  }

  /// Marca el punto actual y recalcula el siguiente objetivo por cercanía.
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
    _notifyListeners();
    return _allPoisCompleted;
  }

  Future<void> _initGpsTracking() async {
    debugPrint("[GPS] Configuring position stream.");
    LocationPermission permission = await Geolocator.checkPermission();
    if (_isDisposed) return;
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (_isDisposed) return;
    }

    Position pos = await Geolocator.getCurrentPosition();
    if (_isDisposed) return;
    _currentPosition = LatLng(pos.latitude, pos.longitude);

    _positionStream =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10,
          ),
        ).listen((Position pos) {
          if (_isDisposed) return;
          if (_isSimulating || _hasReachedDestination) return;

          _currentPosition = LatLng(pos.latitude, pos.longitude);
          _checkArrivalProximity(_currentPosition);
          _updateCurrentNavigationStep();
          _refreshStreetRouteIfNeeded();
          _notifyListeners();
        });
  }

  void _refreshStreetRouteIfNeeded() {
    if (_allPoisCompleted || _currentPoiIndex == -1 || _hasReachedDestination) {
      return;
    }

    final lastPosition = _lastRoutedPosition;
    if (lastPosition == null) return;

    final movedDistance = NavigationDistanceUtils.metersBetween(
      lastPosition,
      _currentPosition,
    );

    if (movedDistance >= 25) {
      // Recalcular en cada posición consume mucho y hace parpadear el mapa;
      // 25 metros mantiene la guía actualizada sin saturar el servicio externo.
      unawaited(_calculateStreetRoute());
    }
  }

  void _checkArrivalProximity(LatLng pos) {
    if (_hasReachedDestination || _allPoisCompleted || _currentPoiIndex == -1) {
      return;
    }

    final target = _pointsOfInterest[_currentPoiIndex];
    final distance = NavigationDistanceUtils.metersBetween(
      pos,
      target.location,
    );

    if (distance <= target.activationRadius) {
      debugPrint(
        "[ARRIVAL] Reached ${target.name}. Distance: ${distance.toInt()}m",
      );
      _currentPosition = target.location;
      _hasReachedDestination = true;
      _isSimulating = false;
      _notifyListeners();
    }
  }

  Future<void> startSimulation() async {
    if (_allPoisCompleted || _currentPoiIndex == -1) return;
    if (_isCalculatingRoute) return;

    if (_routePoints.isEmpty) {
      await _calculateStreetRoute();
      if (_isDisposed) return;
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
      if (_isDisposed || !_isSimulating) break;
      _currentPosition = point;
      _checkArrivalProximity(_currentPosition);
      _updateCurrentNavigationStep();
      _notifyListeners();
      await Future.delayed(_simulationStepDelay);
    }
    if (_isDisposed) return;

    if (_isSimulating && !_hasReachedDestination) {
      final target = _pointsOfInterest[_currentPoiIndex];
      final finalDistance = NavigationDistanceUtils.metersBetween(
        _currentPosition,
        target.location,
      );

      debugPrint(
        "[SIM] End of route points. Final distance: ${finalDistance.toInt()}m",
      );

      if (finalDistance < 200) {
        debugPrint("[SIM] Forcing arrival by final proximity.");
        _hasReachedDestination = true;
      }
    }

    _isSimulating = false;
    _notifyListeners();
  }

  double get distanceToNextPoi {
    if (_currentPoiIndex == -1 || _allPoisCompleted) return 0.0;
    return NavigationDistanceUtils.metersBetween(
      _currentPosition,
      _pointsOfInterest[_currentPoiIndex].location,
    );
  }

  double? get distanceToCurrentNavigationStep {
    final step = currentNavigationStep;
    if (step == null) return null;

    return NavigationDistanceUtils.metersBetween(
      _currentPosition,
      step.maneuverLocation,
    );
  }

  void _updateCurrentNavigationStep() {
    if (_navigationSteps.length <= 1 ||
        _currentStepIndex >= _navigationSteps.length - 1) {
      return;
    }

    var currentStep = _navigationSteps[_currentStepIndex];
    var distanceToStep = NavigationDistanceUtils.metersBetween(
      _currentPosition,
      currentStep.maneuverLocation,
    );

    while (distanceToStep <= 20 &&
        _currentStepIndex < _navigationSteps.length - 1) {
      _currentStepIndex++;
      currentStep = _navigationSteps[_currentStepIndex];
      distanceToStep = NavigationDistanceUtils.metersBetween(
        _currentPosition,
        currentStep.maneuverLocation,
      );
    }
  }

  Future<RouteCompletionSummary> finishRoute() async {
    // Solo guardamos el detalle completo cuando la nueva puntuación iguala o
    // supera la mejor marca; así el historial muestra el intento relevante.
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
    final correctAnswers = _countCorrectAnswers(answers);
    final totalAnswers = answers.length;
    final shouldSaveDetailedResult =
        currentAttemptPoints >= saveResult.savedBestPoints;

    if (shouldSaveDetailedResult) {
      await missionUseCases.saveRouteResult(
        RouteResultRecord(
          routeId: routeId,
          routeName: routeName,
          previousBestScore: saveResult.previousBestPoints,
          savedBestScore: saveResult.savedBestPoints,
          attemptScore: currentAttemptPoints,
          visitedPois: visitedPois,
          completedMissions: completedMissions,
          totalPois: _pointsOfInterest.length,
          totalPossiblePoints: (_pointsOfInterest.length * 30) + 10,
          elapsedTimeLabel: RouteDurationFormatter.format(elapsedTime),
          correctAnswers: correctAnswers,
          totalAnswers: totalAnswers,
          answerResults: _answerRecords(answers),
          skippedPois: _poiNames(skippedPois),
        ),
      );
    }

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
      skippedPoiNames: _poiNames(skippedPois),
    );
  }

  List<RouteAnswerResultRecord> _answerRecords(List<QuizAnswerResult> answers) {
    final records = <RouteAnswerResultRecord>[];

    for (final answer in answers) {
      records.add(
        RouteAnswerResultRecord(
          monumentName: answer.monumentName,
          question: answer.question,
          selectedAnswer: answer.selectedAnswer,
          correctAnswer: answer.correctAnswer,
          isCorrect: answer.isCorrect,
        ),
      );
    }

    return records;
  }

  List<PointOfInterest> _skippedPois() {
    final skippedPois = <PointOfInterest>[];

    for (final completedIndex in _completedPoiIndices) {
      final poi = _pointsOfInterest[completedIndex];

      if (!QuizRouteProgress.visitedPointIds.contains(poi.id)) {
        skippedPois.add(poi);
      }
    }

    return skippedPois;
  }

  int _countCorrectAnswers(List<QuizAnswerResult> answers) {
    var total = 0;

    for (final answer in answers) {
      if (answer.isCorrect) {
        total++;
      }
    }

    return total;
  }

  List<String> _poiNames(List<PointOfInterest> pois) {
    final names = <String>[];

    for (final poi in pois) {
      names.add(poi.name);
    }

    return names;
  }

  void _notifyListeners() {
    if (_isDisposed) return;
    notifyListeners();
  }

  @override
  void dispose() {
    debugPrint("[TRIP_PROVIDER] Disposing GPS stream.");
    _isDisposed = true;
    _isSimulating = false;
    _routeCalculationVersion++;
    _positionStream?.cancel();
    super.dispose();
  }
}
