import 'dart:typed_data';

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

  @override
  Future<void> updateUsername({
    required String uid,
    required String username,
  }) {
    return homeDataLoader.remoteDataSource.updateUsername(
      uid: uid,
      username: username,
    );
  }

  @override
  Future<String> uploadAvatar({
    required String uid,
    required Uint8List bytes,
    required String contentType,
  }) {
    return homeDataLoader.remoteDataSource.uploadAvatar(
      uid: uid,
      bytes: bytes,
      contentType: contentType,
    );
  }

  @override
  Future<void> updateAvatar({
    required String uid,
    required String avatarPath,
  }) {
    return homeDataLoader.remoteDataSource.updateAvatar(
      uid: uid,
      avatarPath: avatarPath,
    );
  }
}
