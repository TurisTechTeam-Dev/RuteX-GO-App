import '../../../domain/entities/mission.dart';

class QuizQuestion {
  final String text;
  final List<String> answers;
  final int correctIndex;

  const QuizQuestion({
    required this.text,
    required this.answers,
    required this.correctIndex,
  });

  factory QuizQuestion.fromMissionQuestion(MissionQuestion question) {
    return QuizQuestion(
      text: question.text,
      answers: question.answers,
      correctIndex: question.correctIndex,
    );
  }
}
