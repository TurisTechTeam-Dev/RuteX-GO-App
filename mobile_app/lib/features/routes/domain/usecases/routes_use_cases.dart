import 'package:cloud_firestore/cloud_firestore.dart';

import '../../presentation/models/route_item.dart';
import '../repositories/routes_repository.dart';

class RoutesUseCases {
  final RoutesRepository repository;

  RoutesUseCases(this.repository);

  Stream<QuerySnapshot> getCities() {
    return repository.getCities();
  }

  Stream<QuerySnapshot> getRoutes() {
    return repository.getRoutes();
  }

  Stream<QuerySnapshot> getRoutesByCity(String cityId) {
    return repository.getRoutesByCity(cityId);
  }

  Future<Map<String, bool>> executeGetRouteAvailability(
    List<RouteItem> routes,
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
