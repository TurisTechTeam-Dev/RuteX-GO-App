/*
  -----------------------------------------------------------------------------
  Proyecto: RuteX Go
  Desarrollado por: TurisTechTeam
  Descripción: Esta aplicación y su código fuente son propiedad intelectual de
  TurisTechTeam. Queda prohibida su copia, distribución o uso no autorizado.
  Año: 2026
  -----------------------------------------------------------------------------
*/
class UserProfile {
  final String uid;
  final String name;
  final String username;
  final String email;
  final String avatarUrl;
  final int points;
  final DateTime? createdAt;

  const UserProfile({
    required this.uid,
    required this.name,
    required this.username,
    required this.email,
    required this.avatarUrl,
    required this.points,
    this.createdAt,
  });
}
