/*
  -----------------------------------------------------------------------------
  Proyecto: RuteX Go
  Desarrollado por: TurisTechTeam
  Descripción: Esta aplicación y su código fuente son propiedad intelectual de
  TurisTechTeam. Queda prohibida su copia, distribución o uso no autorizado.
  Año: 2026
  -----------------------------------------------------------------------------
*/
import '../../domain/entities/home_data.dart';
import '../../domain/entities/home_route.dart';
import '../../domain/entities/profile_rank.dart';

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
    final totalPoints = data.user.points;
    final rank = _rankForPoints(totalPoints, data.ranks);

    return HomeSummary(
      rankName: rank.name,
      rankLogo: rank.logo,
      completedRoutes: data.routes.length,
      completedMissions: _completedMissions(data.routes),
      totalMissions: _totalMissions(data.routes),
      totalPoints: totalPoints,
    );
  }

  static _RankSummary _rankForPoints(int points, List<ProfileRank> ranks) {
    String name = "Esclavo";
    String logo = "";
    int maxPoints = -1;

    for (final rank in ranks) {
      final neededPoints = rank.neededPoints;
      if (points >= neededPoints && neededPoints > maxPoints) {
        maxPoints = neededPoints;
        name = rank.name.isNotEmpty ? rank.name : name;
        logo = rank.logo.isNotEmpty ? rank.logo : logo;
      }
    }

    return _RankSummary(name: name, logo: logo);
  }

  static int _completedMissions(List<HomeRoute> routes) {
    var total = 0;

    for (final route in routes) {
      total += route.completedMissions;
    }

    return total;
  }

  static int _totalMissions(List<HomeRoute> routes) {
    var total = 0;

    for (final route in routes) {
      total += route.totalMissions;
    }

    return total;
  }
}

class _RankSummary {
  final String name;
  final String logo;

  const _RankSummary({required this.name, required this.logo});
}
