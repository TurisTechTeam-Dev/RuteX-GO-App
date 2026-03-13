import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart'; // MaterialApp y Widgets ya están aquí
import 'package:provider/provider.dart';
import 'features/mission/data/repository/mission_repository_impl.dart';
import 'features/mission/domain/usescases/mission_uses_cases.dart';
import 'core/routes/app_routes.dart';
import 'features/splash/presentation/splash_screen.dart';
import 'firebase_options.dart';

void main() async {
  // 1. PRIMERO inicializamos el binding (Obligatorio para Firebase y servicios)
  WidgetsFlutterBinding.ensureInitialized();

  // 2. DESPUÉS inicializamos Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 3. Inicializamos dependencias
  final missionRepo = MissionRepositoryImpl();
  final missionUseCases = MissionUseCases(missionRepo);

  runApp(
    // Inyectamos el UseCase de forma global para que AppRoutes pueda usarlo
    Provider<MissionUseCases>.value(
      value: missionUseCases,
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
      // Usamos onGenerateRoute para que el ID de la ruta sea dinámico
      onGenerateRoute: AppRoutes.onGenerateRoute,
      home: const SplashScreen(),
    );
  }
}