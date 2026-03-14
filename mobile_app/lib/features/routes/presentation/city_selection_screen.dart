import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/Bars/toppAppBarr.dart';
import '../../../core/widgets/cards/custom_cards.dart';
import '../../profile/presentation/home_screen.dart';
import '../domain/usescases/routes_uses_cases.dart';

class CitySelectionScreen extends StatelessWidget {
  final RoutesUsesCases routesUsesCases;

  const CitySelectionScreen({super.key, required this.routesUsesCases});

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

                // GRID DINÁMICO
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: routesUsesCases.executeGetCiudades(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text("No hay ciudades disponibles"),
                        );
                      }

                      final docs = snapshot.data!.docs;

                      docs.sort((a, b) {
                        final aActive =
                            (a.data() as Map<String, dynamic>)['isActive'] ??
                            false;
                        final bActive =
                            (b.data() as Map<String, dynamic>)['isActive'] ??
                            false;

                        if (aActive == bActive) return 0;
                        return aActive ? -1 : 1;
                      });

                      return GridView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.72,
                            ),
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final data =
                              docs[index].data() as Map<String, dynamic>;
                          return _cityCard(
                            context,
                            title: data['nombre'] ?? '',
                            image:
                                data['imagen'] ??
                                "assets/images_selection/${docs[index].id}.jpg",
                            available: data['isActive'] ?? false,
                            idCiudad: docs[index].id,
                            routesCount:
                                data['rutas_count'] ??
                                0, // Cogemos el ID real de Firestore
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
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

  Widget _cityCard(
    BuildContext context, {
    required String title,
    required String image,
    required bool available,
    required String idCiudad,
    required int routesCount,
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
                child: image.startsWith('http')
                    ? Image.network(image, fit: BoxFit.cover)
                    : Image.asset(image, fit: BoxFit.cover),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Título
          StrokeCityTitle(text: title),

          const SizedBox(height: 6),

          // Contador de rutas REAL desde Firestore
          available
              ? StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("rutas")
                      .where("id_ciudad", isEqualTo: idCiudad)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Text(
                        "...",
                        style: Theme.of(context).textTheme.labelMedium,
                      );
                    }

                    final rutasCount = snapshot.data!.docs.length;

                    return Text(
                      "$rutasCount rutas disponibles",
                      style: Theme.of(context).textTheme.labelMedium,
                    );
                  },
                )
              : Text(
                  "Próximamente",
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
                      Navigator.pushNamed(
                        context,
                        AppRoutes.routeSelection,
                        arguments: idCiudad,
                      );
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

// Mantengo tu widget StrokeCityTitle tal cual lo pasaste
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
