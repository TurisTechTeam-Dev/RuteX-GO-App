import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/firestore_contract.dart';
import '../../../../core/widgets/cards/custom_cards.dart';

class HomeUserCard extends StatelessWidget {
  final Map<String, dynamic> userData;
  final String rankName;
  final String rankLogo;

  const HomeUserCard({
    super.key,
    required this.userData,
    required this.rankName,
    required this.rankLogo,
  });

  @override
  Widget build(BuildContext context) {
    final explorerLabel = _explorerLabel(userData[UserFields.fechaCreacion]);

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
              Text(
                explorerLabel,
                style: const TextStyle(color: AppColors.grisNeutro),
              ),
              const SizedBox(height: 4),
              _RankLine(rankName: rankName, rankLogo: rankLogo),
            ],
          ),
        ],
      ),
    );
  }

  String _explorerLabel(dynamic createdAt) {
    final createdDate = _dateFromFirestoreValue(createdAt);
    if (createdDate == null) return "Explorador";

    final days = DateTime.now().difference(createdDate).inDays;
    if (days <= 0) return "Explorador desde hoy";
    if (days == 1) return "Explorador desde hace 1 dia";
    if (days < 30) return "Explorador desde hace $days dias";

    final months = days ~/ 30;
    if (months == 1) return "Explorador desde hace 1 mes";
    return "Explorador desde hace $months meses";
  }

  DateTime? _dateFromFirestoreValue(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;

    return null;
  }
}

class _RankLine extends StatelessWidget {
  final String rankName;
  final String rankLogo;

  const _RankLine({required this.rankName, required this.rankLogo});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          "Rango: ",
          style: TextStyle(color: AppColors.verdePrincipal),
        ),
        Text(
          rankName,
          style: const TextStyle(
            color: AppColors.verdePrincipal,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (rankLogo.isNotEmpty) ...[
          const SizedBox(width: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.network(
              rankLogo,
              width: 22,
              height: 22,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => const Icon(
                Icons.emoji_events,
                size: 20,
                color: AppColors.verdePrincipal,
              ),
            ),
          ),
        ],
      ],
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
