import 'package:firebase_auth/firebase_auth.dart';

import '../domain/repositories/aut_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth firebaseAuth;

  AuthRepositoryImpl(this.firebaseAuth);

  @override
  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapError(e.code));
    }
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
      default:
        return "Error al iniciar sesión. Inténtalo de nuevo.";
    }
  }
}
