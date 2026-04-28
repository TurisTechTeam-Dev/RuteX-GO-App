import 'package:flutter/material.dart';
import 'package:mobile_app/features/admin_panel/data/admin_remote_datasource.dart';

class AdminMapExplorer extends StatelessWidget {
  final AdminRemoteDataSource dataSource;

  const AdminMapExplorer({super.key, required this.dataSource});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Opacity(
              opacity: 0.70, // Keep the background subtle behind the forms.
              child: Image.asset(
                'assets/Mapa_fondo_Extremadura.png',
                fit: BoxFit.contain,

                height: MediaQuery.of(context).size.height * 0.7,
              ),
            ),

            Image.asset(
              'assets/Logo_Color_Rutexgo.png',
              width: 300, // Ajusta el tamaño según tu logo
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
