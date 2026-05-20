/*
  -----------------------------------------------------------------------------
  Proyecto: RuteX Go
  Desarrollado por: TurisTechTeam
  Descripción: Esta aplicación y su código fuente son propiedad intelectual de
  TurisTechTeam. Queda prohibida su copia, distribución o uso no autorizado.
  Año: 2026
  -----------------------------------------------------------------------------
*/
import 'package:flutter/material.dart' hide NavigationMode;
import 'package:provider/provider.dart';

import '../../../../../app/navigation/app_routes.dart';
import '../../../../../core/widgets/audio_guide/audio_guide.dart';
import '../../mission_flow_result.dart';
import '../../quiz/models/route_result_args.dart';
import '../../quiz/quiz_route_progress.dart';
import '../../qr_scanner/models/mission_scanner_args.dart';
import '../models/navigation_types.dart';
import '../models/route_completion_summary.dart';
import '../provider/trip_provider.dart';
import '../utils/route_duration_formatter.dart';
import '../widgets/arrival_bottom_sheet.dart';
import '../widgets/map_view.dart';
import '../widgets/navigation_info_panel.dart';

class MapNavigationScreen extends StatefulWidget {
  final String routeId;
  final bool allowSimulation;
  final UserRole userRole;
  final NavigationMode navigationMode;

  const MapNavigationScreen({
    super.key,
    required this.routeId,
    required this.allowSimulation,
    required this.userRole,
    required this.navigationMode,
  });

  @override
  State<MapNavigationScreen> createState() => _MapNavigationScreenState();
}

