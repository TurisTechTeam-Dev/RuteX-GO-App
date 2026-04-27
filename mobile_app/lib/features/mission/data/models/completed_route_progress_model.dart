import '../../../../core/constants/firestore_contract.dart';
import '../../domain/entities/poi_entity.dart';

class CompletedRouteProgressMatch {
  final int index;
  final int previousBestPoints;

  const CompletedRouteProgressMatch({
    required this.index,
    required this.previousBestPoints,
  });

  bool get exists => index != -1;

  static const empty = CompletedRouteProgressMatch(
    index: -1,
    previousBestPoints: 0,
  );
}

class CompletedRouteProgressModel {
  const CompletedRouteProgressModel._();

  static CompletedRouteProgressMatch findMatch({
    required List<dynamic> completedRoutes,
    required String routeId,
  }) {
    for (var index = 0; index < completedRoutes.length; index++) {
      final route = completedRoutes[index];

      if (route is String && route == routeId) {
        return CompletedRouteProgressMatch(index: index, previousBestPoints: 0);
      }

      if (route is Map) {
        final savedRouteId =
            route[CompletedRouteFields.rutaId] ??
            route[CompletedRouteFields.idRuta] ??
            route[CompletedRouteFields.routeId];

        if (savedRouteId?.toString() == routeId) {
          return CompletedRouteProgressMatch(
            index: index,
            previousBestPoints: _asInt(
              route[CompletedRouteFields.puntosObtenidos] ??
                  route[CompletedRouteFields.puntos],
            ),
          );
        }
      }
    }

    return CompletedRouteProgressMatch.empty;
  }

  static Map<String, dynamic> toFirestore({
    required String routeId,
    required int currentAttemptPoints,
    required int visitedPois,
    required int completedMissions,
    required List<PointOfInterest> skippedPois,
  }) {
    return {
      CompletedRouteFields.rutaId: routeId,
      CompletedRouteFields.puntosObtenidos: currentAttemptPoints,
      CompletedRouteFields.monumentosVisitados: visitedPois,
      CompletedRouteFields.misionesCompletadas: completedMissions,
      CompletedRouteFields.puntosInteresSaltados: _skippedPoisToFirestore(
        skippedPois,
      ),
    };
  }

  static List<Map<String, String>> _skippedPoisToFirestore(
    List<PointOfInterest> skippedPois,
  ) {
    final skippedPoiMaps = <Map<String, String>>[];

    for (final poi in skippedPois) {
      skippedPoiMaps.add({'id': poi.id, 'nombre': poi.name});
    }

    return skippedPoiMaps;
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;

    return 0;
  }
}
