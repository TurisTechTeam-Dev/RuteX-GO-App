import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_contract.dart';

class ProfileRemoteDatasource {
  final FirebaseFirestore db;
  static const int _firestoreWhereInLimit = 10;

  ProfileRemoteDatasource(this.db);

  Future<Map<String, dynamic>> getUserProfile(String uid) async {
    final docSnapShot = await db
        .collection(FirestoreCollections.usuarios)
        .doc(uid)
        .get();

    return docSnapShot.data()!;
  }

  Future<List<Map<String, dynamic>>> getCompletedRoutes(String uid) async {
    final querySnapShot = await db
        .collection(FirestoreCollections.resultado)
        .where(ResultFields.idUsuario, isEqualTo: uid)
        .get();

    return querySnapShot.docs.map((doc) => doc.data()).toList();
  }

  Future<Map<String, dynamic>> getRankConfig(String rankId) async {
    final docSnapShot = await db
        .collection(FirestoreCollections.configRangos)
        .doc(rankId)
        .get();

    return docSnapShot.data()!;
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDoc(String uid) {
    return db.collection(FirestoreCollections.usuarios).doc(uid).get();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getRanksConfigDoc() {
    return db
        .collection(FirestoreCollections.configRangos)
        .doc(FirestoreDocs.rangosConfig)
        .get();
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getRoutesByIds(
    List<String> ids,
  ) async {
    if (ids.isEmpty) return [];

    final docsById = <String, QueryDocumentSnapshot<Map<String, dynamic>>>{};

    for (var i = 0; i < ids.length; i += _firestoreWhereInLimit) {
      final chunk = ids.skip(i).take(_firestoreWhereInLimit).toList();
      final query = await db
          .collection(FirestoreCollections.rutas)
          .where(FieldPath.documentId, whereIn: chunk)
          .get();

      for (final doc in query.docs) {
        docsById[doc.id] = doc;
      }
    }

    return ids
        .map((id) => docsById[id])
        .whereType<QueryDocumentSnapshot<Map<String, dynamic>>>()
        .toList();
  }

  Future<void> updateUserHomeProgress({
    required String uid,
    required List<dynamic> routesProgress,
    required int points,
  }) {
    return db.collection(FirestoreCollections.usuarios).doc(uid).update({
      UserFields.rutasCompletadas: routesProgress,
      UserFields.puntos: points,
    });
  }
}
