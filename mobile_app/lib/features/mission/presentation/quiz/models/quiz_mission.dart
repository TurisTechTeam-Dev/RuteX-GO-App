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
import 'quiz_question.dart';

class QuizMission {
  final String title;
  final List<QuizQuestion> questions;
  final String? routeId;
  final String? pointId;
  final String pointName;
  final int totalPois;

  const QuizMission({
    required this.title,
    required this.questions,
    required this.routeId,
    required this.pointId,
    required this.pointName,
    required this.totalPois,
  });

  factory QuizMission.fromMission({
    required Mission mission,
    required String? routeId,
    required String? pointId,
    required String pointName,
    required int? totalPois,
  }) {
    return QuizMission(
      title: mission.title,
      questions: _questionsFromMission(mission),
      routeId: routeId,
      pointId: pointId,
      pointName: pointName,
      totalPois: totalPois != null && totalPois > 0 ? totalPois : 3,
    );
  }

  static List<QuizQuestion> _questionsFromMission(Mission mission) {
    final questions = <QuizQuestion>[];

    for (final question in mission.questions) {
      questions.add(QuizQuestion.fromMissionQuestion(question));
    }

    return questions;
  }
}
