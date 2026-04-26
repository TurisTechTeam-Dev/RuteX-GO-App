import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../../../core/constants/firestore_contract.dart';

class ProfileRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;
  static const int _firestoreWhereInLimit = 10;

  ProfileRemoteDataSource(this.firestore, {FirebaseStorage? storage})
    : storage = storage ?? FirebaseStorage.instance;

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

  Future<void> updateUsername({
    required String uid,
    required String username,
  }) {
    return firestore.collection(FirestoreCollections.usuarios).doc(uid).update({
      UserFields.usuario: username,
    });
  }

  Future<String> uploadAvatar({
    required String uid,
    required Uint8List bytes,
    required String contentType,
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final ref = storage.ref('Avatares/$uid/perfil_$timestamp.jpg');
    await ref.putData(bytes, SettableMetadata(contentType: contentType));
    return ref.fullPath;
  }

  Future<void> updateAvatar({
    required String uid,
    required String avatarPath,
  }) {
    return firestore.collection(FirestoreCollections.usuarios).doc(uid).update({
      UserFields.avatar: avatarPath,
    });
  }
}
