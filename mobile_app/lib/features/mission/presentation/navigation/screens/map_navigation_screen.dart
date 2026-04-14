import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/routes/app_routes.dart';
import '../../../../../core/map/map_view.dart';
import '../provider/trip_provider.dart';

class MapNavigationScreen extends StatefulWidget {
  final String routeId;
  const MapNavigationScreen({super.key, required this.routeId});

  @override
  State<MapNavigationScreen> createState() => _MapNavigationScreenState();
}

class _MapNavigationScreenState extends State<MapNavigationScreen> {
  bool _dialogOpen = false;

  @override
  Widget build(BuildContext context) {
    final tripProvider = context.watch<TripSimulationProvider>();

    if (tripProvider.hasReachedDestination && !_dialogOpen && !tripProvider.allPoisCompleted) {
      _dialogOpen = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showArrivalDialog(context, tripProvider);
      });
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Ruta RutexGo", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
              color: Colors.white.withOpacity(0.8),
              child: const Center(child: CircularProgressIndicator(color: Colors.green)),
            ),

          if (tripProvider.pointsOfInterest.isNotEmpty && tripProvider.currentPosition != null)
            Positioned(top: 15, left: 15, right: 15, child: _buildInfoPanel(tripProvider)),

          Positioned(
            bottom: 30, left: 30, right: 30,
            child: ElevatedButton(
              onPressed: tripProvider.isSimulating ? null : () => tripProvider.startSimulation(),
              style: ElevatedButton.styleFrom(
                backgroundColor: tripProvider.isSimulating ? Colors.grey : Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: Text(tripProvider.isSimulating ? "SIMULANDO RUTA..." : "COMENZAR RUTA",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoPanel(TripSimulationProvider provider) {
    if (provider.currentPoiIndex >= provider.pointsOfInterest.length) return const SizedBox.shrink();
    final nextPoi = provider.pointsOfInterest[provider.currentPoiIndex];
    final double meters = provider.distanceToNextPoi;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
      child: Row(
        children: [
          const CircleAvatar(backgroundColor: Colors.green, child: Icon(Icons.directions_walk, color: Colors.white)),
          const SizedBox(width: 15),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              Text(nextPoi.nombre, style: const TextStyle(fontSize: 14, color: Colors.grey), overflow: TextOverflow.ellipsis),
              Text(meters >= 1000 ? "${(meters / 1000).toStringAsFixed(1)} km" : "${meters.toStringAsFixed(0)} m",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ]),
          ),
        ],
      ),
    );
  }

  void _showArrivalDialog(BuildContext context, TripSimulationProvider provider) {
    final bool isLastPoint = provider.currentPoiIndex == provider.pointsOfInterest.length - 1;
    final poi = provider.pointsOfInterest[provider.currentPoiIndex];

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(isLastPoint ? "¡Última Parada!" : "¡Has llegado!", style: const TextStyle(color: Colors.grey)),
            Text(poi.nombre, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 25),

            // BOTÓN 1: ESCÁNER
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() => _dialogOpen = false);
                  Navigator.pop(context);
                  Navigator.pushNamed(
                    context,
                    AppRoutes.missionQrScanner,
                    arguments: widget.routeId,
                  );
                },
                icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
                label: const Text("ESCANEAR QR", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(vertical: 15)),
              ),
            ),
            const SizedBox(height: 12),

            // BOTÓN 2: SALTAR O FINALIZAR
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  setState(() => _dialogOpen = false);
                  Navigator.pop(context);
                  if (isLastPoint) {
                    provider.markCurrentPoiAsCompleted();
                    Navigator.pushReplacementNamed(context, AppRoutes.routeResult);
                  } else {
                    provider.skipToNext();
                  }
                },
                style: OutlinedButton.styleFrom(
                    side: BorderSide(color: isLastPoint ? Colors.red : Colors.grey),
                    padding: const EdgeInsets.symmetric(vertical: 15)
                ),
                child: Text(isLastPoint ? "FINALIZAR RUTA" : "SALTAR JUEGO",
                    style: TextStyle(color: isLastPoint ? Colors.red : Colors.black54, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
