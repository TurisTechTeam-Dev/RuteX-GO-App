abstract class Failure {
  final String mensaje;
  const Failure(this.mensaje);
}

class ServerFailure extends Failure {
  const ServerFailure(super.mensaje);
}

class AuthFailure extends Failure {
  const AuthFailure(super.mensaje);
}
