import 'package:flutter/material.dart';

import '../../../../../core/widgets/backgrounds/extremadura_map_background.dart';
import '../../../../../core/widgets/bars/top_app_bar.dart';

class ResultViewScreen extends StatelessWidget {
  const ResultViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopAppBar(showBack: true),
      endDrawer: const CustomDrawer(),
      body: Stack(
        children: [
          const ExtremaduraMapBackground(),
          SafeArea(
            child: Column(
              children: [
                Container(height: 2, color: Colors.black),
                const SizedBox(height: 20),
                const Text(
                  "Resultados",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Nombre de usuario",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 5),
                Text(
                  "Correo electrónico",
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
