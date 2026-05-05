/*
  -----------------------------------------------------------------------------
  Proyecto: RuteX Go
  Desarrollado por: TurisTechTeam
  Descripción: Esta aplicación y su código fuente son propiedad intelectual de
  TurisTechTeam. Queda prohibida su copia, distribución o uso no autorizado.
  Año: 2026
  -----------------------------------------------------------------------------
*/
import '../quiz_route_progress.dart';

class RouteResultArgs {
  final String routeId;
  final String routeName;
  final int previousBestScore;
  final int savedBestScore;
  final int attemptScore;
  final int visitedPois;
  final int completedMissions;
  final int totalPois;
  final int totalPossiblePoints;
  final String elapsedTimeLabel;
  final int correctAnswers;
  final int totalAnswers;
  final List<QuizAnswerResult> answerResults;
  final List<String> skippedPois;
  final List<String> visitedPoiNames;

  const RouteResultArgs({
    required this.routeId,
    required this.routeName,
    required this.previousBestScore,
    required this.savedBestScore,
    required this.attemptScore,
    required this.visitedPois,
    required this.completedMissions,
    required this.totalPois,
    required this.totalPossiblePoints,
    required this.elapsedTimeLabel,
    required this.correctAnswers,
    required this.totalAnswers,
    required this.answerResults,
    required this.skippedPois,
    required this.visitedPoiNames,
  });
}