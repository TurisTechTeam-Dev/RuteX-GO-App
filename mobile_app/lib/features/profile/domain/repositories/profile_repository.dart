abstract class ProfileRepository {
  Future<Map<String, dynamic>> getUserProfile(String uid);

  Future<List<Map<String, dynamic>>> getCompletedRoutes(String uid);

  Future<Map<String, dynamic>> getRankConfig(String rankId);
}
