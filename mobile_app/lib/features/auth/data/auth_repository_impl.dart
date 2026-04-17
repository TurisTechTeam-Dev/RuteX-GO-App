import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/constants/firestore_contract.dart';
import '../domain/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  AuthRepositoryImpl(this.firebaseAuth, this.firestore);

  @override
  Stream<User?> get authStateChanges => firebaseAuth.authStateChanges();

  @override
  Future<void> login({required String email, required String password}) async {
    try {
      final userCredential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        await firestore
            .collection(FirestoreCollections.usuarios)
            .doc(userCredential.user!.uid)
            .update({UserFields.ultimoAcceso: FieldValue.serverTimestamp()});
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapError(e.code));
    }
  }

  @override
  Future<void> register({
    required String nombre,
    required String usuario,
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user!.uid;

      await firestore.collection(FirestoreCollections.usuarios).doc(uid).set({
        UserFields.uid: uid,
        UserFields.nombre: nombre,
        UserFields.usuario: usuario,
        UserFields.email: email,
        UserFields.fechaCreacion: FieldValue.serverTimestamp(),
        UserFields.ultimoAcceso: FieldValue.serverTimestamp(),
        UserFields.puntos: 0,
        UserFields.rutasCompletadas: [],
        UserFields.isAdmin: false,
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw Exception("El correo electronico ya esta registrado.");
      }
      throw Exception(_mapError(e.code));
    }
  }

  @override
  Future<void> recoverPassword(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapError(e.code));
    }
  }

  @override
  Future<void> logout() async {
    await firebaseAuth.signOut();
  }

  @override
  Future<bool> isAdmin(String uid) async {
    try {
      final doc = await firestore
          .collection(FirestoreCollections.usuarios)
          .doc(uid)
          .get();
      if (doc.exists) {
        return doc.data()?[UserFields.isAdmin] == true;
      }
      return false;
    } catch (e) {
      throw Exception("Error al verificar rol de administrador");
    }
  }

  String _mapError(String code) {
    switch (code) {
      case 'user-not-found':
        return "El correo no esta registrado.";
      case 'wrong-password':
        return "La contrasena es incorrecta.";
      case 'invalid-email':
        return "El formato del email no es valido.";
      case 'user-disabled':
        return "Este usuario ha sido deshabilitado.";
      case 'email-already-in-use':
        return "Este correo ya esta registrado.";
      case 'weak-password':
        return "La contrasena es muy corta.";
      default:
        return "Error de autenticacion. Intentalo de nuevo.";
    }
  }
}
