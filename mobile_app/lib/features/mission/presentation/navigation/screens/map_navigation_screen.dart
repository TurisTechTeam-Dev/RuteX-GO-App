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
  bool _isDialogOpen = false;

  @override
  Widget build(BuildContext context) {
    final tripProvider = context.watch<TripSimulationProvider>();

    // Control de apertura del diálogo de llegada
    if (tripProvider.hasReachedDestination && !_isDialogOpen && !tripProvider.allPoisCompleted) {
      _isDialogOpen = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showArrivalBottomSheet(context, tripProvider);
      });
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
            "Ruta RutexGo",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Vista del mapa con datos dinámicos
          MapView(
            currentPosition: tripProvider.currentPosition,
            routePoints: tripProvider.routePoints,
            pointsOfInterest: tripProvider.pointsOfInterest,
          ),

          // Pantalla de carga inicial
          if (tripProvider.isLoading)
            Container(
              color: Colors.white.withOpacity(0.8),
              child: const Center(
                  child: CircularProgressIndicator(color: Colors.green)
              ),
            ),

          // Panel de información del próximo destino (por proximidad)
          if (!tripProvider.isLoading && tripProvider.currentPoiIndex != -1)
            Positioned(
                top: 15,
                left: 15,
                right: 15,
                child: _buildDynamicInfoPanel(tripProvider)
            ),

          // Botón de Simulación / Acción
          Positioned(
            bottom: 30,
            left: 30,
            right: 30,
            child: ElevatedButton(
              onPressed: tripProvider.isSimulating
                  ? null
                  : () => tripProvider.startSimulation(),
              style: ElevatedButton.styleFrom(
                backgroundColor: tripProvider.isSimulating ? Colors.grey : Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: Text(
                  tripProvider.isSimulating ? "SIMULANDO RECORRIDO..." : "COMENZAR RUTA",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicInfoPanel(TripSimulationProvider provider) {
    // Si ya completamos todo, no mostramos el panel
    if (provider.allPoisCompleted) return const SizedBox.shrink();

    final nextPoi = provider.pointsOfInterest[provider.currentPoiIndex];
    final double distance = provider.distanceToNextPoi;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)]
      ),
      child: Row(
        children: [
          const CircleAvatar(
              backgroundColor: Colors.green,
              child: Icon(Icons.directions_walk, color: Colors.white)
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
                    overflow: TextOverflow.ellipsis
                ),
                Text(
                    distance >= 1000
                        ? "${(distance / 1000).toStringAsFixed(1)} km"
                        : "${distance.toStringAsFixed(0)} m",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showArrivalBottomSheet(BuildContext context, TripSimulationProvider provider) {
    // Verificamos si, tras este punto, ya no quedan más en la bolsa de la DB
    final bool isFinalTarget = provider.completedPoiIndices.length + 1 >= provider.pointsOfInterest.length;
    final poi = provider.pointsOfInterest[provider.currentPoiIndex];

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30))
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
                isFinalTarget ? "¡META ALCANZADA!" : "¡HAS LLEGADO!",
                style: const TextStyle(color: Colors.grey, letterSpacing: 1.2)
            ),
            const SizedBox(height: 8),
            Text(
                poi.nombre,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center
            ),
            const SizedBox(height: 25),

            // BOTÓN: ESCANEAR QR (Ir al juego)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() => _isDialogOpen = false);
                  Navigator.pop(context);
                  Navigator.pushNamed(
                    context,
                    AppRoutes.missionQrScanner,
                    arguments: widget.routeId,
                  );
                },
                icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
                label: const Text("ESCANEAR PARA JUGAR", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                ),
              ),
            ),
            const SizedBox(height: 12),

            // BOTÓN: SALTAR/FINALIZAR (Navegación Dinámica)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  setState(() => _isDialogOpen = false);
                  Navigator.pop(context);

                  if (isFinalTarget) {
                    debugPrint("🏁 [UI] Finalizando última parada de la ruta.");
                    provider.markCurrentPoiAsCompleted();
                    Navigator.pushReplacementNamed(context, AppRoutes.routeResult);
                  } else {
                    debugPrint("⏭️ [UI] Saltando punto. Buscando siguiente por proximidad...");
                    provider.markCurrentPoiAsCompleted();
                  }
                },
                style: OutlinedButton.styleFrom(
                    side: BorderSide(color: isFinalTarget ? Colors.red : Colors.grey),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                ),
                child: Text(
                    isFinalTarget ? "FINALIZAR RUTA" : "SALTAR E IR AL SIGUIENTE",
                    style: TextStyle(
                        color: isFinalTarget ? Colors.red : Colors.black54,
                        fontWeight: FontWeight.bold
                    )
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}