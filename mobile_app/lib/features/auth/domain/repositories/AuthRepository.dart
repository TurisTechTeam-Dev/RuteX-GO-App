import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  Stream<User?> get authStateChanges;

  Future<void> login({required String email, required String password});

  Future<void> register({
    required String nombre,
    required String usuario,
    required String email,
    required String password,
  });

  Future<void> recoverPassword(String email);

  Future<void> logout();
}
