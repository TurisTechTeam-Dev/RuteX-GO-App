/*
  -----------------------------------------------------------------------------
  Proyecto: RuteX Go
  Desarrollado por: TurisTechTeam
  Descripción: Esta aplicación y su código fuente son propiedad intelectual de
  TurisTechTeam. Queda prohibida su copia, distribución o uso no autorizado.
  Año: 2026
  -----------------------------------------------------------------------------
*/
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/auth_user.dart';

class AuthUserModel extends AuthUser {
  const AuthUserModel({
    required super.uid,
    super.email,
    super.isFirstLogin = false,
  });

  factory AuthUserModel.fromFirebaseUser(User user, {bool isFirstLogin = false}) {
    return AuthUserModel(uid: user.uid, email: user.email, isFirstLogin: isFirstLogin);
  }
}
