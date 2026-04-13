import 'package:flutter/material.dart';
import 'package:mobile_app/core/widgets/cards/custom_cards.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/Bars/toppAppBarr.dart';

class MonumentInfoScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  const MonumentInfoScreen({super.key, required this.data});

  @override
  State<MonumentInfoScreen> createState() => _MonumentInfoScreenState();
}

class _MonumentInfoScreenState extends State<MonumentInfoScreen> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final punto = widget.data['punto'] ?? {};
    final mision = widget.data['mision'] ?? {};
    final routeId = widget.data['routeId']?.toString();
    final totalPois = widget.data['totalPois'];

    final nombre = punto['nombre'] ?? "Monumento";
    final descripcion = punto['descripcion'] ?? "";
    final imagen = punto['imagen'];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const TopAppBar(showBack: true),
      drawer: const CustomDrawer(),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// IMAGEN MONUMENTO
            Container(
              width: double.infinity,
              height: 220,
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.negroTexto, width: 2),
                ),
              ),
              child: imagen != null && imagen.toString().isNotEmpty
                  ? Image.network(
                      imagen,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 80,
                            color: AppColors.verdePrincipal,
                          ),
                        );
                      },
                    )
                  : const Center(
                      child: Icon(
                        Icons.account_balance,
                        size: 80,
                        color: AppColors.verdePrincipal,
                      ),
                    ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      nombre,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.negroTexto,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// CARD DESCRIPCIÓN
                  CustomCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          descripcion,
                          maxLines: expanded ? null : 5,
                          overflow: expanded
                              ? TextOverflow.visible
                              : TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            color: Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 10),

                        /// MOSTRAR MÁS
                        if (descripcion.length > 200)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                expanded = !expanded;
                              });
                            },
                            child: Text(
                              expanded ? "Mostrar menos" : "Mostrar más",
                              style: const TextStyle(
                                color: AppColors.verdePrincipal,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// BOTÓN MISIÓN
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
                        Navigator.pushNamed(
                          context,
                          AppRoutes.quiz,
                          arguments: {
                            'mision': mision,
                            if (routeId != null) 'routeId': routeId,
                            if (totalPois != null) 'totalPois': totalPois,
                          },
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

                  const SizedBox(height: 80),
                ],
              ),
            ),
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
