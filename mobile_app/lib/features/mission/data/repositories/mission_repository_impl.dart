/*
  -----------------------------------------------------------------------------
  Proyecto: RuteX Go
  Desarrollado por: TurisTechTeam
  Descripción: Esta aplicación y su código fuente son propiedad intelectual de
  TurisTechTeam. Queda prohibida su copia, distribución o uso no autorizado.
  Año: 2026
  -----------------------------------------------------------------------------
*/
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/constants/firestore_contract.dart';
import '../../domain/entities/mission.dart';
import '../../domain/entities/poi_entity.dart';
import '../../domain/entities/route_progress_save_result.dart';
import '../../domain/entities/route_result_record.dart';
import '../../domain/repositories/mission_repository.dart';
import '../datasources/mission_remote_datasource.dart';
import '../models/completed_route_progress_model.dart';
import '../models/mission_model.dart';
import '../models/poi_model.dart';
import '../models/route_result_record_model.dart';

class MissionRepositoryImpl implements MissionRepository {
  static const int _firestoreWhereInLimit = 10;

  final MissionRemoteDataSource remoteDataSource;
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  MissionRepositoryImpl({
    MissionRemoteDataSource? remoteDataSource,
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  }) : firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       firestore = firestore ?? FirebaseFirestore.instance,
       remoteDataSource =
           remoteDataSource ??
           MissionRemoteDataSource(firestore ?? FirebaseFirestore.instance);

  @override
  Future<PointOfInterest?> getPointByQr(String qrCode) async {
    final snapshot = await remoteDataSource.getPointByQr(qrCode);

    if (snapshot.docs.isEmpty) return null;

    final doc = snapshot.docs.first;
    return POIModel.fromFirestore(doc.data(), doc.id);
  }

  @override
  Future<Mission?> getMissionByPointId(String pointId) async {
    try {
      final snapshot = await remoteDataSource.getMissionByPointId(pointId);

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        return MissionModel.fromFirestore(doc.data(), doc.id);
      }

      final singularSnapshot = await remoteDataSource
          .getMissionBySingularPointId(pointId);

      if (singularSnapshot.docs.isNotEmpty) {
        final doc = singularSnapshot.docs.first;
        return MissionModel.fromFirestore(doc.data(), doc.id);
      }

      final refSnapshot = await remoteDataSource.getMissionByPointRef(pointId);

      if (refSnapshot.docs.isNotEmpty) {
        final doc = refSnapshot.docs.first;
        return MissionModel.fromFirestore(doc.data(), doc.id);
      }

      final singularRefSnapshot = await remoteDataSource
          .getMissionBySingularPointRef(pointId);

      if (singularRefSnapshot.docs.isNotEmpty) {
        final doc = singularRefSnapshot.docs.first;
        return MissionModel.fromFirestore(doc.data(), doc.id);
      }
    } catch (e) {
      debugPrint("Failed to load mission for point '$pointId': $e");
    }

