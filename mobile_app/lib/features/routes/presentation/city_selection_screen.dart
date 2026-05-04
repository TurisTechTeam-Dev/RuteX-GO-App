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
import 'widgets/city_selection_content.dart';

class CitySelectionScreen extends StatelessWidget {
  final RoutesUseCases routesUseCases;

  const CitySelectionScreen({super.key, required this.routesUseCases});

  @override
  Widget build(BuildContext context) {
    final autoRead = MediaQuery.of(context).accessibleNavigation;

    return Scaffold(
      appBar: const TopAppBar(showBack: true),
      endDrawer: const CustomDrawer(),
      body: CitySelectionContent(routesUseCases: routesUseCases),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: AudioGuideWidget(
        text:
            'Bienvenido al explorador de ciudades. Selecciona una ciudad para ver sus rutas históricas y culturales disponibles en Extremadura.',
        autoRead: autoRead,
        semanticLabel:
            'Botón de audioguía. Pulsa para escuchar la descripción del selector de ciudades.',
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
