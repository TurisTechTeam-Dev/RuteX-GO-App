import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/backgrounds/extremadura_map_background.dart';
import '../../../../core/widgets/titles/stroke_title.dart';
import '../../domain/entities/tourist_route.dart';
import '../../domain/usecases/routes_use_cases.dart';
import 'route_card.dart';

class RouteSelectionContent extends StatelessWidget {
  final RoutesUseCases routesUseCases;
  final Set<String> cityKeys;

  const RouteSelectionContent({
    super.key,
    required this.routesUseCases,
    required this.cityKeys,
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
                  cityKeys: cityKeys,
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
  final Set<String> cityKeys;

  const _RouteList({required this.routesUseCases, required this.cityKeys});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<TouristRoute>>(
      stream: routesUseCases.getRoutesByCityKeys(cityKeys),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          debugPrint('Error loading routes by city: ${snapshot.error}');

          final errorDetails = snapshot.error.toString();
          return Center(
            child: Text(
              kDebugMode
                  ? "Error al cargar las rutas\n$errorDetails"
                  : "Error al cargar las rutas",
              textAlign: TextAlign.center,
            ),
          );
        }

        final routes = snapshot.data ?? const <TouristRoute>[];

        if (routes.isEmpty) {
          return const Center(
            child: Text("No hay rutas disponibles para esta ciudad"),
          );
        }

        return FutureBuilder<Map<String, bool>>(
          future: routesUseCases.executeGetRouteAvailability(routes),
          builder: (context, availabilitySnapshot) {
            final availability =
                availabilitySnapshot.data ?? const <String, bool>{};

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: routes.length,
              itemBuilder: (context, index) {
                final route = routes[index];
                final canStart =
                    availabilitySnapshot.connectionState ==
                        ConnectionState.done &&
                    (availability[route.id] ?? false);

                return RouteCard(route: route, canStart: canStart);
              },
            );
          },
        );
      },
    );
  }
}
