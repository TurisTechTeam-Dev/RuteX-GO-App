import 'package:flutter/material.dart';
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
  // 1. Controlador para que el mapa se mueva siguiendo a la flecha
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    final tripProvider = context.watch<TripSimulationProvider>();

    // 2. Escuchar cambios de posición para centrar la cámara automáticamente
    if (tripProvider.currentPosition != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.move(
          tripProvider.currentPosition!,
          _mapController.camera.zoom, // Mantenemos el zoom que elija el usuario
        );
      });
    }

    return Scaffold(
      appBar: const TopAppBar(showBack: true),
      // endDrawer: const CustomDrawer(), // Actívalo si lo tienes listo

      body: Stack(
        children: [
          // Capa 1: EL MAPA
          MapView(
            mapController: _mapController,
            routePoints: tripProvider.routePoints,
            markers: _buildMarkers(tripProvider),
            currentLocation: tripProvider.currentPosition,
          ),

          // Capa 2: EL JOYSTICK
          // Solo aparece si ya hemos pulsado "Empezar Aventura" (hay ruta o está simulando)
          if (tripProvider.routePoints.isNotEmpty || tripProvider.isSimulating)
            Positioned(
              bottom: 120, // Situado encima del botón verde
              left: 20,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 8)
                  ],
                ),
                child: Joystick(
                  mode: JoystickMode.all,
                  listener: (details) {
                    // Enviamos el movimiento al Provider
                    tripProvider.movePositionManual(details.x, details.y);
                  },
                ),
              ),
            ),

          // Capa 3: BOTÓN DE ACCIÓN (EMPEZAR / DETENER)
          Positioned(
            bottom: 30,
            left: 50,
            right: 50,
            child: _buildActionButton(tripProvider),
          ),

          // Capa 4: CARGANDO (Si no hay puntos de Firebase aún)
          if (tripProvider.pointsOfInterest.isEmpty)
            const Center(child: CircularProgressIndicator(color: Colors.green)),
        ],
      ),
    );
  }

  // Widget del botón que cambia según el estado de la ruta
  Widget _buildActionButton(TripSimulationProvider provider) {
    bool hasRoute = provider.routePoints.isNotEmpty;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: hasRoute ? Colors.redAccent : Colors.green,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 15),
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      onPressed: () {
        if (!hasRoute) {
          provider.startSimulation();
        } else {
          provider.clearRoute();
        }
      },
      child: Text(
        provider.isSimulating
            ? "SIMULANDO..."
            : (hasRoute ? "DETENER Y LIMPIAR" : "EMPEZAR AVENTURA"),
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  // Generador de marcadores (Monumentos + Flecha de usuario)
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