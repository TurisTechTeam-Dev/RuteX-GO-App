import '../entities/mission_scan_result.dart';
import '../entities/poi_entity.dart';
import '../repositories/mission_repository.dart';

class MissionUseCases {
  final MissionRepository repository;

  MissionUseCases(this.repository);

  Future<MissionScanResult?> executeScan(String qrCode) async {
    final point = await repository.getPointByQr(qrCode);
    if (point == null) return null;

    final mission = await repository.getMissionByPointId(point.id);
    if (mission == null) return null;

    return MissionScanResult(point: point, mission: mission);
  }

  Future<List<PointOfInterest>> executeGetPointsForRoute(String routeId) async {
    final ids = await repository.getRoutePointIds(routeId);
    if (ids.isEmpty) return [];

    return repository.getPointsByIds(ids);
  }
}
