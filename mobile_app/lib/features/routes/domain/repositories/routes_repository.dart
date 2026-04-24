import 'package:cloud_firestore/cloud_firestore.dart';

abstract class RoutesRepository {
  Stream<QuerySnapshot> getCities();
  Stream<QuerySnapshot> getRoutes();
  Stream<QuerySnapshot> getRoutesByCity(String cityId);
  Future<Set<String>> getPointIdsWithMission(List<String> pointIds);
}
