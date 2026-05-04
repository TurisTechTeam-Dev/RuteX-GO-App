/*
  -----------------------------------------------------------------------------
  Proyecto: RuteX Go
  Desarrollado por: TurisTechTeam
  Descripción: Esta aplicación y su código fuente son propiedad intelectual de
  TurisTechTeam. Queda prohibida su copia, distribución o uso no autorizado.
  Año: 2026
  -----------------------------------------------------------------------------
*/
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
