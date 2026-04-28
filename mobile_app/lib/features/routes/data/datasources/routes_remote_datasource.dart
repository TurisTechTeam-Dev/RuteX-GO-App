import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_contract.dart';

class RoutesRemoteDataSource {
  final FirebaseFirestore firestore;

  const RoutesRemoteDataSource(this.firestore);

  Stream<QuerySnapshot<Map<String, dynamic>>> watchCities() {
    return firestore.collection(FirestoreCollections.ciudades).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchRoutes() {
    return firestore.collection(FirestoreCollections.rutas).snapshots();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getPointsByIds(
    List<String> pointIds,
  ) {
    return firestore
        .collection(FirestoreCollections.puntosInteres)
        .where(FieldPath.documentId, whereIn: pointIds)
        .get();
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
    final pointRefs = _pointRefsFromIds(pointIds);

    return firestore
        .collection(FirestoreCollections.misiones)
        .where(MissionFields.puntosInteresId, whereIn: pointRefs)
        .get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getMissionsBySingularPointRefs(
    List<String> pointIds,
  ) {
    final pointRefs = _pointRefsFromIds(pointIds);

    return firestore
        .collection(FirestoreCollections.misiones)
        .where(MissionFields.puntoInteresId, whereIn: pointRefs)
        .get();
  }

  List<DocumentReference<Map<String, dynamic>>> _pointRefsFromIds(
    List<String> pointIds,
  ) {
    final pointRefs = <DocumentReference<Map<String, dynamic>>>[];

    for (final pointId in pointIds) {
      pointRefs.add(
        firestore
            .collection(FirestoreCollections.puntosInteres)
            .doc(pointId.trim()),
      );
    }

    return pointRefs;
  }
}
