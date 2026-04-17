import '../entity/poi_entity.dart';
import '../repository/mission_repository.dart';

class MissionUseCases {
  final MissionRepository repository;

  MissionUseCases(this.repository);

  Future<Map<String, dynamic>?> executeScan(String qrCode) async {
    final punto = await repository.getPuntoByQr(qrCode);
    if (punto == null) return null;

    final mission = await repository.getMissionByPointId(punto['id']);
    if (mission == null) return null;

    return {'punto': punto, 'mision': mission};
  }

  Future<List<PointOfInterest>> executeGetPointsForRoute(String routeId) async {
    final ids = await repository.getRoutePointIds(routeId);
    if (ids.isEmpty) return [];

    return repository.getPointsByIds(ids);
  }
}
