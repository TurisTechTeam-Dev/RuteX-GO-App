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
    return Scaffold(
      appBar: const TopAppBar(showBack: true),
      endDrawer: const CustomDrawer(),
      body: CitySelectionContent(routesUseCases: routesUseCases),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: const AudioGuideWidget(
        text:
            'Pantalla de seleccion de ciudad. Elige una ciudad para ver sus rutas culturales disponibles.',
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
