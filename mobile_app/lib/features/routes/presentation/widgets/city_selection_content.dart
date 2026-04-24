import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/backgrounds/extremadura_map_background.dart';
import '../../../../core/widgets/titles/stroke_title.dart';
import '../../domain/entities/city.dart';
import '../../domain/entities/tourist_route.dart';
import '../../domain/usecases/routes_use_cases.dart';
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
    return StreamBuilder<List<City>>(
      stream: routesUseCases.getCities(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text("Error al cargar las ciudades"));
        }

        final cities = snapshot.data ?? const <City>[];

        if (cities.isEmpty) {
          return const Center(child: Text("No hay ciudades disponibles"));
        }

        return StreamBuilder<List<TouristRoute>>(
          stream: routesUseCases.getRoutes(),
          builder: (context, routesSnapshot) {
            final routes = routesSnapshot.data ?? const <TouristRoute>[];

            final routeCountByCityFromRoutes = <String, int>{};
            for (final city in cities) {
              routeCountByCityFromRoutes[city.id] = routes
                  .where((route) => route.cityId == city.id)
                  .length;
            }

            final sortedCities = [...cities]
              ..sort((a, b) {
                final aHasRoutes = (routeCountByCityFromRoutes[a.id] ?? 0) > 0;
                final bHasRoutes = (routeCountByCityFromRoutes[b.id] ?? 0) > 0;

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
              itemCount: sortedCities.length,
              itemBuilder: (context, index) {
                final city = sortedCities[index];

                return CityCard(
                  city: city,
                  routesCount: routeCountByCityFromRoutes[city.id] ?? 0,
                  isLoadingRoutes:
                      routesSnapshot.connectionState == ConnectionState.waiting,
                );
              },
            );
          },
        );
      },
    );
  }
}
