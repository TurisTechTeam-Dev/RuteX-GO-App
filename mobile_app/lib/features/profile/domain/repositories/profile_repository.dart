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

abstract class ProfileRepository {
  Future<HomeData> getHomeData(String uid);

  Future<void> updateUsername({required String uid, required String username});

  Future<String> uploadAvatar({
    required String uid,
    required Uint8List bytes,
    required String contentType,
  });

  Future<void> updateAvatar({required String uid, required String avatarPath});
}
