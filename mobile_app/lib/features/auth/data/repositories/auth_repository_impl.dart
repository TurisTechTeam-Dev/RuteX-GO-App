import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/constants/firestore_contract.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/auth_user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  AuthRepositoryImpl(this.firebaseAuth, this.firestore);

  @override
  Stream<AuthUserModel?> get authStateChanges =>
      firebaseAuth.authStateChanges().map(
        (user) => user == null ? null : AuthUserModel.fromFirebaseUser(user),
      );

  @override
  Future<AuthUserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw Exception("No se pudo recuperar el usuario tras el login");
      }

      await firestore
          .collection(FirestoreCollections.usuarios)
          .doc(user.uid)
          .update({UserFields.ultimoAcceso: FieldValue.serverTimestamp()});

      return AuthUserModel.fromFirebaseUser(user);
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapError(e.code));
    }
  }

  @override
  AuthUserModel? getCurrentUser() {
    final user = firebaseAuth.currentUser;
    return user == null ? null : AuthUserModel.fromFirebaseUser(user);
  }

  @override
  Future<void> register({
    required String name,
    required String username,
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
        UserFields.nombre: name,
        UserFields.usuario: username,
        UserFields.email: email,
        UserFields.avatar: '',
        UserFields.fechaCreacion: FieldValue.serverTimestamp(),
        UserFields.ultimoAcceso: FieldValue.serverTimestamp(),
        UserFields.puntos: 0,
        UserFields.rutasCompletadas: [],
        UserFields.isAdmin: false,
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw Exception("El correo electrónico ya está registrado.");
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
  Future<void> requestEmailChange(String newEmail) async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        throw Exception("No hay sesión activa.");
      }

      await user.verifyBeforeUpdateEmail(newEmail);
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapError(e.code));
    }
  }

  @override
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        throw Exception("No hay sesión activa.");
      }

      final email = user.email;
      if (email == null || email.isEmpty) {
        throw Exception("No se pudo comprobar el email del usuario.");
      }

      final credential = EmailAuthProvider.credential(
        email: email,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
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
        return "El correo no está registrado.";
      case 'wrong-password':
      case 'invalid-credential':
        return "La contraseña es incorrecta.";
      case 'invalid-email':
        return "El formato del email no es válido.";
      case 'user-disabled':
        return "Este usuario ha sido deshabilitado.";
      case 'email-already-in-use':
        return "Este correo ya está registrado.";
      case 'weak-password':
        return "La contraseña es muy corta.";
      case 'requires-recent-login':
        return "Por seguridad, vuelve a iniciar sesión antes de cambiar estos datos.";
      default:
        return "Error de autenticación. Inténtalo de nuevo.";
    }
  }
}
