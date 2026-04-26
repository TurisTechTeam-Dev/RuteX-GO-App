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

  Future<QuerySnapshot<Map<String, dynamic>>> getMissionsBySingularPointIds(
    List<String> pointIds,
  ) {
    return firestore
        .collection(FirestoreCollections.misiones)
        .where(MissionFields.puntoInteresId, whereIn: pointIds)
        .get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getMissionsByPointRefs(
    List<String> pointIds,
  ) {
    final pointRefs = pointIds
        .map(
          (pointId) => firestore
              .collection(FirestoreCollections.puntosInteres)
              .doc(pointId.trim()),
        )
        .toList();

    return firestore
        .collection(FirestoreCollections.misiones)
        .where(MissionFields.puntosInteresId, whereIn: pointRefs)
        .get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getMissionsBySingularPointRefs(
    List<String> pointIds,
  ) {
    final pointRefs = pointIds
        .map(
          (pointId) => firestore
              .collection(FirestoreCollections.puntosInteres)
              .doc(pointId.trim()),
        )
        .toList();

    return firestore
        .collection(FirestoreCollections.misiones)
        .where(MissionFields.puntoInteresId, whereIn: pointRefs)
        .get();
  }
}
