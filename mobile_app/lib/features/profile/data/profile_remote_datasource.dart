import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileRemoteDatasource {
  final FirebaseFirestore firestore;

  ProfileRemoteDatasource(this.firestore);

  Future<Map<String, dynamic>> getUserProfile(String uid) async {
    final docSnapShot = await firestore.collection("usuarios").doc(uid).get();

    return docSnapShot.data()!;
  }

  Future<List<Map<String, dynamic>>> getCompletedRoutes(String uid) async {
    final querySnapShot = await firestore
        .collection("resultado")
        .where("id_usuario", isEqualTo: uid)
        .get();

    return querySnapShot.docs.map((doc) => doc.data()).toList();
  }
}
