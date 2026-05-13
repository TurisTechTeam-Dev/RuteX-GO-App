/*
  -----------------------------------------------------------------------------
  Proyecto: RuteX Go
  Desarrollado por: TurisTechTeam
  Descripción: Esta aplicación y su código fuente son propiedad intelectual de
  TurisTechTeam. Queda prohibida su copia, distribución o uso no autorizado.
  Año: 2026
  -----------------------------------------------------------------------------
*/
import '../entities/city.dart';
import '../entities/tourist_route.dart';
import '../repositories/routes_repository.dart';

class RoutesUseCases {
  final RoutesRepository repository;

  RoutesUseCases(this.repository);

  Stream<List<City>> getCities() {
    return repository.getCities();
  }

  Stream<List<TouristRoute>> getRoutes() {
    return repository.getRoutes();
  }

  Stream<List<TouristRoute>> getRoutesByCity(String cityId) {
    return repository.getRoutesByCity(cityId);
  }

  Stream<List<TouristRoute>> getRoutesByCityKeys(Set<String> cityKeys) {
    return repository.getRoutesByCityKeys(cityKeys);
  }

  Future<Map<String, bool>> executeGetRouteAvailability(
      List<TouristRoute> routes,
      ) async {
    final allPointIds = _collectUniquePointIds(routes);

    final pointIdsWithMission = await repository.getPointIdsWithMission(
      allPointIds,
    );

    return _buildAvailabilityByRoute(routes, pointIdsWithMission);
  }

  Future<Map<String, List<String>>> executeGetRoutePointNames(
      List<TouristRoute> routes,
      ) async {
    final allPointIds = _collectUniquePointIds(routes);
    final pointNamesById = await repository.getPointNamesByIds(allPointIds);
    final pointNamesByRoute = <String, List<String>>{};

    for (final route in routes) {
      final names = <String>[];

      for (final pointId in route.pointIds) {
        final name = pointNamesById[pointId.trim()]?.trim();
        if (name != null && name.isNotEmpty) {
          names.add(name);
        }
      }

      pointNamesByRoute[route.id] = names;
    }

    return pointNamesByRoute;
  }

  List<String> _collectUniquePointIds(List<TouristRoute> routes) {
    final uniquePointIds = <String>{};

    for (final route in routes) {
      for (final pointId in route.pointIds) {
        final cleanPointId = pointId.trim();

        if (cleanPointId.isNotEmpty) {
          uniquePointIds.add(cleanPointId);
        }
      }
    }

    return uniquePointIds.toList();
  }

  Map<String, bool> _buildAvailabilityByRoute(
      List<TouristRoute> routes,
      Set<String> pointIdsWithMission,
      ) {
    final availabilityByRoute = <String, bool>{};

    for (final route in routes) {
      availabilityByRoute[route.id] = _routeCanStart(
        route,
        pointIdsWithMission,
      );
    }

    return availabilityByRoute;
  }

  bool _routeCanStart(TouristRoute route, Set<String> pointIdsWithMission) {
    if (route.pointIds.length != 3) {
      return false;
    }

    for (final pointId in route.pointIds) {
      if (!pointIdsWithMission.contains(pointId.trim())) {
        return false;
      }
    }
    return true;
  }
}
