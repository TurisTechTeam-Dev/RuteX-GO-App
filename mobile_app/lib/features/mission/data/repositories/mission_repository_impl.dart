import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/constants/firestore_contract.dart';
import '../../domain/entities/poi_entity.dart';
import '../../domain/repositories/mission_repository.dart';

class MissionRepositoryImpl implements MissionRepository {
  static const int _firestoreWhereInLimit = 10;

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Future<Map<String, dynamic>?> getPointByQr(String qrCode) async {
    final snapshot = await _db
        .collection(FirestoreCollections.puntosInteres)
        .where(PointInterestFields.qrCode, isEqualTo: qrCode)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    final data = snapshot.docs.first.data();
    data['id'] = snapshot.docs.first.id;

    return data;
  }

  @override
  Future<Map<String, dynamic>?> getMissionByPointId(String pointId) async {
    try {
      final snapshot = await _db
          .collection(FirestoreCollections.misiones)
          .where(MissionFields.puntosInteresId, isEqualTo: pointId)
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
  Future<List<String>> getRoutePointIds(String routeId) async {
    final doc = await _db
        .collection(FirestoreCollections.rutas)
        .doc(routeId.trim())
        .get();

    if (!doc.exists) {
      debugPrint("ERROR: No existe la ruta con ID: '$routeId'");
      return [];
    }

    final routePointIds = doc.data()?[RouteFields.idPuntosInteres];

    if (routePointIds is List) {
      return routePointIds.map((e) => e.toString()).toList();
    }

    return [];
  }

  @override
  Future<List<PointOfInterest>> getPointsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];

    debugPrint("Buscando en puntos_interes estos IDs: $ids");

    final pointsById = <String, PointOfInterest>{};

    for (var i = 0; i < ids.length; i += _firestoreWhereInLimit) {
      final chunk = ids.skip(i).take(_firestoreWhereInLimit).toList();
      final snapshot = await _db
          .collection(FirestoreCollections.puntosInteres)
          .where(FieldPath.documentId, whereIn: chunk)
          .get();

      for (final doc in snapshot.docs) {
        pointsById[doc.id] = PointOfInterest.fromFirestore(doc.data(), doc.id);
      }
    }

    debugPrint("Encontrados en Firebase: ${pointsById.length} puntos");

    return ids
        .map((id) => pointsById[id])
        .whereType<PointOfInterest>()
        .toList();
  }
}
