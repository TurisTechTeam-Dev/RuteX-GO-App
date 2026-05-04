/*
  -----------------------------------------------------------------------------
  Proyecto: RuteX Go
  Desarrollado por: TurisTechTeam
  Descripción: Esta aplicación y su código fuente son propiedad intelectual de
  TurisTechTeam. Queda prohibida su copia, distribución o uso no autorizado.
  Año: 2026
  -----------------------------------------------------------------------------
*/
import 'dart:typed_data';

import '../entities/home_data.dart';
import '../repositories/profile_repository.dart';

class ProfileUseCases {
  final ProfileRepository repository;

  const ProfileUseCases(this.repository);

  Future<HomeData> getHomeData(String uid) {
    return repository.getHomeData(uid);
  }

  Future<void> updateUsername({required String uid, required String username}) {
    return repository.updateUsername(uid: uid, username: username);
  }

  Future<String> uploadAvatar({
    required String uid,
    required Uint8List bytes,
    required String contentType,
  }) {
    return repository.uploadAvatar(
      uid: uid,
      bytes: bytes,
      contentType: contentType,
    );
  }

  Future<void> updateAvatar({required String uid, required String avatarPath}) {
    return repository.updateAvatar(uid: uid, avatarPath: avatarPath);
  }
}
