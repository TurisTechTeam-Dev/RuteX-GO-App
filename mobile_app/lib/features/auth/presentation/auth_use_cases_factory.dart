import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../data/auth_repository_impl.dart';
import '../domain/usescases/auth_use_cases.dart';

AuthUsesCases createAuthUseCases() {
  return AuthUsesCases(
    AuthRepositoryImpl(
      FirebaseAuth.instance,
      FirebaseFirestore.instance,
    ),
  );
}
