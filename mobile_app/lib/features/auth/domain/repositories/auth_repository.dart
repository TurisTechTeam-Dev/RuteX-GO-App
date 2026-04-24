import '../entities/auth_user.dart';

abstract class AuthRepository {
  Stream<AuthUser?> get authStateChanges;

  Future<AuthUser> login({required String email, required String password});

  AuthUser? getCurrentUser();

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
