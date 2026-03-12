abstract class MissionRepository {
  // Obtiene la información del punto físico (Anfiteatro, etc.)
  Future<Map<String, dynamic>?> getPuntoByQr(String qrCode);

  // Obtiene las preguntas y datos de la misión
  Future<Map<String, dynamic>?> getMisionByPuntoId(String puntoId);

  // NUEVO: Guarda que el usuario ha completado la misión y sus puntos
  Future<void> saveMissionResult({
    required String userId,
    required String misionId,
    required int puntosObtenidos,
  });
}
