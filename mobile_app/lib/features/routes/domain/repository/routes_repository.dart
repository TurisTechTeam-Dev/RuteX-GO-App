import 'package:cloud_firestore/cloud_firestore.dart';

abstract class RoutesRepository {
  Stream<QuerySnapshot> getCiudades();
  Stream<QuerySnapshot> getRutasByCiudad(String idCiudad);
}