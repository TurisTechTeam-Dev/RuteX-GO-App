import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_contract.dart';

class ProfileRemoteDatasource {
  final FirebaseFirestore db;

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
}
