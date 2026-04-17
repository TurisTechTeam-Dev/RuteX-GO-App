import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/backgrounds/extremadura_map_background.dart';
import '../../../../core/widgets/titles/stroke_title.dart';
import '../../domain/usecases/routes_use_cases.dart';
import '../models/route_item.dart';
import 'route_card.dart';

class RouteSelectionContent extends StatelessWidget {
  final RoutesUseCases routesUseCases;
  final String cityId;

  const RouteSelectionContent({
    super.key,
    required this.routesUseCases,
    required this.cityId,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const ExtremaduraMapBackground(),
        SafeArea(
          child: Column(
            children: [
              Container(height: 2, color: AppColors.negroTexto),
              const SizedBox(height: 20),
              const StrokeTitle(text: "Rutas Disponibles"),
              const SizedBox(height: 20),
              Expanded(
                child: _RouteList(
                  routesUseCases: routesUseCases,
                  cityId: cityId,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RouteList extends StatelessWidget {
  final RoutesUseCases routesUseCases;
  final String cityId;

  const _RouteList({required this.routesUseCases, required this.cityId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: routesUseCases.executeGetRutasByCiudad(cityId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text("Error al cargar las rutas"));
        }

        final routeDocs = snapshot.data?.docs ?? [];

        if (routeDocs.isEmpty) {
          return const Center(
            child: Text("No hay rutas disponibles para esta ciudad"),
          );
        }

        final routes = routeDocs.map(RouteItem.fromDoc).toList();

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: routes.length,
          itemBuilder: (context, index) => RouteCard(route: routes[index]),
        );
      },
    );
  }
}
