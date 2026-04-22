import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/constants/firestore_contract.dart';
import 'home_data.dart';

class HomeDataLoader {
  static const int _firestoreWhereInLimit = 10;

  const HomeDataLoader();

  Future<HomeData> load() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final firestore = FirebaseFirestore.instance;
    final userRef = firestore
        .collection(FirestoreCollections.usuarios)
        .doc(uid);

    final userDoc = await userRef.get();

    final userData = userDoc.data() ?? {};

    final rangosDoc = await firestore
        .collection(FirestoreCollections.configRangos)
        .doc(FirestoreDocs.rangosConfig)
        .get();

    final rangos = rangosDoc.data()?[RankFields.rangos] ?? [];

    final rutasProgreso = List<dynamic>.from(
      userData[UserFields.rutasCompletadas] ?? [],
    );

    var rutasIds = rutasProgreso
        .map(_routeIdFromProgress)
        .whereType<String>()
        .toList();

    rutasIds = rutasIds.toSet().toList();

    final rutas = <HomeRouteData>[];
    final rutasDocs = await _loadRoutesByIds(firestore, rutasIds);
    final validRouteIds = rutasDocs.map((doc) => doc.id).toSet();
    final normalizedRoutesProgress = _filterValidRoutesProgress(
      rutasProgreso,
      validRouteIds,
    );
    final orphanedPoints = _sumRemovedRoutePoints(
      rutasProgreso,
      validRouteIds,
    );

    for (final doc in rutasDocs) {
      final data = doc.data();
      final puntosInteres = List<dynamic>.from(
        data[RouteFields.idPuntosInteres] ?? [],
      );
      final misionesTotales = puntosInteres.length;
      final puntosTotales = _asInt(
        data[RouteFields.puntosTotales],
        defaultValue: _routeTotalPoints(misionesTotales),
      );

      final progreso = _progressMapForRoute(rutasProgreso, doc.id);
      final hasDetailedProgress = progreso.isNotEmpty;

      final puntosObtenidos = _asInt(
        progreso[CompletedRouteFields.puntosObtenidos] ??
            progreso[CompletedRouteFields.puntos],
        defaultValue: hasDetailedProgress ? 0 : puntosTotales,
      );
      final misionesCompletadas = _asInt(
        progreso[CompletedRouteFields.misionesCompletadas] ??
            progreso[CompletedRouteFields.monumentosVisitados],
        defaultValue: misionesTotales,
      );

      rutas.add(
        HomeRouteData(
          id: doc.id,
          name: data[RouteFields.nombre]?.toString() ?? "Ruta",
          totalPoints: puntosTotales,
          pointsOfInterest: puntosInteres,
          totalMissions: misionesTotales,
          obtainedPoints: puntosObtenidos,
          completedMissions: misionesCompletadas,
        ),
      );
    }

    final normalizedUserData = Map<String, dynamic>.from(userData);
    normalizedUserData[UserFields.rutasCompletadas] = normalizedRoutesProgress;

    final hasOrphanedRoutes =
        normalizedRoutesProgress.length != rutasProgreso.length;

    if (orphanedPoints > 0 || hasOrphanedRoutes) {
      final currentPoints = _asInt(userData[UserFields.puntos]);
      final updatedPoints = (currentPoints - orphanedPoints).clamp(0, 1 << 31)
          as int;
      normalizedUserData[UserFields.puntos] = updatedPoints;

      await userRef.update({
        UserFields.rutasCompletadas: normalizedRoutesProgress,
        UserFields.puntos: updatedPoints,
      });
    }

    return HomeData(user: normalizedUserData, routes: rutas, rangos: rangos);
  }

  static Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
  _loadRoutesByIds(FirebaseFirestore firestore, List<String> ids) async {
    if (ids.isEmpty) return [];

    final docsById = <String, QueryDocumentSnapshot<Map<String, dynamic>>>{};

    for (var i = 0; i < ids.length; i += _firestoreWhereInLimit) {
      final chunk = ids.skip(i).take(_firestoreWhereInLimit).toList();
      final query = await firestore
          .collection(FirestoreCollections.rutas)
          .where(FieldPath.documentId, whereIn: chunk)
          .get();

      for (final doc in query.docs) {
        docsById[doc.id] = doc;
      }
    }

    return ids
        .map((id) => docsById[id])
        .whereType<QueryDocumentSnapshot<Map<String, dynamic>>>()
        .toList();
  }

  static String? _routeIdFromProgress(dynamic progress) {
    if (progress is String) return progress;

    if (progress is Map) {
      final routeId =
          progress[CompletedRouteFields.rutaId] ??
          progress[CompletedRouteFields.idRuta] ??
          progress[CompletedRouteFields.routeId];
      return routeId?.toString();
    }

    return null;
  }

  static List<dynamic> _filterValidRoutesProgress(
    List<dynamic> routesProgress,
    Set<String> validRouteIds,
  ) {
    return routesProgress.where((progress) {
      final routeId = _routeIdFromProgress(progress);
      if (routeId == null || routeId.isEmpty) return false;
      return validRouteIds.contains(routeId);
    }).toList();
  }

  static int _sumRemovedRoutePoints(
    List<dynamic> routesProgress,
    Set<String> validRouteIds,
  ) {
    var total = 0;

    for (final progress in routesProgress) {
      final routeId = _routeIdFromProgress(progress);
      if (routeId == null || routeId.isEmpty) continue;
      if (validRouteIds.contains(routeId)) continue;

      if (progress is Map) {
        total += _asInt(
          progress[CompletedRouteFields.puntosObtenidos] ??
              progress[CompletedRouteFields.puntos],
        );
      }
    }

    return total;
  }

  static Map<String, dynamic> _progressMapForRoute(
    List<dynamic> routesProgress,
    String routeId,
  ) {
    for (final progress in routesProgress) {
      if (progress is Map && _routeIdFromProgress(progress) == routeId) {
        return Map<String, dynamic>.from(progress);
      }
    }

    return {};
  }

  static int _asInt(dynamic value, {int defaultValue = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;

    return defaultValue;
  }

  static int _routeTotalPoints(int totalStops) {
    if (totalStops <= 0) return 0;
    return (totalStops * 30) + 10;
  }
}
