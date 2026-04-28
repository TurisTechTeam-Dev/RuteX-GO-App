import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../app/navigation/app_routes.dart';
import '../../mission_flow_result.dart';
import '../../quiz/models/route_result_args.dart';
import '../../quiz/quiz_route_progress.dart';
import '../../qr_scanner/models/mission_scanner_args.dart';
import '../models/route_completion_summary.dart';
import '../provider/trip_provider.dart';
import '../utils/route_duration_formatter.dart';
import '../widgets/arrival_bottom_sheet.dart';
import '../widgets/map_view.dart';
import '../widgets/navigation_info_panel.dart';

class MapNavigationScreen extends StatefulWidget {
  final String routeId;

  const MapNavigationScreen({super.key, required this.routeId});

  @override
  State<MapNavigationScreen> createState() => _MapNavigationScreenState();
}

class _MapNavigationScreenState extends State<MapNavigationScreen> {
  bool _isDialogOpen = false;

  @override
  Widget build(BuildContext context) {
    final tripProvider = context.watch<TripSimulationProvider>();
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

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
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text(
            "Ruta RutexGo",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          elevation: 1,
          centerTitle: true,
        ),
        body: Stack(
          children: [
            MapView(
              currentPosition: tripProvider.currentPosition,
              routePoints: tripProvider.routePoints,
              pointsOfInterest: tripProvider.pointsOfInterest,
            ),
            if (tripProvider.isLoading)
              Container(
                color: Colors.white.withValues(alpha: 0.8),
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
              child: ElevatedButton(
                onPressed:
                    tripProvider.isSimulating || tripProvider.isCalculatingRoute
                    ? null
                    : () => tripProvider.startSimulation(),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      tripProvider.isSimulating ||
                          tripProvider.isCalculatingRoute
                      ? Colors.grey
                      : Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  tripProvider.isCalculatingRoute
                      ? "CALCULANDO SIGUIENTE TRAMO..."
                      : tripProvider.isSimulating
                      ? "SIMULANDO RECORRIDO..."
                      : tripProvider.completedPoiIndices.isEmpty
                      ? "COMENZAR RUTA"
                      : "CONTINUAR RUTA",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
      builder: (sheetContext) => ArrivalBottomSheet(
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
