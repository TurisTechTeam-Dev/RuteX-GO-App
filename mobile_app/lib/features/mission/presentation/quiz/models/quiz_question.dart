/*
  -----------------------------------------------------------------------------
  Proyecto: RuteX Go
  Desarrollado por: TurisTechTeam
  Descripción: Esta aplicación y su código fuente son propiedad intelectual de
  TurisTechTeam. Queda prohibida su copia, distribución o uso no autorizado.
  Año: 2026
  -----------------------------------------------------------------------------
*/
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
