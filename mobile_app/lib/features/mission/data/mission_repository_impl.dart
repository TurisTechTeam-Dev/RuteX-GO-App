import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/repository/mission_repository.dart';

class MissionRepositoryImpl implements MissionRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Future<Map<String, dynamic>?> getPuntoByQr(String qrCode) async {
    final snapshot = await _db.collection('puntos_interes')
        .where('qr_code', isEqualTo: qrCode)
        .limit(1).get();

    if(snapshot.docs.isEmpty) return null;

    final doc = snapshot.docs.first;
    final data = doc.data();
    data['id'] = doc.id;
    return data;
  }

  @override
  Future<Map<String, dynamic>?> getMisionByPuntoId(String puntoId) async {
    final snapshot = await _db.collection('misiones')
        .where('puntos_interes_id', isEqualTo: puntoId)
        .limit(1).get();
    return snapshot.docs.isNotEmpty ? snapshot.docs.first.data() : null;
  }


}