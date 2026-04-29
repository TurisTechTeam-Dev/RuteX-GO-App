class RouteAnswerResultRecord {
  final String monumentName;
  final String question;
  final String selectedAnswer;
  final String correctAnswer;
  final bool isCorrect;

  const RouteAnswerResultRecord({
    required this.monumentName,
    required this.question,
    required this.selectedAnswer,
    required this.correctAnswer,
    required this.isCorrect,
  });
}

class RouteResultRecord {
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
  final List<RouteAnswerResultRecord> answerResults;
  final List<String> skippedPois;

  const RouteResultRecord({
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
