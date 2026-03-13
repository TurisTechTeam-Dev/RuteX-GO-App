import 'package:flutter/material.dart';
import 'package:mobile_app/core/routes/app_routes.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import '../../../../core/widgets/Bars/toppAppBarr.dart';
import '../provider/trip_provider.dart';
import '../../../../core/map/map_view.dart';

class MapNavigationScreen extends StatefulWidget {
  const MapNavigationScreen({super.key});

  @override
  State<MapNavigationScreen> createState() => _MapNavigationScreenState();
}

class _MapNavigationScreenState extends State<MapNavigationScreen> {
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    final tripProvider = context.watch<TripSimulationProvider>();

    // Centrar cámara automáticamente
    if (tripProvider.currentPosition != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.move(
          tripProvider.currentPosition!,
          _mapController.camera.zoom,
        );
      });
    }

    return Scaffold(
      appBar: const TopAppBar(showBack: true),
      body: Stack(
        children: [
          // 1. EL MAPA
          MapView(
            mapController: _mapController,
            routePoints: tripProvider.routePoints,
            markers: _buildMarkers(tripProvider),
            currentLocation: tripProvider.currentPosition,
          ),

          // 2. EL JOYSTICK (Solo si no estamos en una parada)
          if ((tripProvider.routePoints.isNotEmpty || tripProvider.isSimulating) && !tripProvider.isNearPOI)
            Positioned(
              bottom: 120,
              left: 20,
              child: _buildJoystick(tripProvider),
            ),

          // 3. BOTÓN PRINCIPAL (Solo se muestra si no hemos llegado a un punto)
          if (!tripProvider.isNearPOI)
            Positioned(
              bottom: 30,
              left: 50,
              right: 50,
              child: _buildStartButton(tripProvider),
            ),

          // 4. PANEL DE MISIÓN (El panel blanco de tu imagen)
          if (tripProvider.isNearPOI && tripProvider.activePOI != null)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: _buildMissionPanel(context, tripProvider),
            ),

          if (tripProvider.pointsOfInterest.isEmpty)
            const Center(child: CircularProgressIndicator(color: Colors.green)),
        ],
      ),
    );
  }

  // Panel con el diseño de tu imagen
  Widget _buildMissionPanel(BuildContext context, TripSimulationProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Siguiente Parada: ${provider.activePOI!.nombre}",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 5),
          const Text(
            "¡Has llegado al destino! Elige cómo continuar:",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          // Botón Leer QR
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007D3A), // Verde oscuro
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                // Navegar a tu pantalla de scanner
                Navigator.pushNamed(context, AppRoutes.missionQrScanner);
                debugPrint("Ir a Scanner");
              },
              child: const Text("Leer QR", style: TextStyle(color: Colors.white)),
            ),
          ),
          const SizedBox(height: 10),
          // Botón Saltar Juego
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007D3A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                provider.nextMission(); // Salta al siguiente y limpia ruta
              },
              child: const Text("Saltar juego", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJoystick(TripSimulationProvider provider) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        shape: BoxShape.circle,
      ),
      child: Joystick(
        mode: JoystickMode.all,
        listener: (details) => provider.movePositionManual(details.x, details.y),
      ),
    );
  }

  Widget _buildStartButton(TripSimulationProvider provider) {
    bool hasRoute = provider.routePoints.isNotEmpty;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: hasRoute ? Colors.redAccent : Colors.green,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      onPressed: () => hasRoute ? provider.clearRoute() : provider.startSimulation(),
      child: Text(provider.isSimulating ? "SIMULANDO..." : (hasRoute ? "LIMPIAR" : "EMPEZAR AVENTURA")),
    );
  }

  List<Marker> _buildMarkers(TripSimulationProvider provider) {
    final markers = provider.pointsOfInterest.map((poi) {
      return Marker(
        point: poi.localizacion,
        width: 45,
        height: 45,
        child: const Icon(Icons.location_on, color: Colors.red, size: 40),
      );
    }).toList();

    if (provider.currentPosition != null) {
      markers.add(
        Marker(
          point: provider.currentPosition!,
          width: 40,
          height: 40,
          child: const Icon(Icons.navigation, color: Colors.blue, size: 35),
        ),
      );
    }
    return markers;
  }
}