import '../../../core/constants/firestore_contract.dart';
import 'home_data.dart';

class HomeSummary {
  final String rankName;
  final String rankLogo;
  final int completedRoutes;
  final int completedMissions;
  final int totalMissions;
  final int totalPoints;

  const HomeSummary({
    required this.rankName,
    required this.rankLogo,
    required this.completedRoutes,
    required this.completedMissions,
    required this.totalMissions,
    required this.totalPoints,
  });

  factory HomeSummary.fromHomeData(HomeData data) {
    final totalPoints = _sumRouteValue(
      data.routes,
      CompletedRouteFields.puntosObtenidos,
    );
    final rank = _rankForPoints(totalPoints, data.rangos);

    return HomeSummary(
      rankName: rank.name,
      rankLogo: rank.logo,
      completedRoutes: data.routes.length,
      completedMissions: _sumRouteValue(
        data.routes,
        CompletedRouteFields.misionesCompletadas,
      ),
      totalMissions: _sumRouteValue(data.routes, "misiones_totales"),
      totalPoints: totalPoints,
    );
  }

  static _RankSummary _rankForPoints(int points, List<dynamic> ranks) {
    String name = "Esclavo";
    String logo = "";
    int maxPoints = -1;

    for (final rank in ranks) {
      if (rank is! Map) continue;

      final neededPoints = _asInt(rank[RankFields.puntosNecesarios]);
      if (points >= neededPoints && neededPoints > maxPoints) {
        maxPoints = neededPoints;
        name = rank[RankFields.nombre]?.toString() ?? name;
        logo = rank[RankFields.logo]?.toString() ?? logo;
      }
    }

    return _RankSummary(name: name, logo: logo);
  }

  static int _sumRouteValue(List<HomeRouteData> routes, String key) {
    var total = 0;

    for (final route in routes) {
      total += switch (key) {
        CompletedRouteFields.puntosObtenidos => route.obtainedPoints,
        CompletedRouteFields.misionesCompletadas => route.completedMissions,
        "misiones_totales" => route.totalMissions,
        _ => 0,
      };
    }

    return total;
  }

  static int _asInt(dynamic value, [int defaultValue = 0]) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;

    return defaultValue;
  }
}

class _RankSummary {
  final String name;
  final String logo;

  const _RankSummary({required this.name, required this.logo});
}
