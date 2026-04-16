import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entity/poi_entity.dart';
import '../../domain/repository/mission_repository.dart';

class MissionRepositoryImpl implements MissionRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Future<Map<String, dynamic>?> getPuntoByQr(String qrCode) async {
    final snapshot = await _db
        .collection('puntos_interes')
        .where('qr_code', isEqualTo: qrCode)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    final data = snapshot.docs.first.data();

    data['id'] = snapshot.docs.first.id;

    return data;
  }

  @override
  Future<Map<String, dynamic>?> getMisionByPuntoId(String puntoId) async {
    try {
      final snapshot = await _db
          .collection('misiones')
          .where('puntos_interes_id', isEqualTo: puntoId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      final data = snapshot.docs.first.data();

      data['id'] = snapshot.docs.first.id;

      return data;
    } catch (e) {
      debugPrint("Error: $e");
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
      await _db.collection('resultado').add({
        'usuario_id': userId,
        'mision_id': misionId,
        'puntos': puntosObtenidos,
        'fecha': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("Error al guardar: $e");
    }
  }

  @override
  Future<List<String>> getRoutePointIds(String routeId) async {
    final doc = await _db.collection('rutas').doc(routeId.trim()).get();

    if (!doc.exists) {
      debugPrint("ERROR: No existe la ruta con ID: '$routeId'");
      return [];
    }

    final data = doc.data();
    // Verificamos el nombre exacto del campo: id_puntos_interes
    final dinamico = data?['id_puntos_interes'];

    if (dinamico is List) {
      return dinamico.map((e) => e.toString()).toList();
    }
    return [];
  }

  @override
  Future<List<PointOfInterest>> getPointsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];

    debugPrint("Buscando en puntos_interes estos IDs: $ids");

    final snapshot = await _db
        .collection('puntos_interes')
        .where(FieldPath.documentId, whereIn: ids)
        .get();

    debugPrint("Encontrados en Firebase: ${snapshot.docs.length} puntos");

    return snapshot.docs.map((doc) {
      return PointOfInterest.fromFirestore(doc.data(), doc.id);
    }).toList();
  }
}
