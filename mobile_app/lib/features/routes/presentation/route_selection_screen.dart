/*
  -----------------------------------------------------------------------------
  Proyecto: RuteX Go
  Desarrollado por: TurisTechTeam
  Descripción: Esta aplicación y su código fuente son propiedad intelectual de
  TurisTechTeam. Queda prohibida su copia, distribución o uso no autorizado.
  Año: 2026
  -----------------------------------------------------------------------------
*/
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
    final autoRead = MediaQuery.of(context).accessibleNavigation;

    return Scaffold(
      appBar: const TopAppBar(showBack: true),
      endDrawer: const CustomDrawer(),
      body: RouteSelectionContent(
        routesUseCases: routesUseCases,
        cityKeys: cityKeys,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: AudioGuideWidget(
        text:
            'Estás en la pantalla de rutas disponibles. Revisa cada ruta, su dificultad, duración, puntos totales y puntos de interés. Pulsa comenzar ruta para iniciar la navegación.',
        autoRead: autoRead,
        semanticLabel:
            'Botón de audioguía. Pulsa para escuchar la descripción de las rutas disponibles.',
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
