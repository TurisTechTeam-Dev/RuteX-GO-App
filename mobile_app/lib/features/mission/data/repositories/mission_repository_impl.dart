import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/constants/firestore_contract.dart';
import '../../domain/entities/mission.dart';
import '../../domain/entities/poi_entity.dart';
import '../../domain/repositories/mission_repository.dart';
import '../datasources/mission_remote_datasource.dart';
import '../models/mission_model.dart';
import '../models/poi_model.dart';

class MissionRepositoryImpl implements MissionRepository {
  static const int _firestoreWhereInLimit = 10;

  final MissionRemoteDatasource remoteDatasource;

  MissionRepositoryImpl({MissionRemoteDatasource? remoteDatasource})
    : remoteDatasource =
          remoteDatasource ??
          MissionRemoteDatasource(FirebaseFirestore.instance);

  @override
  Future<PointOfInterest?> getPointByQr(String qrCode) async {
    final snapshot = await remoteDatasource.getPointByQr(qrCode);

    if (snapshot.docs.isEmpty) return null;

    final doc = snapshot.docs.first;
    return POIModel.fromFirestore(doc.data(), doc.id);
  }

  @override
  Future<Mission?> getMissionByPointId(String pointId) async {
    try {
      final snapshot = await remoteDatasource.getMissionByPointId(pointId);

      if (snapshot.docs.isEmpty) return null;

      final doc = snapshot.docs.first;
      return MissionModel.fromFirestore(doc.data(), doc.id);
    } catch (e) {
      debugPrint("Error: $e");
    }

    return null;
  }

  @override
  Future<List<String>> getRoutePointIds(String routeId) async {
    final doc = await remoteDatasource.getRouteById(routeId);

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

    debugPrint("Searching points of interest by IDs: $ids");

    final pointsById = <String, PointOfInterest>{};

    for (var i = 0; i < ids.length; i += _firestoreWhereInLimit) {
      final chunk = ids.skip(i).take(_firestoreWhereInLimit).toList();
      final snapshot = await remoteDatasource.getPointsByIds(chunk);

      for (final doc in snapshot.docs) {
        pointsById[doc.id] = POIModel.fromFirestore(doc.data(), doc.id);
      }
    }

    debugPrint("Found in Firebase: ${pointsById.length} points");

    return ids
        .map((id) => pointsById[id])
        .whereType<PointOfInterest>()
        .toList();
  }
}
