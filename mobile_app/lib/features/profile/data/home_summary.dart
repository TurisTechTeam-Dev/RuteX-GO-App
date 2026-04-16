import 'home_data.dart';

class HomeSummary {
  final String rankName;
  final int completedRoutes;
  final int completedMissions;
  final int totalMissions;
  final int totalPoints;

  const HomeSummary({
    required this.rankName,
    required this.completedRoutes,
    required this.completedMissions,
    required this.totalMissions,
    required this.totalPoints,
  });

  factory HomeSummary.fromHomeData(HomeData data) {
    final totalPoints = _sumRouteValue(data.routes, "puntos_obtenidos");

    return HomeSummary(
      rankName: _rankName(totalPoints, data.rangos),
      completedRoutes: data.routes.length,
      completedMissions: _sumRouteValue(
        data.routes,
        "misiones_completadas",
      ),
      totalMissions: _sumRouteValue(data.routes, "misiones_totales"),
      totalPoints: totalPoints,
    );
  }

  static String _rankName(int points, List<dynamic> ranks) {
    String name = "Esclavo";
    int maxPoints = -1;

    for (final rank in ranks) {
      if (rank is! Map) continue;

      final neededPoints = _asInt(rank['puntos_necesarios']);
      if (points >= neededPoints && neededPoints > maxPoints) {
        maxPoints = neededPoints;
        name = rank['nombre']?.toString() ?? name;
      }
    }

    return name;
  }

  static int _sumRouteValue(List<HomeRouteData> routes, String key) {
    var total = 0;

    for (final route in routes) {
      total += switch (key) {
        "puntos_obtenidos" => route.obtainedPoints,
        "misiones_completadas" => route.completedMissions,
        "misiones_totales" => route.totalMissions,
        _ => 0,
      };
    }

    return total;
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;

    return 0;
  }
}
