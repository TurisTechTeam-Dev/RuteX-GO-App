import '../entity/poi_entity.dart';

abstract class MissionRepository {
  // Obtiene la información del punto físico (Anfiteatro, etc.)
  Future<Map<String, dynamic>?> getPuntoByQr(String qrCode);

  // Obtiene las preguntas y datos de la misión
  Future<Map<String, dynamic>?> getMisionByPuntoId(String puntoId);

  Future<List<String>> getRoutePointIds(String routeId);

  Future<List<PointOfInterest>> getPointsByIds(List<String> ids);

  // NUEVO: Guarda que el usuario ha completado la misión y sus puntos
  Future<void> saveMissionResult({
    required String userId,
    required String misionId,
    required int puntosObtenidos,
  });
}
