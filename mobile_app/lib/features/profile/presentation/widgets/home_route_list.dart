/*
  -----------------------------------------------------------------------------
  Proyecto: RuteX Go
  Desarrollado por: TurisTechTeam
  Descripción: Esta aplicación y su código fuente son propiedad intelectual de
  TurisTechTeam. Queda prohibida su copia, distribución o uso no autorizado.
  Año: 2026
  -----------------------------------------------------------------------------
*/
import 'package:flutter/material.dart';

import '../../domain/entities/home_route.dart';
import 'home_cards.dart';

class HomeRouteList extends StatelessWidget {
  final List<HomeRoute> routes;

  const HomeRouteList({super.key, required this.routes});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 40),
        itemCount: routes.length,
        itemBuilder: (context, index) {
          final route = routes[index];

          return Column(
            children: [
              HomeRouteCard(
                route: route,
                title: route.name,
                missions: "${route.completedMissions}/${route.totalMissions}",
                date: "Ruta completada",
                obtainedPoints: route.obtainedPoints,
                totalPoints: route.totalPoints,
              ),
              const SizedBox(height: 12),
            ],
          );
        },
      ),
    );
  }
}
