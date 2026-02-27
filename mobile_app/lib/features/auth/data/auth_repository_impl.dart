// features/auth/data/repositories/auth_repository_impl.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../domain/repositories/AuthRepository.dart';


class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  AuthRepositoryImpl(this.firebaseAuth, this.firestore);

  @override
  Future<void> login({required String email, required String password}) async {
    try {
      await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapError(e.code));
    }
  }

  @override
  Future<void> register({
    required String nombre,
    required String apellido,
    required String usuario,
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      final String uid = userCredential.user!.uid;

      await firestore.collection('usuarios').doc(uid).set({
        'uid': uid,
        'nombre': nombre,
        'apellido': apellido,
        'usuario': usuario,
        'email': email,
        'fecha_creacion': FieldValue.serverTimestamp(),
        'ultimo_acceso': FieldValue.serverTimestamp(),
        'isAdmin': false,
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw Exception("El correo electrónico ya está registrado.");
      }
      throw Exception(_mapError(e.code));
    }
  }

  @override
  Future<void> logout() async {
    await firebaseAuth.signOut();
  }

  String _mapError(String code) {
    switch (code) {
      case 'user-not-found':
        return "El correo no está registrado.";
      case 'wrong-password':
        return "La contraseña es incorrecta.";
      case 'invalid-email':
        return "El formato del email no es válido.";
      case 'user-disabled':
        return "Este usuario ha sido deshabilitado.";
      case 'email-already-in-use':
        return "Este correo ya está registrado.";
      case 'weak-password':
        return "La contraseña es muy corta.";
      default:
        return "Error de autenticación. Inténtalo de nuevo.";
    }
  }
}