/*
  -----------------------------------------------------------------------------
  Proyecto: RuteX Go
  Desarrollado por: TurisTechTeam
  Descripción: Esta aplicación y su código fuente son propiedad intelectual de
  TurisTechTeam. Queda prohibida su copia, distribución o uso no autorizado.
  Año: 2026
  -----------------------------------------------------------------------------
*/
import 'package:latlong2/latlong.dart';

import '../../../domain/entities/poi_entity.dart';
import 'navigation_distance_utils.dart';

class RouteTargetSelector {
  const RouteTargetSelector._();

  static int nearestPendingPoiIndex({
    required List<PointOfInterest> pointsOfInterest,
    required List<int> completedPoiIndices,
    required LatLng currentPosition,
  }) {
    if (pointsOfInterest.isEmpty) return -1;

    final pendingIndexes = <int>[];
    for (var index = 0; index < pointsOfInterest.length; index++) {
      if (!completedPoiIndices.contains(index)) {
        pendingIndexes.add(index);
      }
    }

    if (pendingIndexes.isEmpty) return -1;

    pendingIndexes.sort((a, b) {
      final distanceA = NavigationDistanceUtils.metersBetween(
        currentPosition,
        pointsOfInterest[a].location,
      );
      final distanceB = NavigationDistanceUtils.metersBetween(
        currentPosition,
        pointsOfInterest[b].location,
      );
      return distanceA.compareTo(distanceB);
    });

    return pendingIndexes.first;
  }
}
