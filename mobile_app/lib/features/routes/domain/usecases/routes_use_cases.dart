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
    final allPointIds = routes
        .expand((route) => route.pointIds)
        .where((pointId) => pointId.trim().isNotEmpty)
        .toSet()
        .toList();

    final pointIdsWithMission = await repository.getPointIdsWithMission(
      allPointIds,
    );

    return {
      for (final route in routes)
        route.id:
            route.pointIds.isNotEmpty &&
            route.pointIds.every(pointIdsWithMission.contains),
    };
  }
}
