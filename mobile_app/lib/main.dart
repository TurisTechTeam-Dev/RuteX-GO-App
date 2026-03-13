import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'features/mission/data/repository/mission_repository_impl.dart';
import 'features/mission/domain/usescases/mission_uses_cases.dart';
import 'features/mission/presentation/provider/trip_provider.dart';

import 'core/routes/app_routes.dart';
import 'features/splash/presentation/splash_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 1. Inicialización manual de dependencias
  final missionRepo = MissionRepositoryImpl();
  final missionUseCases = MissionUseCases(missionRepo);

  runApp(
    // 2. Envolvemos la App con MultiProvider para que sea GLOBAL
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TripSimulationProvider(missionUseCases: missionUseCases),
        ),
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
      routes: AppRoutes.getRoutes(),
      home: const SplashScreen(),
    );
  }
}