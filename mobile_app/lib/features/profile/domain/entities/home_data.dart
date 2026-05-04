/*
  -----------------------------------------------------------------------------
  Proyecto: RuteX Go
  Desarrollado por: TurisTechTeam
  Descripción: Esta aplicación y su código fuente son propiedad intelectual de
  TurisTechTeam. Queda prohibida su copia, distribución o uso no autorizado.
  Año: 2026
  -----------------------------------------------------------------------------
*/
import 'home_route.dart';
import 'profile_rank.dart';
import 'user_profile.dart';

class HomeData {
  final UserProfile user;
  final List<HomeRoute> routes;
  final List<ProfileRank> ranks;

  const HomeData({
    required this.user,
    required this.routes,
    required this.ranks,
  });
}
