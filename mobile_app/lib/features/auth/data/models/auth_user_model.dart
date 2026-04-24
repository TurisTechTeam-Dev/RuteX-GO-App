import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/auth_user.dart';

class AuthUserModel extends AuthUser {
  const AuthUserModel({required super.uid, super.email});

  factory AuthUserModel.fromFirebaseUser(User user) {
    return AuthUserModel(uid: user.uid, email: user.email);
  }
}
