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
import 'package:flutter/foundation.dart';

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
            if (routesSnapshot.hasError) {
              debugPrint(
                'Error loading routes for city selection: ${routesSnapshot.error}',
              );

              final errorDetails = routesSnapshot.error.toString();
              return Center(
                child: Text(
                  kDebugMode
                      ? "Error al cargar las rutas\n$errorDetails"
                      : "Error al cargar las rutas",
                  textAlign: TextAlign.center,
                ),
              );
            }

            final routes = routesSnapshot.data ?? const <TouristRoute>[];
            final routeCountByCity = _countRoutesByCity(cities, routes);
            final sortedCities = _sortCitiesByAvailability(
              cities,
              routeCountByCity,
            );

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
                  routesCount: routeCountByCity[city.id] ?? 0,
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

  Map<String, int> _countRoutesByCity(
    List<City> cities,
    List<TouristRoute> routes,
  ) {
    final routeCountByCity = <String, int>{};

    for (final city in cities) {
      var routesInCity = 0;

      for (final route in routes) {
        if (city.routeKeys.contains(route.cityId)) {
          routesInCity++;
        }
      }

      routeCountByCity[city.id] = routesInCity;
    }

    return routeCountByCity;
  }

  List<City> _sortCitiesByAvailability(
    List<City> cities,
    Map<String, int> routeCountByCity,
  ) {
    final sortedCities = List<City>.from(cities);

    sortedCities.sort((firstCity, secondCity) {
      final firstCityHasRoutes = (routeCountByCity[firstCity.id] ?? 0) > 0;
      final secondCityHasRoutes = (routeCountByCity[secondCity.id] ?? 0) > 0;

      if (firstCityHasRoutes && !secondCityHasRoutes) {
        return -1;
      }

      if (!firstCityHasRoutes && secondCityHasRoutes) {
        return 1;
      }

      final firstTitle = firstCity.title.toLowerCase();
      final secondTitle = secondCity.title.toLowerCase();
      return firstTitle.compareTo(secondTitle);
    });

    return sortedCities;
  }
}
