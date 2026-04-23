import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/map/map_view.dart';
import '../../../../../core/routes/app_routes.dart';
import '../../mission_flow_result.dart';
import '../../quiz/quiz_route_progress.dart';
import '../provider/trip_provider.dart';

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
                child: _buildDynamicInfoPanel(tripProvider),
              ),
            Positioned(
              bottom: bottomPadding + 48,
              left: 30,
              right: 30,
              child: ElevatedButton(
                onPressed: tripProvider.isSimulating
                    ? null
                    : () => tripProvider.startSimulation(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: tripProvider.isSimulating
                      ? Colors.grey
                      : Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  tripProvider.isSimulating
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

  Widget _buildDynamicInfoPanel(TripSimulationProvider provider) {
    if (provider.allPoisCompleted) return const SizedBox.shrink();

    final nextPoi = provider.pointsOfInterest[provider.currentPoiIndex];
    final distance = provider.distanceToNextPoi;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.green,
            child: Icon(Icons.directions_walk, color: Colors.white),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Siguiente parada: ${nextPoi.nombre}",
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  distance >= 1000
                      ? "${(distance / 1000).toStringAsFixed(1)} km"
                      : "${distance.toStringAsFixed(0)} m",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showArrivalBottomSheet(
    BuildContext context,
    TripSimulationProvider provider,
  ) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
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
      builder: (sheetContext) => Container(
        padding: EdgeInsets.fromLTRB(30, 30, 30, bottomPadding + 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isFinalTarget ? "META ALCANZADA" : "HAS LLEGADO",
              style: const TextStyle(color: Colors.grey, letterSpacing: 1.2),
            ),
            const SizedBox(height: 8),
            Text(
              poi.nombre,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  Navigator.pop(sheetContext);

                  final result = await Navigator.pushNamed(
                    context,
                    AppRoutes.missionQrScanner,
                    arguments: {
                      'routeId': widget.routeId,
                      'totalPois': provider.pointsOfInterest.length,
                      'expectedPointId': poi.id,
                      'expectedPointName': poi.nombre,
                    },
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
                icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
                label: const Text(
                  "ESCANEAR PARA JUGAR",
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () async {
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
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: isFinalTarget ? Colors.red : Colors.grey,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text(
                  isFinalTarget ? "FINALIZAR RUTA" : "SALTAR E IR AL SIGUIENTE",
                  style: TextStyle(
                    color: isFinalTarget ? Colors.red : Colors.black54,
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
      arguments: {
        'routeId': widget.routeId,
        'puntuacion': summary.savedBestPoints,
        'puntuacionIntento': summary.currentAttemptPoints,
        'monumentos': summary.visitedPois,
        'misiones': summary.completedMissions,
        'totalPois': summary.totalPois,
        'puntosTotales': summary.totalPossiblePoints,
        'routeName': summary.routeName,
        'tiempo': _formatDuration(summary.elapsedTime),
        'correctAnswers': summary.correctAnswers,
        'totalAnswers': summary.totalAnswers,
        'answerResults': summary.answerResults
            .map((answer) => answer.toMap())
            .toList(),
        'skippedPois': summary.skippedPoiNames,
      },
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) return '${hours}h ${minutes}min';
    if (minutes > 0) return '${minutes}min ${seconds}s';

    return '${seconds}s';
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
