/*
  -----------------------------------------------------------------------------
  Proyecto: RuteX Go
  Desarrollado por: TurisTechTeam
  Descripción: Esta aplicación y su código fuente son propiedad intelectual de
  TurisTechTeam. Queda prohibida su copia, distribución o uso no autorizado.
  Año: 2026
  -----------------------------------------------------------------------------
*/
class TouristRoute {
  final String id;
  final String cityId;
  final String title;
  final String description;
  final String difficulty;
  final String time;
  final List<String> pointIds;
  final int totalPois;
  final int totalPoints;
  final String image;

  const TouristRoute({
    required this.id,
    required this.cityId,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.time,
    required this.pointIds,
    required this.totalPois,
    required this.totalPoints,
    required this.image,
  });

  String get pointsLabel => "$totalPoints puntos";
}
