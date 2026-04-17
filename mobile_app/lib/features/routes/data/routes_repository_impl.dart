import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/firestore_contract.dart';
import '../domain/repository/routes_repository.dart';

class RoutesRepositoryImpl implements RoutesRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Stream<QuerySnapshot> getCiudades() {
    return _db.collection(FirestoreCollections.ciudades).snapshots();
  }

  @override
  Stream<QuerySnapshot> getRutasByCiudad(String idCiudad) {
    return _db
        .collection(FirestoreCollections.rutas)
        .where(RouteFields.idCiudad, isEqualTo: idCiudad)
        .snapshots();
  }
}
