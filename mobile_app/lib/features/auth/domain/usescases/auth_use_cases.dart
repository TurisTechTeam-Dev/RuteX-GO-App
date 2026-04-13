// features/auth/domain/usecases/auth_usecases.dart
import 'package:firebase_auth/firebase_auth.dart';

import '../repository/auth_repository.dart';


class AuthUsesCases {
  final AuthRepository repository;

  AuthUsesCases(this.repository);

  Stream<User?> get authStateChanges => repository.authStateChanges;

  Future<void> login(String email, String password) {
    return repository.login(email: email, password: password);
  }

  Future<void> register({
    required String nombre,
    required String usuario,
    required String email,
    required String password,
  }) {
    return repository.register(
      nombre: nombre,
      usuario: usuario,
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

  Future<bool> checkAdminStatus(String uid){
    return repository.isAdmin(uid);
  }
}