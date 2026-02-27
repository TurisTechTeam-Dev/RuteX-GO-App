abstract class AuthRepository {
  Future<void> login({required String email, required String password});

  Future<void> register({
    required String nombre,
    required String apellido,
    required String usuario,
    required String email,
    required String password,
  });

  Future<void> logout();
}
