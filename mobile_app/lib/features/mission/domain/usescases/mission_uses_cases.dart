import '../entity/poi_entity.dart';
import '../repository/mission_repository.dart';

class MissionUseCases {
  final MissionRepository repository;

  MissionUseCases(this.repository);

  /// 1. Lógica para el escaneo y obtención de datos
  Future<Map<String, dynamic>?> executeScan(String codigoQR) async {
    final punto = await repository.getPuntoByQr(codigoQR);
    if (punto == null) return null;

    final mision = await repository.getMisionByPuntoId(punto['id']);
    if (mision == null) return null;

    return {'punto': punto, 'mision': mision};
  }

  /// 2. Lógica para guardar el progreso al finalizar el quiz
  Future<void> saveMissionResult({
    required String userId,
    required String misionId,
    required int puntosObtenidos,
  }) async {
    await repository.saveMissionResult(
      userId: userId,
      misionId: misionId,
      puntosObtenidos: puntosObtenidos,
    );
  }

  Future<List<PointOfInterest>> executeGetPointsForRoute(String routeId) async {
    final List<String> ids = await repository.getRoutePointIds(routeId);
    if (ids.isEmpty) return [];
    return await repository.getPointsByIds(ids);
  }
}
