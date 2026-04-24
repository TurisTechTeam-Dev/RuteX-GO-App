import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/routes/app_routes.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/auth_use_cases.dart';
import 'features/auth/presentation/auth_wrapper.dart';
import 'features/mission/data/repositories/mission_repository_impl.dart';
import 'features/mission/domain/usecases/mission_use_cases.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final missionRepository = MissionRepositoryImpl();
  final authRepository = AuthRepositoryImpl(
    FirebaseAuth.instance,
    FirebaseFirestore.instance,
  );

  final missionUseCases = MissionUseCases(missionRepository);
  final authUseCases = AuthUseCases(authRepository);

  runApp(
    MultiProvider(
      providers: [
        Provider<MissionUseCases>.value(value: missionUseCases),
        Provider<AuthUseCases>.value(value: authUseCases),
      ],
      child: const RutexApp(),
    ),
  );
}

class RutexApp extends StatelessWidget {
  const RutexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RutexGo',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      onGenerateRoute: AppRoutes.onGenerateRoute,
      home: const AuthWrapper(),
    );
  }
}
