
import '../repositories/regis_repository.dart';

class RegisterUsecase {
  final RegisRepository repository;

  RegisterUsecase(this.repository);
  Future<void> call(
    String nombre,
    String apellido,
    String usuario,
    String email,
    String password,
  ) async {
     if (email.isEmpty || password.isEmpty||nombre.isEmpty||apellido.isEmpty||usuario.isEmpty) {
      throw Exception("Debes completar todos los campos.");
    }
    

    await repository.register(email: email, password: password,nombre: nombre,apellido: apellido,usuario: usuario);
  }
}


