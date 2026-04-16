import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/backgrounds/extremadura_map_background.dart';
import '../../../../core/widgets/titles/stroke_title.dart';
import '../../data/home_data.dart';
import '../../data/home_summary.dart';
import 'home_cards.dart';
import 'home_route_list.dart';

class HomeContent extends StatelessWidget {
  final HomeData data;

  const HomeContent({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final summary = HomeSummary.fromHomeData(data);

    return Stack(
      children: [
        const ExtremaduraMapBackground(),
        SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 2, color: AppColors.negroTexto),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HomeUserCard(
                      userData: data.user,
                      rankName: summary.rankName,
                    ),
                    const SizedBox(height: 20),
                    const StrokeTitle(text: "Estadísticas"),
                    const SizedBox(height: 12),
                    HomeStatsCard(
                      completedRoutes: summary.completedRoutes,
                      completedMissions: summary.completedMissions,
                      totalMissions: summary.totalMissions,
                      totalPoints: summary.totalPoints,
                    ),
                    const SizedBox(height: 20),
                    const StrokeTitle(text: "Rutas Completadas"),
                  ],
                ),
              ),
              Expanded(child: HomeRouteList(routes: data.routes)),
              Container(height: 2, color: AppColors.negroTexto),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ],
    );
  }
}
