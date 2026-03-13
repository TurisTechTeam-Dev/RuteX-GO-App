import '../entity/poi_entity.dart';
import '../repository/mission_repository.dart';

class MissionUseCases {
  final MissionRepository repository;

  MissionUseCases(this.repository);

  // Esta es la función que escanea el QR (déjala como está)
  Future<Map<String, dynamic>?> executeScan(String codigoQR) async {
    final punto = await repository.getPuntoByQr(codigoQR);
    if (punto == null) return null;
    final mision = await repository.getMisionByPuntoId(punto['id']);
    return {'punto': punto, 'mision': mision};
  }

  // Esta es la función que necesitamos para la ruta.
  // IMPORTANTE: Se llama 'executeGetOrderedPoints'
  Future<List<PointOfInterest>> executeGetOrderedPoints(String routeId) async {
    final List<String> orderedIds = await repository.getRoutePointIds(routeId);
    final List<PointOfInterest> unorderedPoints = await repository.getPointsByIds(orderedIds);

    return orderedIds.map((id) {
      return unorderedPoints.firstWhere(
            (point) => point.id == id,
        orElse: () => throw Exception("Punto con ID $id no encontrado"),
      );
    }).toList();
  }
}