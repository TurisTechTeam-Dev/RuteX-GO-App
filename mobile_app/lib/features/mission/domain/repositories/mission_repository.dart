import '../entities/mission.dart';
import '../entities/poi_entity.dart';

abstract class MissionRepository {
  Future<PointOfInterest?> getPointByQr(String qrCode);

  Future<Mission?> getMissionByPointId(String pointId);

  Future<List<String>> getRoutePointIds(String routeId);

  Future<int> getRoutePointCount(String routeId);

  Future<List<PointOfInterest>> getPointsByIds(List<String> ids);
}
