import 'home_route_result.dart';

class HomeRoute {
  final String id;
  final String name;
  final int totalPoints;
  final List<String> pointIds;
  final int totalMissions;
  final int obtainedPoints;
  final int completedMissions;
  final HomeRouteResult? result;

  const HomeRoute({
    required this.id,
    required this.name,
    required this.totalPoints,
    required this.pointIds,
    required this.totalMissions,
    required this.obtainedPoints,
    required this.completedMissions,
    this.result,
  });
}
