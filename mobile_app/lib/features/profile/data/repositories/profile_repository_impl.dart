import 'package:mobile_app/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:mobile_app/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDatasource remoteDatasource;

  ProfileRepositoryImpl(this.remoteDatasource);

  @override
  Future<Map<String, dynamic>> getUserProfile(String uid) async {
    return await remoteDatasource.getUserProfile(uid);
  }

  @override
  Future<List<Map<String, dynamic>>> getCompletedRoutes(String uid) async {
    return await remoteDatasource.getCompletedRoutes(uid);
  }

  @override
  Future<Map<String, dynamic>> getRankConfig(String rankId) async {
    return await remoteDatasource.getRankConfig(rankId);
  }
}
