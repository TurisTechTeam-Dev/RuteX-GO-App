import '../../quiz/quiz_route_progress.dart';

class RouteCompletionSummary {
  final int currentAttemptPoints;
  final int previousBestPoints;
  final int savedBestPoints;
  final int visitedPois;
  final int completedMissions;
  final int totalPois;
  final int totalPossiblePoints;
  final int correctAnswers;
  final int totalAnswers;
  final String routeName;
  final Duration elapsedTime;
  final List<QuizAnswerResult> answerResults;
  final List<String> skippedPoiNames;

  const RouteCompletionSummary({
    required this.currentAttemptPoints,
    required this.previousBestPoints,
    required this.savedBestPoints,
    required this.visitedPois,
    required this.completedMissions,
    required this.totalPois,
    required this.totalPossiblePoints,
    required this.correctAnswers,
    required this.totalAnswers,
    required this.routeName,
    required this.elapsedTime,
    required this.answerResults,
    required this.skippedPoiNames,
  });
}
