import 'package:cloud_firestore/cloud_firestore.dart';

import '../../presentation/models/route_item.dart';
import '../repository/routes_repository.dart';

class RoutesUseCases {
  final RoutesRepository repository;

  RoutesUseCases(this.repository);

  Stream<QuerySnapshot> executeGetCiudades() {
    return repository.getCiudades();
  }

  Stream<QuerySnapshot> executeGetRutas() {
    return repository.getRutas();
  }

  Stream<QuerySnapshot> executeGetRutasByCiudad(String idCiudad) {
    return repository.getRutasByCiudad(idCiudad);
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
        route.id: route.pointIds.isNotEmpty &&
            route.pointIds.every(pointIdsWithMission.contains),
    };
  }
}
