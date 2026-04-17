class QuizRouteProgress {
  static int visitedMonuments = 0;
  static int routePoints = 0;
  static String? activeRouteId;
  static final Set<String> visitedPointIds = <String>{};

  static void ensureRoute(String? routeId) {
    if (routeId == null || routeId == activeRouteId) return;

    activeRouteId = routeId;
    visitedMonuments = 0;
    routePoints = 0;
    visitedPointIds.clear();
  }

  static bool hasVisitedPoint(String? pointId) {
    if (pointId == null || pointId.isEmpty) return false;
    return visitedPointIds.contains(pointId);
  }

  static bool addMonumentResult({
    required String? pointId,
    required int points,
  }) {
    if (pointId != null && pointId.isNotEmpty) {
      if (visitedPointIds.contains(pointId)) return false;
      visitedPointIds.add(pointId);
    }

    visitedMonuments++;
    routePoints += points;

    return true;
  }

  static int pointsWithCompletionBonus(int bonus) {
    return routePoints + bonus;
  }

  static void reset() {
    visitedMonuments = 0;
    routePoints = 0;
    activeRouteId = null;
    visitedPointIds.clear();
  }
}
