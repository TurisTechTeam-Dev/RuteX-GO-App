import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/core/constants/app_colors.dart';
import 'package:mobile_app/core/widgets/Bars/toppAppBarr.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/cards/custom_cards.dart';
import '../../profile/presentation/home_screen.dart';
import '../domain/usescases/routes_uses_cases.dart';

class RouteSelectionScreen extends StatelessWidget {
  final RoutesUsesCases routesUsesCases;
  final String idCiudad;

  const RouteSelectionScreen({
    super.key,
    required this.routesUsesCases,
    required this.idCiudad,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopAppBar(showBack: true),
      endDrawer: const CustomDrawer(),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: AppColors.blancoPuro,
              image: DecorationImage(
                image: AssetImage('assets/Mapa_fondo_Extremadura.png'),
                opacity: 0.4,
                fit: BoxFit.contain,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Container(height: 2, color: AppColors.negroTexto),
                const SizedBox(height: 20),
                const StrokeTitle(text: "Rutas Disponibles"),
                const SizedBox(height: 20),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: routesUsesCases.executeGetRutasByCiudad(idCiudad),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text("No hay rutas disponibles para esta ciudad"),
                        );
                      }

                      final rutasDocs = snapshot.data!.docs;

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: rutasDocs.length,
                        itemBuilder: (context, index) {
                          final doc = rutasDocs[index];
                          final data = doc.data() as Map<String, dynamic>;
                          final puntosInteres = data['id_puntos_interes'] as List?;
                          final totalPois = puntosInteres?.length ?? 0;

                          return _routeCard(
                            context,
                            routeId: doc.id,
                            title: data['nombre'] ?? 'Ruta',
                            description: data['descripcion'] ?? '',
                            difficulty: data['dificultad'] ?? 'Media',
                            time: data['duracion'] ?? '--',
                            distance: "$totalPois puntos",
                            totalPois: totalPois,
                            image: data['imagen_asset'] ?? "assets/merida_monumental.png",
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        height: 60,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.negroTexto, width: 2)),
        ),
        child: const SafeArea(child: SizedBox()),
      ),
    );
  }

  Widget _routeCard(
      BuildContext context, {
        required String routeId,
        required String image,
        required String title,
        required String description,
        required String difficulty,
        required String time,
        required String distance,
        required int totalPois,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: CustomCard(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.negroTexto, width: 1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: image.startsWith('http')
                      ? Image.network(image, fit: BoxFit.cover)
                      : Image.asset(image, fit: BoxFit.cover),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.account_balance, color: AppColors.verdePrincipal, size: 20),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.negroTexto),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(description, textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 10),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 6,
              children: [
                _infoRow(Icons.extension, "Dificultad: $difficulty"),
                _infoRow(Icons.access_time, "Tiempo: $time"),
                _infoRow(Icons.route, "Puntos: $distance"),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 36,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.verdePrincipal,
                  foregroundColor: AppColors.blancoPuro,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                ),
                onPressed: () {
                  // NAVEGACIÓN DIRECTA AL MAPA
                  // Se envía el routeId para que el TripSimulationProvider cargue los POIs
                  Navigator.pushNamed(
                    context,
                    AppRoutes.mapNavigation,
                    arguments: routeId,
                  );
                },
                child: const Text("Comenzar ruta"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: AppColors.verdePrincipal),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}