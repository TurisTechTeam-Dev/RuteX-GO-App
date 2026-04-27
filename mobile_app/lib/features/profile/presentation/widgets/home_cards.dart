import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/cards/custom_cards.dart';
import '../../../../core/widgets/images/storage_aware_image.dart';
import '../../domain/entities/user_profile.dart';

class HomeUserCard extends StatelessWidget {
  final UserProfile user;
  final String rankName;
  final String rankLogo;

  const HomeUserCard({
    super.key,
    required this.user,
    required this.rankName,
    required this.rankLogo,
  });

  @override
  Widget build(BuildContext context) {
    final explorerLabel = _explorerLabel(user.createdAt);
    final displayName = user.username.isNotEmpty ? user.username : user.name;

    return CustomCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _UserAvatar(avatarUrl: user.avatarUrl),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayName,
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

  String _explorerLabel(DateTime? createdAt) {
    if (createdAt == null) return "Explorador";

    final days = DateTime.now().difference(createdAt).inDays;
    if (days <= 0) return "Explorador desde hoy";
    if (days == 1) return "Explorador desde hace 1 día";
    if (days < 30) return "Explorador desde hace $days días";

    final months = days ~/ 30;
    if (months == 1) return "Explorador desde hace 1 mes";
    return "Explorador desde hace $months meses";
  }
}

class _UserAvatar extends StatelessWidget {
  final String avatarUrl;

  const _UserAvatar({required this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    if (avatarUrl.isEmpty) {
      return const CircleAvatar(
        radius: 30,
        backgroundColor: AppColors.verdePrincipal,
        child: Icon(Icons.person, color: AppColors.blancoPuro),
      );
    }

    return ClipOval(
      child: StorageAwareImage(
        source: avatarUrl,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        fallback: const CircleAvatar(
          radius: 30,
          backgroundColor: AppColors.verdePrincipal,
          child: Icon(Icons.person, color: AppColors.blancoPuro),
        ),
      ),
    );
  }
}

class _RankLine extends StatelessWidget {
  final String rankName;
  final String rankLogo;

  const _RankLine({required this.rankName, required this.rankLogo});

  @override
  Widget build(BuildContext context) {
    final rankContent = _buildRankContent();

    return Row(mainAxisSize: MainAxisSize.min, children: rankContent);
  }

  List<Widget> _buildRankContent() {
    final content = <Widget>[
      const Text("Rango: ", style: TextStyle(color: AppColors.verdePrincipal)),
      Text(
        rankName,
        style: const TextStyle(
          color: AppColors.verdePrincipal,
          fontWeight: FontWeight.w600,
        ),
      ),
    ];

    if (rankLogo.isNotEmpty) {
      content.add(const SizedBox(width: 6));
      content.add(
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: StorageAwareImage(
            source: rankLogo,
            width: 22,
            height: 22,
            fit: BoxFit.contain,
            fallback: const Icon(
              Icons.emoji_events,
              size: 20,
              color: AppColors.verdePrincipal,
            ),
          ),
        ),
      );
    }

    return content;
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
