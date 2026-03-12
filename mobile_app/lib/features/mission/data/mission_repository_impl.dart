import 'package:cloud_firestore/cloud_firestore.dart';
import '../repository/mission_repository.dart';

class MissionRepositoryImpl implements Mission_Repository {
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
      DocumentSnapshot doc = await _firestore.collection('misiones').doc(puntoId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
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
      // Guardamos en una colección nueva llamada 'resultados'
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