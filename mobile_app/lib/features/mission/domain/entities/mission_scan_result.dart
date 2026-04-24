import 'mission.dart';
import 'poi_entity.dart';

class MissionScanResult {
  final PointOfInterest point;
  final Mission mission;

  const MissionScanResult({required this.point, required this.mission});
}
