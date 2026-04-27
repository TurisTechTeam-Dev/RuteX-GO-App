import 'package:flutter/material.dart';
import 'package:mobile_app/features/admin_panel/data/admin_remote_datasource.dart';

class AdminMapExplorer extends StatelessWidget {
  final AdminRemoteDataSource dataSource;

  const AdminMapExplorer({super.key, required this.dataSource});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Para que tome el color del panel
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 1. Imagen del Mapa de Fondo (Extremadura)
            Opacity(
              opacity:
                  0.70, // Ajusta esto para que no distraiga de los formularios
              child: Image.asset(
                'assets/Mapa_fondo_Extremadura.png',
                fit: BoxFit.contain,
                // Si la imagen es muy grande, puedes limitarla con un Container o SizedBox
                height: MediaQuery.of(context).size.height * 0.7,
              ),
            ),

            // 2. Logo de la Empresa (Frontal)
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
