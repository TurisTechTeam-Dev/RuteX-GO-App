import 'package:cloud_firestore/cloud_firestore.dart';
import '../repository/routes_repository.dart';

class RoutesUsesCases {
  final RoutesRepository repository;

  RoutesUsesCases(this.repository);

  Stream<QuerySnapshot> executeGetCiudades() {
    return repository.getCiudades();
  }

  Stream<QuerySnapshot> executeGetRutasByCiudad(String idCiudad) {
    return repository.getRutasByCiudad(idCiudad);
  }
}