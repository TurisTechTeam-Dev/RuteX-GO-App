import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  Stream<User?> get authStateChanges;

  Future<void> login({required String email, required String password});

  Future<void> register({
    required String name,
    required String username,
    required String email,
    required String password,
  });

  Future<void> recoverPassword(String email);

  Future<void> logout();

  Future<bool> isAdmin(String uid);
}
