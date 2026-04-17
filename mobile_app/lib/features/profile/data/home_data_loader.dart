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

    final userDoc = await firestore
        .collection(FirestoreCollections.usuarios)
        .doc(uid)
        .get();

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

    return HomeData(user: userData, routes: rutas, rangos: rangos);
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
