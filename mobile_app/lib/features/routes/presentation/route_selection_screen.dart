import 'package:flutter/material.dart';

import '../../../app/widgets/custom_drawer.dart';
import '../../../app/widgets/top_app_bar.dart';
import '../../../core/widgets/audio_guide/audio_guide.dart';
import '../domain/usecases/routes_use_cases.dart';
import 'widgets/route_selection_content.dart';

class RouteSelectionScreen extends StatelessWidget {
  final RoutesUseCases routesUseCases;
  final Set<String> cityKeys;

  const RouteSelectionScreen({
    super.key,
    required this.routesUseCases,
    required this.cityKeys,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopAppBar(showBack: true),
      endDrawer: const CustomDrawer(),
      body: RouteSelectionContent(
        routesUseCases: routesUseCases,
        cityKeys: cityKeys,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: const AudioGuideWidget(
        text:
            'Pantalla de rutas disponibles. Revisa cada ruta, su dificultad, duracion, puntos totales y puntos de interes. Pulsa comenzar ruta para iniciar la navegacion.',
      ),
      bottomNavigationBar: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.onSurface,
              width: 2,
            ),
          ),
        ),
        child: const SafeArea(child: SizedBox()),
      ),
    );
  }
}
