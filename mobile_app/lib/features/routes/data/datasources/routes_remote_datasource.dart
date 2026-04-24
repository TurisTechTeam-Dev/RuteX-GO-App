import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_contract.dart';

class RoutesRemoteDatasource {
  final FirebaseFirestore firestore;

  const RoutesRemoteDatasource(this.firestore);

  Stream<QuerySnapshot> watchCities() {
    return firestore.collection(FirestoreCollections.ciudades).snapshots();
  }

  Stream<QuerySnapshot> watchRoutes() {
    return firestore.collection(FirestoreCollections.rutas).snapshots();
  }

  Stream<QuerySnapshot> watchRoutesByCity(String cityId) {
    return firestore
        .collection(FirestoreCollections.rutas)
        .where(RouteFields.idCiudad, isEqualTo: cityId)
        .snapshots();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getMissionsByPointIds(
    List<String> pointIds,
  ) {
    return firestore
        .collection(FirestoreCollections.misiones)
        .where(MissionFields.puntosInteresId, whereIn: pointIds)
        .get();
  }
}
