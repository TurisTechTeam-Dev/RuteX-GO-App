/*
  -----------------------------------------------------------------------------
  Proyecto: RuteX Go
  Desarrollado por: TurisTechTeam
  Descripción: Esta aplicación y su código fuente son propiedad intelectual de
  TurisTechTeam. Queda prohibida su copia, distribución o uso no autorizado.
  Año: 2026
  -----------------------------------------------------------------------------
*/
class AuthUser {
  final String uid;
  final String? email;
  final bool isFirstLogin;

  const AuthUser({required this.uid, this.email, this.isFirstLogin = false});
}
