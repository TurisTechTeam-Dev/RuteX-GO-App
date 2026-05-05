/*
  -----------------------------------------------------------------------------
  Proyecto: RuteX Go
  Desarrollado por: TurisTechTeam
  Descripción: Esta aplicación y su código fuente son propiedad intelectual de
  TurisTechTeam. Queda prohibida su copia, distribución o uso no autorizado.
  Año: 2026
  -----------------------------------------------------------------------------
*/
import 'route_result_args.dart';
import '../quiz_route_progress.dart';

class RouteResultData {
  final String routeName;
  final int previousBestScore;
  final int savedBestScore;
  final int attemptScore;
  final int visitedMonuments;
  final int totalPois;
  final int totalPossiblePoints;
  final int correctAnswers;
  final int totalAnswers;
  final String time;
  final List<AnswerResultData> answerResults;
  final List<String> skippedPois;
  final List<String> visitedPoiNames;

  const RouteResultData({
    required this.routeName,
    required this.previousBestScore,
    required this.savedBestScore,
    required this.attemptScore,
    required this.visitedMonuments,
    required this.totalPois,
    required this.totalPossiblePoints,
    required this.correctAnswers,
    required this.totalAnswers,
    required this.time,
    required this.answerResults,
    required this.skippedPois,
    required this.visitedPoiNames,
  });

  factory RouteResultData.fromArgs(RouteResultArgs args) {
    return RouteResultData(
      routeName: args.routeName,
      previousBestScore: args.previousBestScore,
      savedBestScore: args.savedBestScore,
      attemptScore: args.attemptScore,
      visitedMonuments: args.visitedPois,
      totalPois: args.totalPois,
      totalPossiblePoints: args.totalPossiblePoints,
      correctAnswers: args.correctAnswers,
      totalAnswers: args.totalAnswers,
      time: args.elapsedTimeLabel,
      answerResults: args.answerResults.map((answer) {
        return AnswerResultData(
          monumentName: answer.monumentName,
          question: answer.question,
          selectedAnswer: answer.selectedAnswer,
          correctAnswer: answer.correctAnswer,
          isCorrect: answer.isCorrect,
        );
      }).toList(),
      skippedPois: args.skippedPois,
      visitedPoiNames: args.visitedPoiNames,
    );
  }

  factory RouteResultData.empty() {
    return const RouteResultData(
      routeName: 'Ruta',
      previousBestScore: 0,
      savedBestScore: 0,
      attemptScore: 0,
      visitedMonuments: 0,
      totalPois: 0,
      totalPossiblePoints: 0,
      correctAnswers: 0,
      totalAnswers: 0,
      time: '--:--',
      answerResults: <AnswerResultData>[],
      skippedPois: <String>[],
      visitedPoiNames: <String>[],
    );
  }

  String get previousBestScoreLabel => '$previousBestScore/$totalPossiblePoints';
  String get visitedPoisLabel => '$visitedMonuments/$totalPois';

  Map<String, List<AnswerResultData>> get groupedAnswers {
    final grouped = <String, List<AnswerResultData>>{};
    for (final answer in answerResults) {
      grouped.putIfAbsent(answer.monumentName, () => <AnswerResultData>[]);
      grouped[answer.monumentName]!.add(answer);
    }
    return grouped;
  }
}

class AnswerResultData {
  final String monumentName;
  final String question;
  final String selectedAnswer;
  final String correctAnswer;
  final bool isCorrect;

  const AnswerResultData({
    required this.monumentName,
    required this.question,
    required this.selectedAnswer,
    required this.correctAnswer,
    required this.isCorrect,
  });
}

class AnswerTextSanitizer {
  static String clean(String text) {
    return text.replaceAll(RegExp(r'<[^>]*>'), '').trim();
  }
}