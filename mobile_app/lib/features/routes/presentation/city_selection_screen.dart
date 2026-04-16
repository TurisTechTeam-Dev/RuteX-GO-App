import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/bars/top_app_bar.dart';
import '../../../core/widgets/titles/stroke_title.dart';
import '../domain/usescases/routes_uses_cases.dart';
import 'widgets/city_card.dart';

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
              color: AppColors.blancoPuro,
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
                      if (snapshot.hasError) {
                        return const Center(
                          child: Text("Error al cargar las ciudades"),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text("No hay ciudades disponibles"),
                        );
                      }

                      final docs = snapshot.data!.docs.toList();

                      docs.sort((a, b) {
                        final aActive =
                            ((a.data() as Map<String, dynamic>)['isActive'] ??
                                    false) ==
                                true;
                        final bActive =
                            ((b.data() as Map<String, dynamic>)['isActive'] ??
                                    false) ==
                                true;

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
                          final fallbackImage =
                              "assets/images_selection/${docs[index].id}.jpg";
                          final image = data['imagen']?.toString() ??
                              fallbackImage;

                          return CityCard(
                            title: data['nombre']?.toString() ?? '',
                            image: image,
                            available: data['isActive'] == true,
                            cityId: docs[index].id,
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
}
