import 'package:mobile_app/features/profile/data/profile_remote_datasource.dart';
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
  Future <Map<String, dynamic>> getConfigRangos (String rangoId) async{
    return await remoteDatasource.getConfigRangos(rangoId);
  }

  @override
  Future<void> logout() {
    // TODO: implement logout
    throw UnimplementedError();
  }
}
