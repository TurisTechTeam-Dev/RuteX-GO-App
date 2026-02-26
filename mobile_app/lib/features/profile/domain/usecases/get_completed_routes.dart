import 'package:mobile_app/features/profile/domain/repositories/profile_repository.dart';

class GetCompletedRoutes {
  final ProfileRepository repository;

  GetCompletedRoutes(this.repository);

  Future<List<Map<String, dynamic>>> call(String uid) {
    return repository.getCompletedRoutes(uid);
  }
}
