/*
  -----------------------------------------------------------------------------
  Proyecto: RuteX Go
  Desarrollado por: TurisTechTeam
  Descripción: Esta aplicación y su código fuente son propiedad intelectual de
  TurisTechTeam. Queda prohibida su copia, distribución o uso no autorizado.
  Año: 2026
  -----------------------------------------------------------------------------
*/
import '../entities/auth_user.dart';

abstract class AuthRepository {
  Stream<AuthUser?> get authStateChanges;

  Future<AuthUser> login({required String email, required String password});

  Future<AuthUser> loginWithGoogle();

  AuthUser? getCurrentUser();

  Future<void> register({
    required String name,
    required String username,
    required String email,
    required String password,
  });

  Future<void> recoverPassword(String email);

  Future<void> requestEmailChange(String newEmail);

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<void> logout();

  Future<bool> isAdmin(String uid);
}
