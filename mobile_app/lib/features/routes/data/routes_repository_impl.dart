import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/firestore_contract.dart';
import '../domain/repository/routes_repository.dart';

class RoutesRepositoryImpl implements RoutesRepository {
  static const int _firestoreWhereInLimit = 10;

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Stream<QuerySnapshot> getCiudades() {
    return _db.collection(FirestoreCollections.ciudades).snapshots();
  }

  @override
  Stream<QuerySnapshot> getRutas() {
    return _db.collection(FirestoreCollections.rutas).snapshots();
  }

  @override
  Stream<QuerySnapshot> getRutasByCiudad(String idCiudad) {
    return _db
        .collection(FirestoreCollections.rutas)
        .where(RouteFields.idCiudad, isEqualTo: idCiudad)
        .snapshots();
  }

  @override
  Future<Set<String>> getPointIdsWithMission(List<String> pointIds) async {
    if (pointIds.isEmpty) return <String>{};

    final pointIdsWithMission = <String>{};

    for (var i = 0; i < pointIds.length; i += _firestoreWhereInLimit) {
      final chunk = pointIds.skip(i).take(_firestoreWhereInLimit).toList();
      final snapshot = await _db
          .collection(FirestoreCollections.misiones)
          .where(MissionFields.puntosInteresId, whereIn: chunk)
          .get();

      for (final doc in snapshot.docs) {
        final pointId = doc.data()[MissionFields.puntosInteresId]?.toString();
        if (pointId != null && pointId.isNotEmpty) {
          pointIdsWithMission.add(pointId);
        }
      }
    }

    return pointIdsWithMission;
  }
}
