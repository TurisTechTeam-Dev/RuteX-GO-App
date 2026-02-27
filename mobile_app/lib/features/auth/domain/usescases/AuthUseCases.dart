// features/auth/domain/usecases/auth_usecases.dart
import '../repositories/AuthRepository.dart';


class AuthUsesCases {
  final AuthRepository repository;

  AuthUsesCases(this.repository);

  Future<void> login(String email, String password) {
    return repository.login(email: email, password: password);
  }

  Future<void> register({
    required String nombre,
    required String apellido,
    required String usuario,
    required String email,
    required String password,
  }) {
    return repository.register(
      nombre: nombre,
      apellido: apellido,
      usuario: usuario,
      email: email,
      password: password,
    );
  }

  Future<void> logout() {
    return repository.logout();
  }
}