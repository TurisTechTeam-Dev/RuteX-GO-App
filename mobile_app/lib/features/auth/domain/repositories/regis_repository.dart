abstract class RegisRepository {
  Future<void> register({
    required String nombre,
    required String apellido,
    required String usuario,
    required String email,
    required String password,
  });
}
