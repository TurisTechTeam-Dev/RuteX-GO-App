class HomeData {
  final Map<String, dynamic> user;
  final List<HomeRouteData> routes;
  final List<dynamic> rangos;

  HomeData({required this.user, required this.routes, required this.rangos});
}

class HomeRouteData {
  final String id;
  final String name;
  final int totalPoints;
  final List<dynamic> pointsOfInterest;
  final int totalMissions;
  final int obtainedPoints;
  final int completedMissions;

  const HomeRouteData({
    required this.id,
    required this.name,
    required this.totalPoints,
    required this.pointsOfInterest,
    required this.totalMissions,
    required this.obtainedPoints,
    required this.completedMissions,
  });
}
