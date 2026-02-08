import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; //
import 'firebase_options.dart'; //

void main() async {
  // Asegura que los bindings de Flutter estén listos
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Inicialización oficial de Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Mensaje de éxito en la consola de Android Studio
    print("----------------------------------------------------------");
    print("¡CONEXIÓN EXITOSA: RutexGo ya está hablando con Firebase!");
    print("----------------------------------------------------------");
  } catch (e) {
    // Mensaje en caso de error de red o configuración
    print("----------------------------------------------------------");
    print("ERROR AL CONECTAR CON FIREBASE: $e");
    print("----------------------------------------------------------");
  }

  runApp(const RutexApp());
}

class RutexApp extends StatelessWidget {
  const RutexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RutexGo',
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF7F7F7),
      body: FondoConMapa(
        child: Image(
          image: AssetImage('assets/logos finales rutexgo1.2.png'),
          width: 300, // Tamaño del logo centrado
        ),
      ),
    );
  }
}

// Widget reutilizable para mantener la estética del mapa de fondo
class FondoConMapa extends StatelessWidget {
  final Widget child;

  const FondoConMapa({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Capa inferior: El mapa de Extremadura centrado
        Center(
          child: Image.asset(
            'assets/Mapa Fondo Extremadura.jpeg',
            fit: BoxFit.contain,
          ),
        ),
        // Capa superior: El contenido (Logo, botones de login, etc.)
        Center(child: child),
      ],
    );
  }
}