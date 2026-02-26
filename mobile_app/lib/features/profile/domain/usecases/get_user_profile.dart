import 'package:mobile_app/features/profile/domain/repositories/profile_repository.dart';

class GetUserProfile {
  final ProfileRepository repository;

  GetUserProfile(this.repository);

  Future<Map<String, dynamic>> call(String uid) {
    return repository.getUserProfile(uid);
  }
}
