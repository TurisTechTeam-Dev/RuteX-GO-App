/*
  -----------------------------------------------------------------------------
  Proyecto: RuteX Go
  Desarrollado por: TurisTechTeam
  Descripción: Esta aplicación y su código fuente son propiedad intelectual de
  TurisTechTeam. Queda prohibida su copia, distribución o uso no autorizado.
  Año: 2026
  -----------------------------------------------------------------------------
*/
import 'mission.dart';
import 'poi_entity.dart';

class MissionScanResult {
  final PointOfInterest point;
  final Mission mission;

  const MissionScanResult({required this.point, required this.mission});
}
