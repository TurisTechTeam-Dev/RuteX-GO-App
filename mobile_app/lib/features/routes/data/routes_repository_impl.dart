import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/repository/routes_repository.dart';

class RoutesRepositoryImpl implements RoutesRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Stream<QuerySnapshot> getCiudades() {
    // Escucha la colección ciudades
    return _db.collection('ciudades').snapshots();
  }

  @override
  Stream<QuerySnapshot> getRutasByCiudad(String idCiudad) {
    // Filtra las rutas cuyo campo 'id_ciudad' coincida con la seleccionada
    return _db.collection('rutas')
        .where('id_ciudad', isEqualTo: idCiudad)
        .snapshots();
  }
}