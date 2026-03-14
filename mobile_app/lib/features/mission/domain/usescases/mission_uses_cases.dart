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
    // Llamaremos a una función del repositorio (que definiremos a continuación)
    // para registrar que el usuario Joel ha completado la misión.
    await repository.saveMissionResult(
      userId: userId,
      misionId: misionId,
      puntosObtenidos: puntosObtenidos,
    );
  }

  Future<List<PointOfInterest>> executeGetOrderedPoints(String routeId) async {
    final List<String> orderedIds = await repository.getRoutePointIds(routeId);
    final List<PointOfInterest> unorderedPoints = await repository
        .getPointsByIds(orderedIds);

    return orderedIds.map((id) {
      return unorderedPoints.firstWhere(
        (point) => point.id == id,
        orElse: () => throw Exception("Punto con ID $id no encontrado"),
      );
    }).toList();
  }
}
