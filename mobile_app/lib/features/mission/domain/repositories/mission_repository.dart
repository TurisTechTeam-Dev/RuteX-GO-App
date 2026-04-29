import '../entities/mission.dart';
import '../entities/poi_entity.dart';
import '../entities/route_progress_save_result.dart';
import '../entities/route_result_record.dart';

abstract class MissionRepository {
  Future<PointOfInterest?> getPointByQr(String qrCode);

  Future<Mission?> getMissionByPointId(String pointId);

  Future<List<String>> getRoutePointIds(String routeId);

  Future<int> getRoutePointCount(String routeId);

  Future<String> getRouteName(String routeId);

  Future<List<PointOfInterest>> getPointsByIds(List<String> ids);

  Future<RouteProgressSaveResult> saveBestRouteProgress({
    required String routeId,
    required int currentAttemptPoints,
    required int visitedPois,
    required int completedMissions,
    required List<PointOfInterest> skippedPois,
  });

  Future<void> saveRouteResult(RouteResultRecord result);
}
