import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileRemoteDatasource {
  final FirebaseFirestore db;

  ProfileRemoteDatasource(this.db);

  Future<Map<String, dynamic>> getUserProfile(String uid) async {
    final docSnapShot = await db.collection("usuarios").doc(uid).get();

    return docSnapShot.data()!;
  }

  Future<List<Map<String, dynamic>>> getCompletedRoutes(String uid) async {
    final querySnapShot = await db
        .collection("resultado")
        .where("id_usuario", isEqualTo: uid)
        .get();

    return querySnapShot.docs.map((doc) => doc.data()).toList();
  }

  Future<Map<String, dynamic>> getConfigRangos(String rangoId) async{
    final docSnapShot = await db.collection("config_rangos").doc(rangoId).get();
    return docSnapShot.data()!;
  }
}
