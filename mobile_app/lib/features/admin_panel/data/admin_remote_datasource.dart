import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data'; // Para Uint8List

import '../../../core/constants/firestore_contract.dart';
import 'models/admin_models.dart';

class AdminRemoteDataSource {
  AdminRemoteDataSource({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  /// Sube los bytes de una imagen a Firebase Storage y devuelve la URL de descarga.
  Future<String> uploadFile(
    Uint8List fileBytes,
    String folder,
    String fileName,
  ) async {
    try {
      Reference ref = _storage.ref().child(folder).child(fileName);

      try {
        // Comprobamos si el archivo ya existe intentando obtener sus metadatos
        await ref.getMetadata();

        // Si no lanza excepciÃ³n, es que ya existe. Generamos un nombre Ãºnico con timestamp.
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final dotIndex = fileName.lastIndexOf('.');
        final nameOnly = dotIndex != -1
            ? fileName.substring(0, dotIndex)
            : fileName;
        final extension = dotIndex != -1 ? fileName.substring(dotIndex) : '';

        final uniqueFileName = '${nameOnly}_$timestamp$extension';
        ref = _storage.ref().child(folder).child(uniqueFileName);
      } catch (e) {
        // Si llegamos aquÃ­ (probablemente error object-not-found),
        // significa que el nombre original estÃ¡ libre. Lo usamos tal cual.
      }

      // En Web y mÃ³vil, putData funciona perfectamente con bytes
      final uploadTask = ref.putData(fileBytes);

      final snapshot = await uploadTask;
      return snapshot.ref.fullPath;
    } catch (e) {
      throw Exception('Error al subir imagen: $e');
    }
  }

  Stream<List<AdminCityModel>> watchCities() {
    return _firestore
        .collection(FirestoreCollections.ciudades)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AdminCityModel.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }

  Stream<List<AdminPoiModel>> watchPois() {
    return _firestore
        .collection(FirestoreCollections.puntosInteres)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AdminPoiModel.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }

  Stream<List<AdminMissionModel>> watchMissions() {
    return _firestore
        .collection(FirestoreCollections.misiones)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AdminMissionModel.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }

  Stream<List<AdminRouteModel>> watchRoutes() {
    return _firestore
        .collection(FirestoreCollections.rutas)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AdminRouteModel.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> saveCity(AdminCityModel city) async {
    final collection = _firestore.collection(FirestoreCollections.ciudades);
    if (city.id == null || city.id!.isEmpty) {
      await collection.add(city.toFirestore());
      return;
    }
    await collection
        .doc(city.id)
        .set(city.toFirestore(), SetOptions(merge: true));
  }

  Future<void> savePoi(AdminPoiModel poi) async {
    final collection = _firestore.collection(
      FirestoreCollections.puntosInteres,
    );
    if (poi.id == null || poi.id!.isEmpty) {
      await collection.add(poi.toFirestore());
      return;
    }
    await collection
        .doc(poi.id)
        .set(poi.toFirestore(), SetOptions(merge: true));
  }

  Future<void> saveMission(AdminMissionModel mission) async {
    final collection = _firestore.collection(FirestoreCollections.misiones);
    if (mission.id == null || mission.id!.isEmpty) {
      await collection.add(mission.toFirestore());
      return;
    }
    await collection
        .doc(mission.id)
        .set(mission.toFirestore(), SetOptions(merge: true));
  }

  Future<void> saveRoute(AdminRouteModel route) async {
    final collection = _firestore.collection(FirestoreCollections.rutas);
    if (route.id == null || route.id!.isEmpty) {
      await collection.add(route.toFirestore());
      return;
    }
    await collection
        .doc(route.id)
        .set(route.toFirestore(), SetOptions(merge: true));
  }

  Future<void> deleteCity(String id) async {
    await _firestore.collection(FirestoreCollections.ciudades).doc(id).delete();
  }

  Future<void> deletePoi(String id) async {
    await _firestore
        .collection(FirestoreCollections.puntosInteres)
        .doc(id)
        .delete();
  }

  Future<void> deleteRoute(String id) async {
    await _firestore.collection(FirestoreCollections.rutas).doc(id).delete();
  }

  Future<void> deleteMission(String id) async {
    await _firestore.collection(FirestoreCollections.misiones).doc(id).delete();
  }
}
