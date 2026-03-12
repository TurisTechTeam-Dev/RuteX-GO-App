import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/Bars/toppAppBarr.dart';
import '../../../core/widgets/cards/custom_cards.dart';
import '../../profile/presentation/home_screen.dart';

class CitySelectionScreen extends StatelessWidget {
  const CitySelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopAppBar(showBack: true),
      endDrawer: const CustomDrawer(),

      body: Stack(
        children: [
          // FONDO
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/Mapa_fondo_Extremadura.png'),
                opacity: 0.4,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // CONTENIDO
          SafeArea(
            child: Column(
              children: [
                Container(height: 2, color: AppColors.negroTexto),

                const SizedBox(height: 20),

                const StrokeTitle(text: "Selecciona una ciudad"),

                const SizedBox(height: 6),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Text(
                    "Explora el patrimonio histórico de Extremadura",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),

                const SizedBox(height: 20),

                // GRID SCROLLABLE
                Expanded(
                  child: GridView.count(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.72,
                    children: [
                      _cityCard(
                        context,
                        title: "Mérida",
                        image: "assets/images_selection/merida.jpg",
                        available: true,
                      ),

                      _cityCard(
                        context,
                        title: "Cáceres",
                        image: "assets/images_selection/caceres.jpg",
                        available: false,
                      ),

                      _cityCard(
                        context,
                        title: "Badajoz",
                        image: "assets/images_selection/badajoz.jpg",
                        available: false,
                      ),

                      _cityCard(
                        context,
                        title: "Trujillo",
                        image: "assets/images_selection/trujillo.jpg",
                        available: false,
                      ),

                      _cityCard(
                        context,
                        title: "Coria",
                        image: "assets/images_selection/coria.jpg",
                        available: false,
                      ),

                      _cityCard(
                        context,
                        title: "Jaraíz de la Vera",
                        image: "assets/images_selection/jarais.jpg",
                        available: false,
                      ),

                      const SizedBox(height: 60),
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

  // CITY CARD
  Widget _cityCard(
    BuildContext context, {
    required String title,
    required String image,
    required bool available,
  }) {
    return CustomCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // Imagen
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

          const SizedBox(height: 8),

          // Título
          StrokeCityTitle(text: title),

          const SizedBox(height: 6),

          // Estado
          Text(
            available ? "Rutas disponibles: 3" : "Próximamente",
            style: Theme.of(context).textTheme.labelMedium,
          ),

          const Spacer(),

          SizedBox(
            height: 32,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: available
                    ? AppColors.verdePrincipal
                    : AppColors.grisSombra,
                foregroundColor: AppColors.blancoPuro,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                textStyle: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              onPressed: available
                  ? () {
                      Navigator.pushNamed(context, AppRoutes.routeSelection);
                    }
                  : null,
              child: const Text("Explorar"),
            ),
          ),
        ],
      ),
    );
  }
}

// TITULO CON BORDE (CIUDADES)

class StrokeCityTitle extends StatelessWidget {
  final String text;

  const StrokeCityTitle({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 0.8
              ..color = AppColors.verdePrincipal,
          ),
        ),
        Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.negroTexto,
          ),
        ),
      ],
    );
  }
}
