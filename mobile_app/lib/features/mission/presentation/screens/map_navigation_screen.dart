import 'package:flutter/material.dart';
import 'package:mobile_app/core/routes/app_routes.dart';
import 'package:provider/provider.dart';
import '../../../../core/map/map_view.dart';
import '../provider/trip_provider.dart';

class MapNavigationScreen extends StatelessWidget {
  final String routeId;

  const MapNavigationScreen({super.key, required this.routeId});

  @override
  Widget build(BuildContext context) {
    final tripProvider = context.watch<TripSimulationProvider>();

    // Escucha si has llegado al destino para mostrar el diálogo
    if (tripProvider.hasReachedDestination) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showArrivalDialog(context, tripProvider);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ruta RutexGo", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: Colors.black),
      ),
      body: Stack(
        children: [
          // 1. Mapa dinámico
          MapView(
            currentPosition: tripProvider.currentPosition,
            routePoints: tripProvider.routePoints,
            pointsOfInterest: tripProvider.pointsOfInterest,
          ),

          // 2. Cargando datos de Firebase
          if (tripProvider.pointsOfInterest.isEmpty)
            const Center(child: CircularProgressIndicator(color: Colors.green)),

          // 3. Panel de distancia superior
          if (tripProvider.pointsOfInterest.isNotEmpty && tripProvider.currentPosition != null)
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: _buildInfoPanel(tripProvider),
            ),

          // 4. Botón de acción inferior
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: tripProvider.isSimulating
                  ? null
                  : () => tripProvider.startSimulation(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: Text(
                tripProvider.isSimulating ? "SIMULANDO..." : "EMPEZAR AVENTURA",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoPanel(TripSimulationProvider provider) {
    if (provider.currentPoiIndex >= provider.pointsOfInterest.length) {
      return const SizedBox.shrink();
    }

    final nextPoi = provider.pointsOfInterest[provider.currentPoiIndex];
    final double meters = provider.distanceToNextPoi;

    String distanceLabel = meters >= 1000
        ? "${(meters / 1000).toStringAsFixed(1)} km"
        : "${meters.toStringAsFixed(0)} m";

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Siguiente Parada: ${nextPoi.nombre}",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(
            distanceLabel,
            style: const TextStyle(fontSize: 22, color: Colors.green, fontWeight: FontWeight.bold),
          ),
          const Text("Continúa por la ruta marcada", style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  void _showArrivalDialog(BuildContext context, TripSimulationProvider provider) {
    if (!provider.hasReachedDestination) return;

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        final poi = provider.pointsOfInterest[provider.currentPoiIndex];
        return Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("¡Has llegado a ${poi.nombre}!",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              const Text("¿Qué quieres hacer ahora?"),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.missionQrScanner);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text("Leer QR", style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    provider.skipToNext();
                  },
                  child: const Text("Saltar juego"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}