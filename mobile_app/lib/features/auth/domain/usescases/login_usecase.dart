import '../repositories/aut_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<void> call(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      throw Exception("Debes completar todos los campos.");
    }

    await repository.login(email: email, password: password);
  }
}
