import '../repositories/profile_repository.dart';

class ProfileUseCases {
  final ProfileRepository repository;

  ProfileUseCases(this.repository);

  Future<Map<String, dynamic>> getUserProfile(String uid) {
    return repository.getUserProfile(uid);
  }

  Future<List<Map<String, dynamic>>> getCompletedRoutes(String uid) {
    return repository.getCompletedRoutes(uid);
  }

  Future<Map<String, dynamic>> getConfigRangos(String configId) {
    return repository.getConfigRangos(configId);
  }
}
