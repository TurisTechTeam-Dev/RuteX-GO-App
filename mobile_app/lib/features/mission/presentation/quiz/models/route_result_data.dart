import '../quiz_route_progress.dart';
import 'route_result_args.dart';

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
  });

  bool get hasNewBestScore => savedBestScore > previousBestScore;

  String get previousBestScoreLabel =>
      '$previousBestScore/$totalPossiblePoints';

  String get savedBestScoreLabel => '$savedBestScore/$totalPossiblePoints';

  String get visitedPoisLabel => '$visitedMonuments/$totalPois';

  Map<String, List<AnswerResultData>> get groupedAnswers {
    final grouped = <String, List<AnswerResultData>>{};

    for (final answer in answerResults) {
      grouped.putIfAbsent(answer.monumentName, () => []).add(answer);
    }

    return grouped;
  }

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
      answerResults: _answerResultsFromArgs(args),
      skippedPois: args.skippedPois,
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
      totalPossiblePoints: 100,
      correctAnswers: 0,
      totalAnswers: 0,
      time: '--',
      answerResults: [],
      skippedPois: [],
    );
  }

  static List<AnswerResultData> _answerResultsFromArgs(RouteResultArgs args) {
    final answerResults = <AnswerResultData>[];

    for (final answer in args.answerResults) {
      answerResults.add(AnswerResultData.fromQuiz(answer));
    }

    return answerResults;
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

  factory AnswerResultData.fromQuiz(QuizAnswerResult data) {
    return AnswerResultData(
      monumentName: data.monumentName,
      question: data.question,
      selectedAnswer: data.selectedAnswer,
      correctAnswer: data.correctAnswer,
      isCorrect: data.isCorrect,
    );
  }
}

class AnswerTextSanitizer {
  const AnswerTextSanitizer._();

  static String clean(String value) {
    final cleanLines = <String>[];
    final normalizedText = value.replaceAll('\r\n', '\n');

    for (final line in normalizedText.split('\n')) {
      final cleanLine = line.trim();

      if (cleanLine.isNotEmpty) {
        cleanLines.add(cleanLine);
      }
    }

    return cleanLines.join('\n').trim();
  }
}
