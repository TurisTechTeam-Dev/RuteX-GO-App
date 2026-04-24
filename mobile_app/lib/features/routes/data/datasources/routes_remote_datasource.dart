import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_contract.dart';

class RoutesRemoteDataSource {
  final FirebaseFirestore firestore;

  const RoutesRemoteDataSource(this.firestore);

  Stream<QuerySnapshot> watchCities() {
    return firestore.collection(FirestoreCollections.ciudades).snapshots();
  }

  Stream<QuerySnapshot> watchRoutes() {
    return firestore.collection(FirestoreCollections.rutas).snapshots();
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
