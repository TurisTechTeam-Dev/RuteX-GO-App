import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/repository/mission_repository.dart';

class MissionRepositoryImpl implements MissionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<Map<String, dynamic>?> getPuntoByQr(String qrCode) async {
    final snapshot = await _firestore
        .collection('puntos_interes')
        .where('qr_code', isEqualTo: qrCode)
        .get();

    if (snapshot.docs.isEmpty) return null;

    var data = snapshot.docs.first.data();
    data['id'] = snapshot.docs.first.id;
    return data;
  }

  @override
  Future<Map<String, dynamic>?> getMisionByPuntoId(String puntoId) async {
    try {
      final snapshot = await _firestore
          .collection('misiones')
          .where('puntos_interes_id', isEqualTo: puntoId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        data['id'] = snapshot.docs.first.id;
        return data;
      }
    } catch (e) {
      print("Error: $e");
    }

    return null;
  }

  @override
  Future<void> saveMissionResult({
    required String userId,
    required String misionId,
    required int puntosObtenidos,
  }) async {
    try {
      await _firestore.collection('resultado').add({
        'usuario_id': userId,
        'mision_id': misionId,
        'puntos': puntosObtenidos,
        'fecha': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error al guardar: $e");
    }
  }
}
