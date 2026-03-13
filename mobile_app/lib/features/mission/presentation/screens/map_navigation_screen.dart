import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import '../../../../core/widgets/Bars/toppAppBarr.dart';
import '../provider/trip_provider.dart';
import '../../../../core/map/map_view.dart'; // Ajusta la ruta a tu widget

class MapNavigationScreen extends StatelessWidget {
  const MapNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tripProvider = context.watch<TripSimulationProvider>();

    return Scaffold(
      // 1. Usamos tu Widget personalizado
      appBar: const TopAppBar(showBack: true),

      // 2. Añadimos tu Drawer para que el botón de menú de la derecha funcione
      endDrawer: const CustomDrawer(),

      body: Stack(
        children: [
          // EL MAPA
          MapView(
            routePoints: tripProvider.routePoints,
            markers: _buildMarkers(tripProvider),
          ),

          // BOTÓN DE INICIO (Flotante abajo)
          Positioned(
            bottom: 30,
            left: 50,
            right: 50,
            child: _buildStartButton(tripProvider),
          ),

          // Feedback visual si no hay datos
          if (tripProvider.pointsOfInterest.isEmpty)
            const Center(child: CircularProgressIndicator(color: Colors.green)),
        ],
      ),
    );
  }

  // Botón con el estilo verde de tu app
  Widget _buildStartButton(TripSimulationProvider provider) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green, // O usa AppColors.verdePrincipal
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 15),
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      onPressed: provider.isSimulating ? null : () => provider.startSimulation(),
      child: Text(
        provider.isSimulating ? "SIGUIENDO RUTA..." : "EMPEZAR AVENTURA",
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
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