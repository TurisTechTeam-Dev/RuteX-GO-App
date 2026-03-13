import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/Bars/toppAppBarr.dart';

class MonumentInfoScreen extends StatefulWidget {
  const MonumentInfoScreen({super.key});

  @override
  State<MonumentInfoScreen> createState() => _MonumentInfoScreenState();
}

class _MonumentInfoScreenState extends State<MonumentInfoScreen> {
  bool mostrarMas = false;

  @override
  Widget build(BuildContext context) {
    // Extraemos los argumentos que enviamos desde el escáner
    final Map<String, dynamic> data =
    ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final punto = data['punto'];
    final mision = data['mision'];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const TopAppBar(showBack: true),
      endDrawer: const CustomDrawer(),

      body: SingleChildScrollView(
        child: Column(
          children: [

            // Línea superior
            Container(
              height: 2,
              color: AppColors.negroTexto,
            ),

            // IMAGEN FULL WIDTH
            Image.asset(
              "assets/anfiteatro_romano.jpg",
              width: double.infinity,
              height: 240,
              fit: BoxFit.cover,
            ),

            const SizedBox(height: 25),

            // NOMBRE DEL MONUMENTO (FUERA DE LA CARD)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                punto['nombre'] ?? "Sin nombre",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.negroTexto,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // CARD SOLO CON DESCRIPCIÓN
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppColors.negroTexto, width: 2),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(2, 4),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      punto['descripcion'] ??
                          "No hay descripción disponible.",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        height: 1.6,
                      ),
                      maxLines: mostrarMas ? null : 5,
                      overflow: mostrarMas
                          ? TextOverflow.visible
                          : TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 10),

                    GestureDetector(
                      onTap: () {
                        setState(() {
                          mostrarMas = !mostrarMas;
                        });
                      },
                      child: Text(
                        mostrarMas ? "Mostrar menos" : "Mostrar más",
                        style: const TextStyle(
                          color: AppColors.verdePrincipal,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // BOTÓN EMPEZAR MISIÓN
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.verdePrincipal,
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.quiz,
                      arguments: mision,
                    );
                  },
                  child: const Text(
                    "EMPEZAR MISIÓN",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),

      bottomNavigationBar: Container(
        height: 60,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: AppColors.negroTexto, width: 2),
          ),
        ),
        child: const SafeArea(child: SizedBox()),
      ),
    );
  }
}