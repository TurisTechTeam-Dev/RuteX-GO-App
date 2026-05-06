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
import 'package:provider/provider.dart';

import '../../../../core/widgets/backgrounds/extremadura_map_background.dart';
import '../../../../core/widgets/titles/stroke_title.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../../auth/domain/usecases/auth_use_cases.dart';
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
              SizedBox(height: ResponsiveLayout.isCompact(context) ? 12 : 20),
              const StrokeTitle(text: "Rutas Disponibles"),
              SizedBox(height: ResponsiveLayout.isCompact(context) ? 12 : 20),
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
    final authUseCases = context.read<AuthUseCases>();

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

        return FutureBuilder<_RouteListData>(
          future: _loadRouteListData(routes, authUseCases),
          builder: (context, routeDataSnapshot) {
            final routeData =
                routeDataSnapshot.data ?? const _RouteListData.empty();
            final isCheckingAvailability =
                routeDataSnapshot.connectionState != ConnectionState.done;

            return ListView.builder(
              padding: EdgeInsets.fromLTRB(
                ResponsiveLayout.horizontalPadding(context),
                0,
                ResponsiveLayout.horizontalPadding(context),
                MediaQuery.paddingOf(context).bottom + 96,
              ),
              itemCount: routes.length,
              itemBuilder: (context, index) {
                final route = routes[index];
                final canStart =
                    !isCheckingAvailability &&
                    (routeData.availability[route.id] ?? false);

                return RouteCard(
                  route: route,
                  canStart: canStart,
                  pointNames: routeData.pointNames[route.id] ?? const [],
                  isCheckingAvailability: isCheckingAvailability,
                  isAdmin: routeData.isAdmin,
                );
              },
            );
          },
        );
      },
    );
  }

  Future<_RouteListData> _loadRouteListData(
    List<TouristRoute> routes,
    AuthUseCases authUseCases,
  ) async {
    final availability = await routesUseCases.executeGetRouteAvailability(
      routes,
    );
    final pointNames = await routesUseCases.executeGetRoutePointNames(routes);
    final currentUser = authUseCases.getCurrentUser();
    final isAdmin = currentUser == null
        ? false
        : await authUseCases.checkAdminStatus(currentUser.uid);

    return _RouteListData(
      availability: availability,
      pointNames: pointNames,
      isAdmin: isAdmin,
    );
  }
}

class _RouteListData {
  final Map<String, bool> availability;
  final Map<String, List<String>> pointNames;
  final bool isAdmin;

  const _RouteListData({
    required this.availability,
    required this.pointNames,
    required this.isAdmin,
  });

  const _RouteListData.empty()
    : availability = const <String, bool>{},
      pointNames = const <String, List<String>>{},
      isAdmin = false;
}
