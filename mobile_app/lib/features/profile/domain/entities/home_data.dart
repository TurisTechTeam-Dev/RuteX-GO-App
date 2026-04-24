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
