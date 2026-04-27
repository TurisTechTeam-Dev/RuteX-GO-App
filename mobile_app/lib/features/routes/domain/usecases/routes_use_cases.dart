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
    if (route.pointIds.isEmpty) {
      return false;
    }

    for (final pointId in route.pointIds) {
      if (!pointIdsWithMission.contains(pointId)) {
        return false;
      }
    }

    return true;
  }
}
