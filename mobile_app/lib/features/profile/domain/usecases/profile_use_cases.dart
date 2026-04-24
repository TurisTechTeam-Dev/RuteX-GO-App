import '../entities/home_data.dart';
import '../repositories/profile_repository.dart';

class ProfileUseCases {
  final ProfileRepository repository;

  const ProfileUseCases(this.repository);

  Future<HomeData> getHomeData(String uid) {
    return repository.getHomeData(uid);
  }
}
