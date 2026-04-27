import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/firestore_contract.dart';
import '../domain/entities/home_data.dart';
import '../domain/entities/home_route.dart';
import '../domain/entities/profile_rank.dart';
import '../domain/entities/user_profile.dart';
import 'datasources/profile_remote_datasource.dart';

class HomeDataLoader {
  final ProfileRemoteDataSource remoteDataSource;

  const HomeDataLoader(this.remoteDataSource);

  Future<HomeData> load(String uid) async {
    final userDoc = await remoteDataSource.getUserDoc(uid);
    final userData = userDoc.data() ?? {};

    final ranksDoc = await remoteDataSource.getRanksConfigDoc();
    final ranks = _parseRanks(ranksDoc.data()?[RankFields.rangos]);

    final routesProgress = List<dynamic>.from(
      userData[UserFields.rutasCompletadas] ?? [],
    );

    final routeIds = _routeIdsFromProgress(routesProgress);

    final routes = <HomeRoute>[];
    final routeDocs = await remoteDataSource.getRoutesByIds(routeIds);
    final validRouteIds = _routeIdsFromDocs(routeDocs);
    final normalizedRoutesProgress = _filterValidRoutesProgress(
      routesProgress,
      validRouteIds,
    );
    final orphanedPoints = _sumRemovedRoutePoints(
      routesProgress,
      validRouteIds,
    );

    for (final doc in routeDocs) {
      final data = doc.data();
      final rawPointIds = List<dynamic>.from(
        data[RouteFields.idPuntosInteres] ?? [],
      );
      final pointIds = _pointIdsFromRouteData(rawPointIds);
      final totalMissions = pointIds.length;
      final totalPoints = _asInt(
        data[RouteFields.puntosTotales],
        defaultValue: _routeTotalPoints(totalMissions),
      );

      final progress = _progressMapForRoute(routesProgress, doc.id);
      final hasDetailedProgress = progress.isNotEmpty;

      final obtainedPoints = _asInt(
        progress[CompletedRouteFields.puntosObtenidos] ??
            progress[CompletedRouteFields.puntos],
        defaultValue: hasDetailedProgress ? 0 : totalPoints,
      );
      final completedMissions = _asInt(
        progress[CompletedRouteFields.misionesCompletadas] ??
            progress[CompletedRouteFields.monumentosVisitados],
        defaultValue: totalMissions,
      );

      routes.add(
        HomeRoute(
          id: doc.id,
          name: data[RouteFields.nombre]?.toString() ?? "Ruta",
          totalPoints: totalPoints,
          pointIds: pointIds,
          totalMissions: totalMissions,
          obtainedPoints: obtainedPoints,
          completedMissions: completedMissions,
        ),
      );
    }

    var totalUserPoints = _asInt(userData[UserFields.puntos]);
    final hasOrphanedRoutes =
        normalizedRoutesProgress.length != routesProgress.length;

    if (orphanedPoints > 0 || hasOrphanedRoutes) {
      totalUserPoints = (totalUserPoints - orphanedPoints).clamp(0, 1 << 31);

      await remoteDataSource.updateUserHomeProgress(
        uid: uid,
        routesProgress: normalizedRoutesProgress,
        points: totalUserPoints,
      );
    }

    return HomeData(
      user: _parseUser(userData, uid, totalUserPoints),
      routes: routes,
      ranks: ranks,
    );
  }

  static UserProfile _parseUser(
    Map<String, dynamic> data,
    String uid,
    int points,
  ) {
    return UserProfile(
      uid: data[UserFields.uid]?.toString() ?? uid,
      name: data[UserFields.nombre]?.toString() ?? 'Sin nombre',
      username: data[UserFields.usuario]?.toString() ?? '',
      email: data[UserFields.email]?.toString() ?? '',
      avatarUrl: data[UserFields.avatar]?.toString() ?? '',
      points: points,
      createdAt: _dateFromFirestoreValue(data[UserFields.fechaCreacion]),
    );
  }

  static List<ProfileRank> _parseRanks(dynamic rawRanks) {
    if (rawRanks is! List) return const [];

    final ranks = <ProfileRank>[];

    for (final rawRank in rawRanks) {
      if (rawRank is Map) {
        ranks.add(
          ProfileRank(
            name: rawRank[RankFields.nombre]?.toString() ?? '',
            logo: rawRank[RankFields.logo]?.toString() ?? '',
            neededPoints: _asInt(rawRank[RankFields.puntosNecesarios]),
          ),
        );
      }
    }

    return ranks;
  }

  static DateTime? _dateFromFirestoreValue(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;

    return null;
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
    final validRoutesProgress = <dynamic>[];

    for (final progress in routesProgress) {
      final routeId = _routeIdFromProgress(progress);
      if (routeId == null || routeId.isEmpty) continue;

      if (validRouteIds.contains(routeId)) {
        validRoutesProgress.add(progress);
      }
    }

    return validRoutesProgress;
  }

  static List<String> _routeIdsFromProgress(List<dynamic> routesProgress) {
    final routeIds = <String>{};

    for (final progress in routesProgress) {
      final routeId = _routeIdFromProgress(progress);

      if (routeId != null) {
        routeIds.add(routeId);
      }
    }

    return routeIds.toList();
  }

  static List<String> _pointIdsFromRouteData(List<dynamic> rawPointIds) {
    final pointIds = <String>[];

    for (final rawPointId in rawPointIds) {
      pointIds.add(rawPointId.toString());
    }

    return pointIds;
  }

  static Set<String> _routeIdsFromDocs(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> routeDocs,
  ) {
    final routeIds = <String>{};

    for (final doc in routeDocs) {
      routeIds.add(doc.id);
    }

    return routeIds;
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
