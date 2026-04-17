import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/backgrounds/extremadura_map_background.dart';
import '../../../../core/widgets/titles/stroke_title.dart';
import '../../domain/usecases/routes_use_cases.dart';
import '../models/city_item.dart';
import 'city_card.dart';

class CitySelectionContent extends StatelessWidget {
  final RoutesUseCases routesUseCases;

  const CitySelectionContent({super.key, required this.routesUseCases});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const ExtremaduraMapBackground(),
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
              Expanded(child: _CityGrid(routesUseCases: routesUseCases)),
            ],
          ),
        ),
      ],
    );
  }
}

class _CityGrid extends StatelessWidget {
  final RoutesUseCases routesUseCases;

  const _CityGrid({required this.routesUseCases});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: routesUseCases.executeGetCiudades(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text("Error al cargar las ciudades"));
        }

        final docs = snapshot.data?.docs.toList() ?? [];

        if (docs.isEmpty) {
          return const Center(child: Text("No hay ciudades disponibles"));
        }

        final cities = docs.map(CityItem.fromDoc).toList()
          ..sort((a, b) {
            if (a.available == b.available) return 0;
            return a.available ? -1 : 1;
          });

        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.72,
          ),
          itemCount: cities.length,
          itemBuilder: (context, index) {
            final city = cities[index];

            return CityCard(
              city: city,
              routesStream: routesUseCases.executeGetRutasByCiudad(city.id),
            );
          },
        );
      },
    );
  }
}
