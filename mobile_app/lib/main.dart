import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mobile_app/features/auth/presentation/LoginScreen.dart';
import 'package:mobile_app/features/profile/presentation/HomeScreen.dart';
import 'package:mobile_app/features/splash/presentation/SplashScreen.dart';
import 'firebase_options.dart';
import 'core/routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const RutexApp());
}

class RutexApp extends StatelessWidget {
  const RutexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RutexGo',
      theme: ThemeData(useMaterial3: true, primarySwatch: Colors.deepPurple),
      routes: AppRoutes.getRoutes(),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, estadoSesion){
          if(estadoSesion.connectionState == ConnectionState.waiting){
            return const SplashScreen();
          }

          if(estadoSesion.hasData){
            return const HomeScreen();
          }

          return const LoginScreen();
        }



          ),
    );
  }
}
