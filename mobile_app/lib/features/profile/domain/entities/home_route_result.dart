/*
  -----------------------------------------------------------------------------
  Proyecto: RuteX Go
  Desarrollado por: TurisTechTeam
  Descripción: Esta aplicación y su código fuente son propiedad intelectual de
  TurisTechTeam. Queda prohibida su copia, distribución o uso no autorizado.
  Año: 2026
  -----------------------------------------------------------------------------
*/
class HomeAnswerResult {
  final String monumentName;
  final String question;
  final String selectedAnswer;
  final String correctAnswer;
  final bool isCorrect;

  const HomeAnswerResult({
    required this.monumentName,
    required this.question,
    required this.selectedAnswer,
    required this.correctAnswer,
    required this.isCorrect,
  });
}

class HomeRouteResult {
  final String routeName;
  final int previousBestScore;
  final int savedBestScore;
  final int attemptScore;
  final int visitedPois;
  final int totalPois;
  final int totalPossiblePoints;
  final int correctAnswers;
  final int totalAnswers;
  final String time;
  final List<HomeAnswerResult> answerResults;
  final List<String> skippedPois;
  final List<String> visitedPoiNames;

  const HomeRouteResult({
    required this.routeName,
    required this.previousBestScore,
    required this.savedBestScore,
    required this.attemptScore,
    required this.visitedPois,
    required this.totalPois,
    required this.totalPossiblePoints,
    required this.correctAnswers,
    required this.totalAnswers,
    required this.time,
    required this.answerResults,
    required this.skippedPois,
    required this.visitedPoiNames,
  });
}