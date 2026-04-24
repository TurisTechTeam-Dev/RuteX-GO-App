import '../entities/home_data.dart';

abstract class ProfileRepository {
  Future<HomeData> getHomeData(String uid);
}
