import '../../domain/entities/home_data.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';
import '../home_data_loader.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final HomeDataLoader homeDataLoader;

  ProfileRepositoryImpl({
    required ProfileRemoteDataSource remoteDataSource,
  }) : homeDataLoader = HomeDataLoader(remoteDataSource);

  @override
  Future<HomeData> getHomeData(String uid) {
    return homeDataLoader.load(uid);
  }
}
