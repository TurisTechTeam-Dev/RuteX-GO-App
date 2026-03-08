import '../repository/mission_repository.dart';

class MissionUseCases {
  final MissionRepository repository;

  MissionUseCases(this.repository);

  Future<Map<String, dynamic>?> executeScan(String codigoQR) async {
    // Buscamos el punto (Anfiteatro, etc.)
    final punto = await repository.getPuntoByQr(codigoQR);
    if (punto == null) return null;

    // Buscamos la misión asociada
    final mision = await repository.getMisionByPuntoId(punto['id']);

    return {
      'punto': punto,
      'mision': mision,
    };
  }
}