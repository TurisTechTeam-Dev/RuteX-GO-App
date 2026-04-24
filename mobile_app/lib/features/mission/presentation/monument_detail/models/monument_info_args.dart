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