    return null;
  }

  @override
  Future<List<String>> getRoutePointIds(String routeId) async {
    final doc = await remoteDataSource.getRouteById(routeId);

    if (!doc.exists) {
      debugPrint("Route '$routeId' does not exist.");
      return [];
    }

    final routePointIds = doc.data()?[RouteFields.idPuntosInteres];

    if (routePointIds is List) {
      return _pointIdsFromRouteValues(routePointIds);
    }

    return [];
  }

  @override
  Future<int> getRoutePointCount(String routeId) async {
    return (await getRoutePointIds(routeId)).length;
  }

  @override
  Future<String> getRouteName(String routeId) async {
    final doc = await remoteDataSource.getRouteById(routeId);

    return doc.data()?[RouteFields.nombre]?.toString() ?? 'Ruta completada';
  }

  @override
  Future<List<PointOfInterest>> getPointsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];

    debugPrint("Searching points of interest by IDs: $ids");

    final pointsById = <String, PointOfInterest>{};

    for (var i = 0; i < ids.length; i += _firestoreWhereInLimit) {
      final chunk = ids.skip(i).take(_firestoreWhereInLimit).toList();
      final snapshot = await remoteDataSource.getPointsByIds(chunk);

      for (final doc in snapshot.docs) {
        pointsById[doc.id] = POIModel.fromFirestore(doc.data(), doc.id);
      }
    }

    debugPrint("Found in Firebase: ${pointsById.length} points");

    return _sortPointsByRequestedIds(ids, pointsById);
  }

  @override
  Future<RouteProgressSaveResult> saveBestRouteProgress({
    required String routeId,
    required int currentAttemptPoints,
    required int visitedPois,
    required int completedMissions,
    required List<PointOfInterest> skippedPois,
  }) async {
    final user = firebaseAuth.currentUser;
    if (user == null) {
      return RouteProgressSaveResult(
        previousBestPoints: 0,
        savedBestPoints: currentAttemptPoints,
      );
    }

    final userRef = firestore
        .collection(FirestoreCollections.usuarios)
        .doc(user.uid);

    return firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(userRef);
      final data = snapshot.data() ?? {};
      final completedRoutes = List<dynamic>.from(
        data[UserFields.rutasCompletadas] ?? [],
      );
      final normalizedRoutes = List<dynamic>.from(completedRoutes);
      final savedProgress = CompletedRouteProgressModel.findMatch(
        completedRoutes: normalizedRoutes,
        routeId: routeId,
      );
      final previousBestPoints = savedProgress.previousBestPoints;

      if (savedProgress.exists && previousBestPoints >= currentAttemptPoints) {
        return RouteProgressSaveResult(
          previousBestPoints: previousBestPoints,
          savedBestPoints: previousBestPoints,
        );
      }

      final routeProgress = CompletedRouteProgressModel.toFirestore(
        routeId: routeId,
        currentAttemptPoints: currentAttemptPoints,
        visitedPois: visitedPois,
        completedMissions: completedMissions,
        skippedPois: skippedPois,
      );

      if (!savedProgress.exists) {
        normalizedRoutes.add(routeProgress);
      } else {
        normalizedRoutes[savedProgress.index] = routeProgress;
      }

      final updates = <String, dynamic>{
        UserFields.rutasCompletadas: normalizedRoutes,
      };

      final pointsDelta = currentAttemptPoints - previousBestPoints;
      if (pointsDelta > 0) {
        updates[UserFields.puntos] = FieldValue.increment(pointsDelta);
      }

      transaction.update(userRef, updates);
      return RouteProgressSaveResult(
        previousBestPoints: previousBestPoints,
        savedBestPoints: currentAttemptPoints,
      );
    });
  }

  @override
  Future<void> saveRouteResult(RouteResultRecord result) async {
    final user = firebaseAuth.currentUser;
    if (user == null) return;

    final resultId = ResultDocIds.routeResult(
      uid: user.uid,
      routeId: result.routeId,
    );

    await firestore
        .collection(FirestoreCollections.resultado)
        .doc(resultId)
        .set(
          RouteResultRecordModel.toFirestore(uid: user.uid, result: result),
          SetOptions(merge: true),
        );
  }

  String _pointIdFromRouteValue(dynamic rawValue) {
    if (rawValue == null) return '';

    if (rawValue is DocumentReference) {
      return rawValue.id.trim();
    }

    if (rawValue is Map) {
      const nestedKeys = ['id', 'uid', 'path', 'ref', 'reference'];
      for (final key in nestedKeys) {
        final value = _pointIdFromRouteValue(rawValue[key]);
        if (value.isNotEmpty) return value;
      }
    }

    final value = rawValue.toString().trim();
    if (value.isEmpty) return '';

    final segments = value.split('/');
    final lastSegment = segments.last.trim();
    return lastSegment.isEmpty ? value : lastSegment;
  }

  List<String> _pointIdsFromRouteValues(List<dynamic> routePointValues) {
    final pointIds = <String>[];

    for (final rawPointId in routePointValues) {
      final pointId = _pointIdFromRouteValue(rawPointId);

      if (pointId.isNotEmpty) {
        pointIds.add(pointId);
      }
    }

    return pointIds;
  }

  List<PointOfInterest> _sortPointsByRequestedIds(
    List<String> requestedIds,
    Map<String, PointOfInterest> pointsById,
  ) {
    final sortedPoints = <PointOfInterest>[];

    for (final id in requestedIds) {
      final point = pointsById[id];

      if (point != null) {
        sortedPoints.add(point);
      }
    }

    return sortedPoints;
  }
}
