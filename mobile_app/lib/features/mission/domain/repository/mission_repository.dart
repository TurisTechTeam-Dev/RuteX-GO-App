abstract class MissionRepository {

  Future<Map<String, dynamic>?> getPuntoByQr(String qrCode);

  Future<Map<String, dynamic>?> getMisionByPuntoId(String puntoId);

}