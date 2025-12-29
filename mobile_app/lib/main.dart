import 'package:flutter/material.dart';

void main() => runApp(const RutexApp());

class RutexApp extends StatelessWidget {
  const RutexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
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

// Widget que podrás reutilizar en el Login y otras pantallas
class FondoConMapa extends StatelessWidget {
  final Widget child;

  const FondoConMapa({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Capa inferior: El mapa de Extremadura
        Center(
          child: Image.asset(
            'assets/Mapa Fondo Extremadura.jpeg',
            fit: BoxFit.contain,
          ),
        ),
        // Capa superior: Lo que pongas dentro (en este caso, el logo)
        Center(child: child),
      ],
    );
  }
}