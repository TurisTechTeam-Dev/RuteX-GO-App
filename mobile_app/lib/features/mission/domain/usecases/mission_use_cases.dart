import '../entities/mission_scan_result.dart';
import '../entities/poi_entity.dart';
import '../entities/route_progress_save_result.dart';
import '../entities/route_result_record.dart';
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

  Future<int> getRoutePointCount(String routeId) {
    return repository.getRoutePointCount(routeId);
  }

  Future<String> getRouteName(String routeId) {
    return repository.getRouteName(routeId);
  }

  Future<RouteProgressSaveResult> saveBestRouteProgress({
    required String routeId,
    required int currentAttemptPoints,
    required int visitedPois,
    required int completedMissions,
    required List<PointOfInterest> skippedPois,
  }) {
    return repository.saveBestRouteProgress(
      routeId: routeId,
      currentAttemptPoints: currentAttemptPoints,
      visitedPois: visitedPois,
      completedMissions: completedMissions,
      skippedPois: skippedPois,
    );
  }

  Future<void> saveRouteResult(RouteResultRecord result) {
    return repository.saveRouteResult(result);
  }
}
