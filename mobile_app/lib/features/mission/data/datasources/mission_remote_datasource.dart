import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_contract.dart';

class MissionRemoteDataSource {
  final FirebaseFirestore firestore;

  const MissionRemoteDataSource(this.firestore);

  Future<QuerySnapshot<Map<String, dynamic>>> getPointByQr(String qrCode) {
    return firestore
        .collection(FirestoreCollections.puntosInteres)
        .where(PointInterestFields.qrCode, isEqualTo: qrCode)
        .limit(1)
        .get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getMissionByPointId(
    String pointId,
  ) {
    return firestore
        .collection(FirestoreCollections.misiones)
        .where(MissionFields.puntosInteresId, isEqualTo: pointId)
        .limit(1)
        .get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getMissionBySingularPointId(
    String pointId,
  ) {
    return firestore
        .collection(FirestoreCollections.misiones)
        .where(MissionFields.puntoInteresId, isEqualTo: pointId)
        .limit(1)
        .get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getMissionByPointRef(
    String pointId,
  ) {
    final pointRef = firestore
        .collection(FirestoreCollections.puntosInteres)
        .doc(pointId.trim());

    return firestore
        .collection(FirestoreCollections.misiones)
        .where(MissionFields.puntosInteresId, isEqualTo: pointRef)
        .limit(1)
        .get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getMissionBySingularPointRef(
    String pointId,
  ) {
    final pointRef = firestore
        .collection(FirestoreCollections.puntosInteres)
        .doc(pointId.trim());

    return firestore
        .collection(FirestoreCollections.misiones)
        .where(MissionFields.puntoInteresId, isEqualTo: pointRef)
        .limit(1)
        .get();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getRouteById(String routeId) {
    return firestore
        .collection(FirestoreCollections.rutas)
        .doc(routeId.trim())
        .get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getPointsByIds(
    List<String> pointIds,
  ) {
    return firestore
        .collection(FirestoreCollections.puntosInteres)
        .where(FieldPath.documentId, whereIn: pointIds)
        .get();
  }
}
