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
import '../../../../core/widgets/cards/custom_cards.dart';
import '../../../../core/widgets/images/storage_aware_image.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/entities/home_route.dart';
import '../../domain/entities/home_route_result.dart';
import '../../../mission/presentation/quiz/models/route_result_data.dart';
import '../../../mission/presentation/quiz/widgets/route_result_panel.dart';

class HomeUserCard extends StatelessWidget {
  final UserProfile user;
  final String rankName;
  final String rankLogo;
  final bool preferOfflineFallback;

  const HomeUserCard({
    super.key,
    required this.user,
    required this.rankName,
    required this.rankLogo,
    this.preferOfflineFallback = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final explorerLabel = _explorerLabel(user.createdAt);
    final displayName = user.username.isNotEmpty ? user.username : user.name;

    return CustomCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _UserAvatar(
            avatarUrl: user.avatarUrl,
            preferOfflineFallback: preferOfflineFallback,
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                explorerLabel,
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.68),
                ),
              ),
              const SizedBox(height: 4),
              _RankLine(
                rankName: rankName,
                rankLogo: rankLogo,
                preferOfflineFallback: preferOfflineFallback,
              ),
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
  final bool preferOfflineFallback;

  const _UserAvatar({
    required this.avatarUrl,
    required this.preferOfflineFallback,
  });

  @override
  Widget build(BuildContext context) {
    const fallback = CircleAvatar(
      radius: 30,
      backgroundColor: AppColors.verdePrincipal,
      child: Icon(Icons.person, color: AppColors.blancoPuro),
    );

    if (avatarUrl.isEmpty ||
        (preferOfflineFallback && !_isAssetPath(avatarUrl))) {
      return fallback;
    }

    return ClipOval(
      child: StorageAwareImage(
        source: avatarUrl,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        placeholder: const _AvatarLoadingState(),
        fallback: fallback,
      ),
    );
  }

  bool _isAssetPath(String value) {
    return value.trim().startsWith('assets/');
  }
}

class _AvatarLoadingState extends StatelessWidget {
  const _AvatarLoadingState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      color: AppColors.blancoTarjeta,
      alignment: Alignment.center,
      child: const SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.4,
          color: AppColors.verdePrincipal,
        ),
      ),
    );
  }
}

class _RankLine extends StatelessWidget {
  final String rankName;
  final String rankLogo;
  final bool preferOfflineFallback;

  const _RankLine({
    required this.rankName,
    required this.rankLogo,
    required this.preferOfflineFallback,
  });

  @override
  Widget build(BuildContext context) {
    final rankContent = _buildRankContent(context);

    return Row(mainAxisSize: MainAxisSize.min, children: rankContent);
  }

  List<Widget> _buildRankContent(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final badgeBackground = isDark
        ? theme.colorScheme.onSurface.withValues(alpha: 0.82)
        : Colors.transparent;
    final badgeBorder = isDark
        ? theme.colorScheme.onSurface.withValues(alpha: 0.70)
        : AppColors.negroTexto;
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

    final canShowRankLogo =
        rankLogo.isNotEmpty &&
        (!preferOfflineFallback || _isAssetPath(rankLogo));

    if (canShowRankLogo) {
      content.add(const SizedBox(width: 6));
      content.add(
        Container(
          width: 30,
          height: 30,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: badgeBackground,
            shape: BoxShape.circle,
            border: Border.all(color: badgeBorder, width: 1.4),
          ),
          child: ClipOval(
            child: StorageAwareImage(
              source: rankLogo,
              width: 22,
              height: 22,
              fit: BoxFit.contain,
              fallback: const SizedBox.shrink(),
            ),
          ),
        ),
      );
    }

    return content;
  }

  bool _isAssetPath(String value) {
    return value.trim().startsWith('assets/');
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
          Text(
            "Rutas completadas: $completedRoutes",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            "Misiones completadas: $completedMissions/$totalMissions",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            "Puntos totales: $totalPoints",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class HomeRouteCard extends StatelessWidget {
  final HomeRoute route;
  final String title;
  final String missions;
  final String date;
  final int obtainedPoints;
  final int totalPoints;

  const HomeRouteCard({
    super.key,
    required this.route,
    required this.title,
    required this.missions,
    required this.date,
    required this.obtainedPoints,
    required this.totalPoints,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => _openResult(context),
      child: CustomCard(
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
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.56),
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
      ),
    );
  }

  void _openResult(BuildContext context) {
    final result = route.result;
    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Esta ruta todavia no tiene resultado guardado.'),
        ),
      );
      return;
    }

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 24,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: RouteResultPanel(
              result: _routeResultData(result),
              finishLabel: 'Cerrar',
              showPreviousBestScore: false,
              onFinish: () => Navigator.pop(dialogContext),
            ),
          ),
        );
      },
    );
  }

  RouteResultData _routeResultData(HomeRouteResult result) {
    return RouteResultData(
      routeName: result.routeName,
      previousBestScore: result.previousBestScore,
      savedBestScore: result.savedBestScore,
      attemptScore: result.attemptScore,
      visitedMonuments: result.visitedPois,
      totalPois: result.totalPois,
      totalPossiblePoints: result.totalPossiblePoints,
      correctAnswers: result.correctAnswers,
      totalAnswers: result.totalAnswers,
      time: result.time,
      answerResults: result.answerResults.map(_answerResultData).toList(),
      skippedPois: result.skippedPois,
    );
  }

  AnswerResultData _answerResultData(HomeAnswerResult answer) {
    return AnswerResultData(
      monumentName: answer.monumentName,
      question: answer.question,
      selectedAnswer: answer.selectedAnswer,
      correctAnswer: answer.correctAnswer,
      isCorrect: answer.isCorrect,
    );
  }
}