class _MapNavigationScreenState extends State<MapNavigationScreen>
    with WidgetsBindingObserver {
  bool _isDialogOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted || state != AppLifecycleState.resumed) return;
    final trip = context.read<TripSimulationProvider>();
    if (_isDialogOpen &&
        (!trip.hasReachedDestination || trip.allPoisCompleted)) {
      setState(() => _isDialogOpen = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tripProvider = context.watch<TripSimulationProvider>();
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    final autoRead = MediaQuery.of(context).accessibleNavigation;

    if (tripProvider.hasReachedDestination &&
        !_isDialogOpen &&
        !tripProvider.allPoisCompleted) {
      _isDialogOpen = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showArrivalBottomSheet(context, tripProvider);
      });
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final shouldLeave = await _confirmRouteExit(context);
        if (!context.mounted || !shouldLeave) return;

        QuizRouteProgress.reset();
        Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            "Ruta RutexGo",
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: theme.colorScheme.surface,
          elevation: 1,
          centerTitle: true,
        ),
        body: Stack(
          children: [
            MapView(
              currentPosition: tripProvider.currentPosition,
              routePoints: tripProvider.routePoints,
              pointsOfInterest: tripProvider.pointsOfInterest,
              useGoogleMaps: widget.userRole == UserRole.normal,
            ),
            if (tripProvider.isLoading)
              Container(
                color: theme.scaffoldBackgroundColor.withValues(alpha: 0.82),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.green),
                ),
              ),
            if (!tripProvider.isLoading && tripProvider.currentPoiIndex != -1)
              Positioned(
                top: 15,
                left: 15,
                right: 15,
                child: NavigationInfoPanel(
                  nextStopName: tripProvider
                      .pointsOfInterest[tripProvider.currentPoiIndex]
                      .name,
                  distanceToNextStop: tripProvider.distanceToNextPoi,
                  navigationInstruction:
                      tripProvider.currentNavigationStep?.instruction,
                  distanceToInstruction:
                      tripProvider.distanceToCurrentNavigationStep,
                ),
              ),
            Positioned(
              bottom: bottomPadding + 48,
              left: 30,
              right: 30,
              child: widget.allowSimulation
                  ? _SimulationButton(tripProvider: tripProvider)
                  : const _WalkingRouteStatus(),
            ),
            if (!tripProvider.isLoading)
              Positioned(
                left: 16,
                bottom: bottomPadding + 128,
                child: AudioGuideWidget(
                  text: _navigationAudioText(tripProvider),
                  autoRead: autoRead,
                  semanticLabel:
                      'Botón de audioguía. Pulsa para escuchar las indicaciones de navegación.',
                ),
              ),
            if (tripProvider.gpsPermissionDenied)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Material(
                  color: Colors.orange.shade700,
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.location_off, color: Colors.white, size: 18),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Sin permiso de ubicación. Actívalo en ajustes para una navegación precisa.',
                              style: TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            if (!tripProvider.isLoading && tripProvider.routeCalculationFailed)
              Positioned(
                bottom: bottomPadding + 100,
                left: 30,
                right: 30,
                child: Material(
                  color: Colors.red.shade700,
                  borderRadius: BorderRadius.circular(12),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: Row(
                      children: [
                        Icon(Icons.route, color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'No se pudo calcular la ruta. Dirígete al punto indicado en el mapa.',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _navigationAudioText(TripSimulationProvider provider) {
    if (provider.allPoisCompleted) {
      return 'Ruta completada. Puedes revisar el resultado de tu recorrido.';
    }

    if (provider.currentPoiIndex == -1 || provider.pointsOfInterest.isEmpty) {
      return 'Pantalla de navegación. Estamos preparando la ruta.';
    }

    final nextStop = provider.pointsOfInterest[provider.currentPoiIndex].name;
    final distance = provider.distanceToNextPoi.toInt();
    final instruction = provider.currentNavigationStep?.instruction;
    final routeModeText = widget.allowSimulation
        ? provider.isSimulating
              ? 'La simulación está en marcha.'
              : 'Puedes simular el recorrido desde el botón inferior.'
        : 'Sigue la ruta en Google Maps y acércate al punto para continuar.';

    if (instruction == null || instruction.isEmpty) {
      return 'Pantalla de navegación. El siguiente punto es $nextStop, a unos $distance metros. $routeModeText';
    }

    return 'Pantalla de navegación. El siguiente punto es $nextStop, a unos $distance metros. Indicación actual: $instruction. $routeModeText';
  }

  void _showArrivalBottomSheet(
    BuildContext context,
    TripSimulationProvider provider,
  ) {
    final isFinalTarget =
        provider.completedPoiIndices.length + 1 >=
        provider.pointsOfInterest.length;
    final poi = provider.pointsOfInterest[provider.currentPoiIndex];

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.72,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (sheetContext) => PopScope(
        canPop: false,
        child: ArrivalBottomSheet(
          poiName: poi.name,
          isFinalTarget: isFinalTarget,
          onScanMission: () async {
            Navigator.pop(sheetContext);

            final result = await Navigator.pushNamed(
              context,
              AppRoutes.missionQrScanner,
              arguments: MissionScannerArgs(
                routeId: widget.routeId,
                totalPois: provider.pointsOfInterest.length,
                expectedPointId: poi.id,
                expectedPointName: poi.name,
              ),
            );

            if (!context.mounted) return;

            if (result == MissionFlowResult.pointCompleted) {
              final completedRoute = provider.markCurrentPoiAsCompleted();
              if (completedRoute) {
                await _finishRoute(context, provider);
                return;
              }
            }

            setState(() => _isDialogOpen = false);
          },
          onSkipPoint: () async {
            Navigator.pop(sheetContext);

            if (isFinalTarget) {
              provider.markCurrentPoiAsCompleted();
              setState(() => _isDialogOpen = false);
              await _finishRoute(context, provider);
            } else {
              provider.markCurrentPoiAsCompleted();
              setState(() => _isDialogOpen = false);
            }
          },
        ),
      ),
    );
  }

  Future<void> _finishRoute(
    BuildContext context,
    TripSimulationProvider provider,
  ) async {
    late final RouteCompletionSummary summary;
    try {
      summary = await provider.finishRoute();
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("No se pudo guardar la ruta: $e"),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _isDialogOpen = false);
      return;
    }

    if (!context.mounted) return;

    Navigator.pushReplacementNamed(
      context,
      AppRoutes.routeResult,
      arguments: RouteResultArgs(
        routeId: widget.routeId,
        routeName: summary.routeName,
        previousBestScore: summary.previousBestPoints,
        savedBestScore: summary.savedBestPoints,
        attemptScore: summary.currentAttemptPoints,
        visitedPois: summary.visitedPois,
        completedMissions: summary.completedMissions,
        totalPois: summary.totalPois,
        totalPossiblePoints: summary.totalPossiblePoints,
        elapsedTimeLabel: RouteDurationFormatter.format(summary.elapsedTime),
        correctAnswers: summary.correctAnswers,
        totalAnswers: summary.totalAnswers,
        answerResults: summary.answerResults,
        skippedPois: summary.skippedPoiNames,
        visitedPoiNames: summary.visitedPoiNames,
      ),
    );
  }

  Future<bool> _confirmRouteExit(BuildContext context) async {
    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Salir de la ruta"),
        content: const Text(
          "Si sales ahora, el progreso de esta ruta se perderá.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Continuar ruta"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Salir"),
          ),
        ],
      ),
    );

    return shouldLeave ?? false;
  }
}

class _SimulationButton extends StatelessWidget {
  final TripSimulationProvider tripProvider;

  const _SimulationButton({required this.tripProvider});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: tripProvider.isSimulating || tripProvider.isCalculatingRoute
          ? null
          : () => tripProvider.startSimulation(),
      style: ElevatedButton.styleFrom(
        backgroundColor:
            tripProvider.isSimulating || tripProvider.isCalculatingRoute
            ? Colors.grey
            : Colors.green,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Text(
        tripProvider.isCalculatingRoute
            ? "CALCULANDO SIGUIENTE TRAMO..."
            : tripProvider.isSimulating
            ? "SIMULANDO RECORRIDO..."
            : tripProvider.completedPoiIndices.isEmpty
            ? "SIMULAR RUTA"
            : "CONTINUAR SIMULACIÓN",
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
        softWrap: true,
      ),
    );
  }
}

class _WalkingRouteStatus extends StatelessWidget {
  const _WalkingRouteStatus();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.directions_walk, color: Colors.white),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'RUTA A PIE EN CURSO',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
