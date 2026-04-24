import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/auth_use_cases.dart';
import 'features/mission/data/repositories/mission_repository_impl.dart';
import 'features/mission/domain/repositories/mission_repository.dart';
import 'features/mission/domain/usecases/mission_use_cases.dart';
import 'features/profile/data/datasources/profile_remote_datasource.dart';
import 'features/profile/data/repositories/profile_repository_impl.dart';
import 'features/profile/domain/repositories/profile_repository.dart';
import 'features/profile/domain/usecases/profile_use_cases.dart';
import 'features/routes/data/datasources/routes_remote_datasource.dart';
import 'features/routes/data/repositories/routes_repository_impl.dart';
import 'features/routes/domain/repositories/routes_repository.dart';
import 'features/routes/domain/usecases/routes_use_cases.dart';

List<SingleChildWidget> buildAppProviders() {
  return [
    Provider<FirebaseAuth>.value(value: FirebaseAuth.instance),
    Provider<FirebaseFirestore>.value(value: FirebaseFirestore.instance),
    ProxyProvider2<FirebaseAuth, FirebaseFirestore, AuthRepository>(
      update: (context, firebaseAuth, firestore, previous) =>
          AuthRepositoryImpl(firebaseAuth, firestore),
    ),
    ProxyProvider2<FirebaseAuth, FirebaseFirestore, MissionRepository>(
      update: (context, firebaseAuth, firestore, previous) =>
          MissionRepositoryImpl(
            firebaseAuth: firebaseAuth,
            firestore: firestore,
          ),
    ),
    ProxyProvider<FirebaseFirestore, RoutesRepository>(
      update: (context, firestore, previous) => RoutesRepositoryImpl(
        remoteDataSource: RoutesRemoteDataSource(firestore),
      ),
    ),
    ProxyProvider<FirebaseFirestore, ProfileRepository>(
      update: (context, firestore, previous) => ProfileRepositoryImpl(
        remoteDataSource: ProfileRemoteDataSource(firestore),
      ),
    ),
    ProxyProvider<AuthRepository, AuthUseCases>(
      update: (context, repository, previous) => AuthUseCases(repository),
    ),
    ProxyProvider<MissionRepository, MissionUseCases>(
      update: (context, repository, previous) => MissionUseCases(repository),
    ),
    ProxyProvider<RoutesRepository, RoutesUseCases>(
      update: (context, repository, previous) => RoutesUseCases(repository),
    ),
    ProxyProvider<ProfileRepository, ProfileUseCases>(
      update: (context, repository, previous) => ProfileUseCases(repository),
    ),
  ];
}
