import 'package:flutter/material.dart';
import 'package:mobile_app/core/constants/app_colors.dart';
import 'package:mobile_app/core/widgets/Bars/toppAppBarr.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/cards/custom_cards.dart';
import '../../profile/presentation/home_screen.dart';

class RouteSelectionScreen extends StatelessWidget {
  const RouteSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopAppBar(showBack: true),
      endDrawer: const CustomDrawer(),

      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: AppColors.blancoPuro,
              image: DecorationImage(
                image: AssetImage('assets/Mapa_Fondo_Extremadura.jpeg'),
                opacity: 0.4,
                fit: BoxFit.contain,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Container(height: 2, color: AppColors.negroTexto),

                const SizedBox(height: 20),

                const StrokeTitle(text: "Rutas en Mérida"),

                const SizedBox(height: 20),

                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      _routeCard(
                        context,
                        image: "assets/merida_monumental.png",
                        title: "Ruta Monumental Romana",
                        description: "Teatro, Anfiteatro, Circo Romano",
                        difficulty: "Fácil",
                        time: "2 h",
                        distance: "3 km",
                      ),

                      _routeCard(
                        context,
                        image: "assets/merida_cotidiana.png",
                        title: "Ruta Roma Cotidiana",
                        description:
                            "Templo de Diana, Foro Romano, Casa Mitreo",
                        difficulty: "Fácil",
                        time: "1.5 h",
                        distance: "1 km",
                      ),

                      _routeCard(
                        context,
                        image: "assets/merida_vidafe.jpg",
                        title: "Ruta Vida y Fe",
                        description:
                            "Basílica de Santa Eulalia, Cripta de Santa Eulalia, Alcazaba Árabe",
                        difficulty: "Fácil",
                        time: "2 h",
                        distance: "1,5 km",
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      bottomNavigationBar: Container(
        height: 10,
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

Widget _routeCard(
  BuildContext context, {
  required String image,
  required String title,
  required String description,
  required String difficulty,
  required String time,
  required String distance,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 20),

    child: CustomCard(
      padding: const EdgeInsets.all(12),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // IMAGEN
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.negroTexto, width: 1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Image.asset(image, fit: BoxFit.cover),
              ),
            ),
          ),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.account_balance,
                color: AppColors.verdePrincipal,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  textAlign: TextAlign.center,
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.negroTexto,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Text(description, style: Theme.of(context).textTheme.labelMedium),

          const SizedBox(height: 10),

          Wrap(
            spacing: 10,
            runSpacing: 6,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.extension,
                    size: 18,
                    color: AppColors.verdePrincipal,
                  ),
                  const SizedBox(width: 4),
                  Text("Dificultad: $difficulty"),
                ],
              ),

              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.access_time,
                    size: 18,
                    color: AppColors.verdePrincipal,
                  ),
                  const SizedBox(width: 4),
                  Text("Tiempo: $time"),
                ],
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.route,
                    size: 18,
                    color: AppColors.verdePrincipal,
                  ),
                  const SizedBox(width: 4),
                  Text("Distancia: $distance"),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            height: 36,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.verdePrincipal,
                foregroundColor: AppColors.blancoPuro,
              ),
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.missionQrScanner);
              },
              child: const Text("Comenzar ruta"),
            ),
          ),
        ],
      ),
    ),
  );
}
