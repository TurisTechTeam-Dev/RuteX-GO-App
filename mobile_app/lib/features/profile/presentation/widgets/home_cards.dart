import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/cards/custom_cards.dart';

class HomeUserCard extends StatelessWidget {
  final Map<String, dynamic> userData;
  final String rankName;

  const HomeUserCard({
    super.key,
    required this.userData,
    required this.rankName,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.verdePrincipal,
            child: Icon(Icons.person, color: AppColors.blancoPuro),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userData['nombre'] ?? 'Sin nombre',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.negroTexto,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Explorador novato",
                style: TextStyle(color: AppColors.grisNeutro),
              ),
              const SizedBox(height: 4),
              Text(
                "Rango: $rankName",
                style: const TextStyle(color: AppColors.verdePrincipal),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class HomeStatsCard extends StatelessWidget {
  final int completedRoutes;
  final int completedMissions;
  final int totalMissions;
  final int totalPoints;

  const HomeStatsCard({
    super.key,
    required this.completedRoutes,
    required this.completedMissions,
    required this.totalMissions,
    required this.totalPoints,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Rutas completadas: $completedRoutes"),
          const SizedBox(height: 6),
          Text("Misiones completadas: $completedMissions/$totalMissions"),
          const SizedBox(height: 6),
          Text("Puntos totales: $totalPoints"),
        ],
      ),
    );
  }
}

class HomeRouteCard extends StatelessWidget {
  final String title;
  final String missions;
  final String date;
  final int obtainedPoints;
  final int totalPoints;

  const HomeRouteCard({
    super.key,
    required this.title,
    required this.missions,
    required this.date,
    required this.obtainedPoints,
    required this.totalPoints,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, color: AppColors.verdePrincipal),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.negroTexto,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.track_changes, size: 18),
              const SizedBox(width: 6),
              Text("Misiones completadas: $missions"),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 18),
              const SizedBox(width: 6),
              Text(date),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.emoji_events, size: 18),
              const SizedBox(width: 6),
              Text("Puntos obtenidos: $obtainedPoints / $totalPoints"),
            ],
          ),
        ],
      ),
    );
  }
}
