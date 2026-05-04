/*
  -----------------------------------------------------------------------------
  Proyecto: RuteX Go
  Desarrollado por: TurisTechTeam
  Descripción: Esta aplicación y su código fuente son propiedad intelectual de
  TurisTechTeam. Queda prohibida su copia, distribución o uso no autorizado.
  Año: 2026
  -----------------------------------------------------------------------------
*/
import '../../../domain/entities/mission_scan_result.dart';

class MonumentInfoArgs {
  final MissionScanResult scanResult;
  final String? routeId;
  final int? totalPois;

  const MonumentInfoArgs({
    required this.scanResult,
    this.routeId,
    this.totalPois,
  });
}
