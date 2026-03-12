import '../repository/mission_repository.dart';

class MissionUseCases {
  final MissionRepository repository;

  MissionUseCases(this.repository);

  /// 1. Lógica para el escaneo y obtención de datos
  Future<Map<String, dynamic>?> executeScan(String codigoQR) async {
    // Buscamos el punto de interés (Teatro, Anfiteatro, etc.)
    final punto = await repository.getPuntoByQr(codigoQR);
    if (punto == null) return null;

    // Buscamos la misión que pertenece a ese punto
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
    await repository.saveMissionResult(userId: userId, misionId: misionId, puntosObtenidos: puntosObtenidos);
  }
}
