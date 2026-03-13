import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_app/features/mission/domain/entity/poi_entity.dart';

import '../../domain/repository/mission_repository.dart';
import '../model/poi_model.dart';

class MissionRepositoryImpl implements MissionRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Future<List<String>> getRoutePointIds(String routeId) async {
    final doc = await _db.collection('rutas').doc(routeId).get();
    // Accedemos al campo id_puntos_interes de tu captura de Firebase
    final data = doc.data();
    if (data != null && data['id_puntos_interes'] != null) {
      return List<String>.from(data['id_puntos_interes']);
    }
    return [];
  }

  @override
  Future<List<PointOfInterest>> getPointsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    // Traemos los puntos que pertenecen a esa ruta
    final snapshot = await _db.collection('puntos_interes')
        .where(FieldPath.documentId, whereIn: ids)
        .get();

    return snapshot.docs.map((doc) {
      return PointOfInterest.fromFirestore(doc.data(), doc.id);
    }).toList();
  }

  @override
  Future<Map<String, dynamic>?> getPuntoByQr(String qrCode) async {
    final query = await _db.collection('puntos_interes')
        .where('codigoQR', isEqualTo: qrCode)
        .limit(1)
        .get();
    return query.docs.isNotEmpty ? query.docs.first.data() : null;
  }

  @override
  Future<Map<String, dynamic>?> getMisionByPuntoId(String puntoId) async {
    final query = await _db.collection('misiones')
        .where('id_punto', isEqualTo: puntoId)
        .limit(1)
        .get();
    return query.docs.isNotEmpty ? query.docs.first.data() : null;
  }
}