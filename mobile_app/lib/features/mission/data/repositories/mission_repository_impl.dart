import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/constants/firestore_contract.dart';
import '../../domain/entities/mission.dart';
import '../../domain/entities/poi_entity.dart';
import '../../domain/entities/route_progress_save_result.dart';
import '../../domain/repositories/mission_repository.dart';
import '../datasources/mission_remote_datasource.dart';
import '../models/completed_route_progress_model.dart';
import '../models/mission_model.dart';
import '../models/poi_model.dart';

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

      if (snapshot.docs.isEmpty) return null;

      final doc = snapshot.docs.first;
      return MissionModel.fromFirestore(doc.data(), doc.id);
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
      return routePointIds.map((e) => e.toString()).toList();
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

    return ids
        .map((id) => pointsById[id])
        .whereType<PointOfInterest>()
        .toList();
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

}
