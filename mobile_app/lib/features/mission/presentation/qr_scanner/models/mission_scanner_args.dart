/*
  -----------------------------------------------------------------------------
  Proyecto: RuteX Go
  Desarrollado por: TurisTechTeam
  Descripción: Esta aplicación y su código fuente son propiedad intelectual de
  TurisTechTeam. Queda prohibida su copia, distribución o uso no autorizado.
  Año: 2026
  -----------------------------------------------------------------------------
*/
class MissionScannerArgs {
  final String? routeId;
  final int? totalPois;
  final String? expectedPointId;
  final String? expectedPointName;

  const MissionScannerArgs({
    this.routeId,
    this.totalPois,
    this.expectedPointId,
    this.expectedPointName,
  });
}
