import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/backgrounds/extremadura_map_background.dart';
import '../../../../core/widgets/titles/stroke_title.dart';
import '../../domain/usecases/routes_use_cases.dart';
import '../models/city_item.dart';
import 'city_card.dart';

class CitySelectionContent extends StatelessWidget {
  final RoutesUseCases routesUseCases;

  const CitySelectionContent({super.key, required this.routesUseCases});

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
              const StrokeTitle(text: "Selecciona una ciudad"),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Text(
                  "Explora el patrimonio histórico de Extremadura",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(child: _CityGrid(routesUseCases: routesUseCases)),
            ],
          ),
        ),
      ],
    );
  }
}

class _CityGrid extends StatelessWidget {
  final RoutesUseCases routesUseCases;

  const _CityGrid({required this.routesUseCases});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: routesUseCases.getCities(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text("Error al cargar las ciudades"));
        }

        final docs = snapshot.data?.docs.toList() ?? [];

        if (docs.isEmpty) {
          return const Center(child: Text("No hay ciudades disponibles"));
        }

        return StreamBuilder<QuerySnapshot>(
          stream: routesUseCases.getRoutes(),
          builder: (context, routesSnapshot) {
            final routesDocs = routesSnapshot.data?.docs ?? const [];
            final routeCountByCity = <String, int>{};

            for (final doc in routesDocs) {
              final data = doc.data() as Map<String, dynamic>;
              final cityId = data['id_ciudad']?.toString();
              if (cityId == null || cityId.isEmpty) continue;
              routeCountByCity[cityId] = (routeCountByCity[cityId] ?? 0) + 1;
            }

            final cities = docs.map(CityItem.fromDoc).toList()
              ..sort((a, b) {
                final aHasRoutes = (routeCountByCity[a.id] ?? 0) > 0;
                final bHasRoutes = (routeCountByCity[b.id] ?? 0) > 0;

                if (aHasRoutes != bHasRoutes) {
                  return aHasRoutes ? -1 : 1;
                }

                return a.title.toLowerCase().compareTo(b.title.toLowerCase());
              });

            return GridView.builder(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.72,
              ),
              itemCount: cities.length,
              itemBuilder: (context, index) {
                final city = cities[index];

                return CityCard(
                  city: city,
                  routesStream: routesUseCases.getRoutesByCity(city.id),
                );
              },
            );
          },
        );
      },
    );
  }
}
