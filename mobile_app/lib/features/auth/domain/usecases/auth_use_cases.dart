import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class AuthUseCases {
  final AuthRepository repository;

  AuthUseCases(this.repository);

  Stream<AuthUser?> get authStateChanges => repository.authStateChanges;

  Future<AuthUser> login(String email, String password) {
    return repository.login(email: email, password: password);
  }

  Future<AuthUser> loginWithGoogle() {
    return repository.loginWithGoogle();
  }

  AuthUser? getCurrentUser() {
    return repository.getCurrentUser();
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

  Future<void> requestEmailChange(String newEmail) {
    return repository.requestEmailChange(newEmail);
  }

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    return repository.updatePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  Future<void> logout() {
    return repository.logout();
  }

  Future<bool> checkAdminStatus(String uid) {
    return repository.isAdmin(uid);
  }
}
