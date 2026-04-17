import '../entity/poi_entity.dart';

abstract class MissionRepository {
  Future<Map<String, dynamic>?> getPuntoByQr(String qrCode);

  Future<Map<String, dynamic>?> getMissionByPointId(String pointId);

  Future<List<String>> getRoutePointIds(String routeId);

  Future<List<PointOfInterest>> getPointsByIds(List<String> ids);
}
