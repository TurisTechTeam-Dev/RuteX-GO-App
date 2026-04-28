import 'package:flutter/material.dart';

class AdminMapExplorer extends StatelessWidget {
  const AdminMapExplorer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Opacity(
              opacity: 0.70,
              child: Image.asset(
                'assets/Mapa_fondo_Extremadura.png',
                fit: BoxFit.contain,
                height: MediaQuery.of(context).size.height * 0.7,
              ),
            ),
            Image.asset('assets/Logo_Color_Rutexgo.png', width: 300),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
