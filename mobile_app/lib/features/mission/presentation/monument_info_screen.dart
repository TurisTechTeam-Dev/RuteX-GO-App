import 'package:flutter/material.dart';
import 'package:mobile_app/core/widgets/cards/custom_cards.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/Bars/toppAppBarr.dart';

class MonumentInfoScreen extends StatefulWidget {
  const MonumentInfoScreen({super.key});

  @override
  State<MonumentInfoScreen> createState() => _MonumentInfoScreenState();
}

class _MonumentInfoScreenState extends State<MonumentInfoScreen> {
  // Controla si la descripción está expandida o no
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
      drawer: const CustomDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Imagen del monumento (si tenéis la URL en Firebase)
            // Si no, podemos usar un icono temporal
            const SizedBox(height: 20),

            CustomCard(
              child: const Icon(
                Icons.account_balance,
                size: 100,
                color: AppColors.verdePrincipal,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //nombre del monumento
                  Center(
                    child: SizedBox(
                      width: 280, // ancho de la card
                      child: CustomCard(
                        child: Text(
                          punto['nombre'] ?? 'Sin nombre',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.negroTexto,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Descripción del monumento con "Mostrar más"
                  CustomCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          punto['descripcion'] ??
                              'No hay descripción disponible.',
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            height: 1.5,
                          ),

                          // Mostramos solo 5 líneas si no está expandido
                          maxLines: mostrarMas ? null : 5,
                          overflow: mostrarMas
                              ? TextOverflow.visible
                              : TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 8),

                        // Botón mostrar más / menos
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

                  const SizedBox(height: 40),

                  // Botón para empezar el Quiz (Misión)
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.verdePrincipal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: () {
                        // Navegamos al Quiz pasando los datos de la misión
                        Navigator.pushNamed(
                          context,
                          AppRoutes.quiz,
                          arguments: mision,
                        );
                      },
                      child: const Text(
                        "EMPEZAR MISIÓN",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // Espacio extra para que el botón no quede debajo
                  // de la barra de navegación del móvil
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
