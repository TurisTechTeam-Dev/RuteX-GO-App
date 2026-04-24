import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_contract.dart';

class ProfileRemoteDataSource {
  final FirebaseFirestore firestore;
  static const int _firestoreWhereInLimit = 10;

  ProfileRemoteDataSource(this.firestore);

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDoc(String uid) {
    return firestore.collection(FirestoreCollections.usuarios).doc(uid).get();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getRanksConfigDoc() {
    return firestore
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
      final query = await firestore
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
    return firestore.collection(FirestoreCollections.usuarios).doc(uid).update({
      UserFields.rutasCompletadas: routesProgress,
      UserFields.puntos: points,
    });
  }
}
