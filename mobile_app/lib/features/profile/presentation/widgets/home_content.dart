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

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/backgrounds/extremadura_map_background.dart';
import '../../../../core/widgets/titles/stroke_title.dart';
import '../../domain/entities/home_data.dart';
import '../models/home_summary.dart';
import 'home_cards.dart';
import 'home_route_list.dart';

class HomeContent extends StatelessWidget {
  final HomeData data;
  final bool showOfflineBanner;

  const HomeContent({
    super.key,
    required this.data,
    this.showOfflineBanner = false,
  });

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
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showOfflineBanner) ...[
                      const _InlineOfflineBanner(),
                      const SizedBox(height: 12),
                    ],
                    HomeUserCard(
                      user: data.user,
                      rankName: summary.rankName,
                      rankLogo: summary.rankLogo,
                      preferOfflineFallback: showOfflineBanner,
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
              Container(
                height: 2,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ],
    );
  }
}

class _InlineOfflineBanner extends StatelessWidget {
  const _InlineOfflineBanner();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label: 'Modo sin conexión. Mostrando datos guardados.',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.verdePrincipal,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: const Row(
          children: [
            Icon(Icons.wifi_off, color: Colors.white, size: 18),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Modo sin conexión',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
