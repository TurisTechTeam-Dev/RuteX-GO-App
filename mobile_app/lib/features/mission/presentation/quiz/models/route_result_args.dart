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
  });
}
