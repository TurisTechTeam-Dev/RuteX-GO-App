import 'package:firebase_auth/firebase_auth.dart';

import '../repositories/auth_repository.dart';

class AuthUseCases {
  final AuthRepository repository;

  AuthUseCases(this.repository);

  Stream<User?> get authStateChanges => repository.authStateChanges;

  Future<void> login(String email, String password) {
    return repository.login(email: email, password: password);
  }

  Future<void> register({
    required String name,
    required String username,
    required String email,
    required String password,
  }) {
    return repository.register(
      name: name,
      username: username,
      email: email,
      password: password,
    );
  }

  Future<void> recoverPassword(String email) {
    return repository.recoverPassword(email);
  }

  Future<void> logout() {
    return repository.logout();
  }

  Future<bool> checkAdminStatus(String uid) {
    return repository.isAdmin(uid);
  }
}
