import 'package:flutter/material.dart';

import '../../../core/widgets/bars/top_app_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopAppBar(showBack: false),
      endDrawer: const CustomDrawer(),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/Mapa_fondo_Extremadura.png'),
                opacity: 0.4,
                fit: BoxFit.contain,
              ),
            ),
          ),

          SafeArea(
            child: Column(
                children: [
                  Container(height: 2, color: Colors.black),
                  const SizedBox(height: 20),
                  const Text(
                    "Perfil de Usuario",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Nombre de Usuario",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Correo Electrónico",
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
          )
        ],
      )
    );
  }
}
