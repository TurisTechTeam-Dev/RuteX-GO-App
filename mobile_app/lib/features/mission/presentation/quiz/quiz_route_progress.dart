class QuizRouteProgress {
  static int visitedMonuments = 0;
  static int routePoints = 0;
  static String? activeRouteId;

  static void ensureRoute(String? routeId) {
    if (routeId == null || routeId == activeRouteId) return;

    activeRouteId = routeId;
    visitedMonuments = 0;
    routePoints = 0;
  }

  static void addMissionPoints(int points) {
    visitedMonuments++;
    routePoints += points;
  }

  static void reset() {
    visitedMonuments = 0;
    routePoints = 0;
    activeRouteId = null;
  }
}
