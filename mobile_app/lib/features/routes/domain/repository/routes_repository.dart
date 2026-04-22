import 'package:cloud_firestore/cloud_firestore.dart';

abstract class RoutesRepository {
  Stream<QuerySnapshot> getCiudades();
  Stream<QuerySnapshot> getRutas();
  Stream<QuerySnapshot> getRutasByCiudad(String idCiudad);
  Future<Set<String>> getPointIdsWithMission(List<String> pointIds);
}
