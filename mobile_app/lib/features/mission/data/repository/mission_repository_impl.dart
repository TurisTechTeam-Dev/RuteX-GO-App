import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_app/features/mission/domain/entity/poi_entity.dart';

import '../../domain/repository/mission_repository.dart';
import '../model/poi_model.dart';

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

  @override
  Future<List<PointOfInterest>> getMissionPoints() async {
    try{
      final snapshot =  await _db.collection('puntos_interes').get();

      return snapshot.docs.map((doc) {
        return POIModel.fromFirestore(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      print("Error en MissionRepositoryImpl: $e");
      throw Exception("No se pudieron cargar los puntos de la misión");
    }
  }
}