import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/constants/firestore_contract.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/auth_user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;
  final GoogleSignIn googleSignIn;

  AuthRepositoryImpl(
    this.firebaseAuth,
    this.firestore, {
    GoogleSignIn? googleSignIn,
  }) : googleSignIn = googleSignIn ?? GoogleSignIn();

  @override
  Stream<AuthUserModel?> get authStateChanges async* {
    await for (final user in firebaseAuth.authStateChanges()) {
      if (user == null) {
        yield null;
      } else {
        yield AuthUserModel.fromFirebaseUser(user);
      }
    }
  }

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
  Future<AuthUserModel> loginWithGoogle() async {
    try {
      final UserCredential userCredential;

      if (kIsWeb) {
        userCredential = await firebaseAuth.signInWithPopup(
          GoogleAuthProvider(),
        );
      } else {
        final googleUser = await googleSignIn.signIn();
        if (googleUser == null) {
          throw const GoogleSignInCancelledException();
        }

        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        userCredential = await firebaseAuth.signInWithCredential(credential);
      }

      final user = userCredential.user;
      if (user == null) {
        throw Exception("No se pudo recuperar el usuario tras el login");
      }

      await _ensureUserDocument(user);
      return AuthUserModel.fromFirebaseUser(user);
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapError(e.code));
    } on PlatformException catch (e) {
      throw Exception(_mapGooglePlatformError(e));
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

  Future<void> _ensureUserDocument(User user) async {
    final userRef = firestore
        .collection(FirestoreCollections.usuarios)
        .doc(user.uid);
    final snapshot = await userRef.get();

    if (!snapshot.exists) {
      final email = user.email ?? '';
      await userRef.set({
        UserFields.uid: user.uid,
        UserFields.nombre: _displayNameForGoogleUser(user),
        UserFields.usuario: _usernameForGoogleUser(user),
        UserFields.email: email,
        UserFields.avatar: user.photoURL ?? '',
        UserFields.fechaCreacion: FieldValue.serverTimestamp(),
        UserFields.ultimoAcceso: FieldValue.serverTimestamp(),
        UserFields.puntos: 0,
        UserFields.rutasCompletadas: [],
        UserFields.isAdmin: false,
      });
      return;
    }

    final data = snapshot.data() ?? {};
    final updates = <String, dynamic>{
      UserFields.ultimoAcceso: FieldValue.serverTimestamp(),
    };

    if ((data[UserFields.email]?.toString() ?? '').isEmpty) {
      updates[UserFields.email] = user.email ?? '';
    }
    if ((data[UserFields.usuario]?.toString() ?? '').isEmpty) {
      updates[UserFields.usuario] = _usernameForGoogleUser(user);
    }
    if (!data.containsKey(UserFields.avatar)) {
      updates[UserFields.avatar] = user.photoURL ?? '';
    }
    await userRef.update(updates);
  }

  String _displayNameForGoogleUser(User user) {
    final displayName = user.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) return displayName;

    return _usernameForGoogleUser(user);
  }

  String _usernameForGoogleUser(User user) {
    final displayName = user.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) return displayName;

    final email = user.email?.trim() ?? '';
    if (email.contains('@')) return email.split('@').first;

    return 'Usuario';
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
    if (!kIsWeb) {
      await googleSignIn.signOut();
    }
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
      case 'account-exists-with-different-credential':
        return "Ya existe una cuenta con ese email usando otro metodo de acceso.";
      case 'popup-closed-by-user':
      case 'canceled':
        return "Inicio de sesión cancelado.";
      default:
        return "Error de autenticación. Inténtalo de nuevo.";
    }
  }

  String _mapGooglePlatformError(PlatformException error) {
    if (error.code == 'channel-error') {
      return "Google no se ha inicializado en esta instalación. Cierra la app y vuelve a instalarla con un build nuevo.";
    }

    final details = '${error.message ?? ''} ${error.details ?? ''}';
    if (error.code == 'sign_in_failed' &&
        details.contains('ApiException: 10')) {
      return "Google Sign-In no está configurado para esta firma de Android. Añade el SHA-1 y SHA-256 de esta app en Firebase y descarga de nuevo google-services.json.";
    }

    if (error.code == 'sign_in_canceled' || error.code == 'canceled') {
      return "Inicio de sesión cancelado.";
    }

    return "No se pudo iniciar sesión con Google. Inténtalo de nuevo.";
  }
}

class GoogleSignInCancelledException implements Exception {
  const GoogleSignInCancelledException();

  @override
  String toString() => "Inicio de sesión cancelado.";
}
