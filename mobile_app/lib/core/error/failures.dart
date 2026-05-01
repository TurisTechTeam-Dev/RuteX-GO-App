/*
  -----------------------------------------------------------------------------
  Proyecto: RuteX Go
  Desarrollado por: TurisTechTeam
  Descripción: Esta aplicación y su código fuente son propiedad intelectual de
  TurisTechTeam. Queda prohibida su copia, distribución o uso no autorizado.
  Año: 2026
  -----------------------------------------------------------------------------
*/
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
