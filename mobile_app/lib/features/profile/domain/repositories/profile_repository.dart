import 'dart:typed_data';

import '../entities/home_data.dart';

abstract class ProfileRepository {
  Future<HomeData> getHomeData(String uid);

  Future<void> updateUsername({required String uid, required String username});

  Future<String> uploadAvatar({
    required String uid,
    required Uint8List bytes,
    required String contentType,
  });

  Future<void> updateAvatar({
    required String uid,
    required String avatarPath,
  });
}
