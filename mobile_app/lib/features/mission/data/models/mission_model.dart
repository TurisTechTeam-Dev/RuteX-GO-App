import '../../../../core/constants/firestore_contract.dart';
import '../../domain/entities/mission.dart';

class MissionModel extends Mission {
  const MissionModel({
    required super.id,
    required super.title,
    required super.questions,
  });

  factory MissionModel.fromFirestore(Map<String, dynamic> data, String id) {
    final rawQuestions = data[MissionFields.preguntas];

    return MissionModel(
      id: id,
      title: data[MissionFields.titulo]?.toString() ?? 'Misión',
      questions: rawQuestions is List
          ? _questionsFromList(rawQuestions)
          : const [],
    );
  }

  static List<MissionQuestionModel> _questionsFromList(List rawQuestions) {
    final questions = <MissionQuestionModel>[];

    for (final rawQuestion in rawQuestions) {
      if (rawQuestion is Map) {
        questions.add(
          MissionQuestionModel.fromMap(Map<String, dynamic>.from(rawQuestion)),
        );
      }
    }

    return questions;
  }
}

class MissionQuestionModel extends MissionQuestion {
  const MissionQuestionModel({
    required super.text,
    required super.answers,
    required super.correctIndex,
  });

  factory MissionQuestionModel.fromMap(Map<String, dynamic> data) {
    final answers = data[MissionFields.respuestas];

    return MissionQuestionModel(
      text: _questionTextFromData(data),
      answers: answers is List ? _answersFromList(answers) : const [],
      correctIndex: _correctIndexFromData(data),
    );
  }

  static String _questionTextFromData(Map<String, dynamic> data) {
    for (final entry in data.entries) {
      if (entry.key.startsWith('pregunta_')) {
        return entry.value.toString();
      }
    }

    return 'Cargando...';
  }

  static List<String> _answersFromList(List rawAnswers) {
    final answers = <String>[];

    for (final rawAnswer in rawAnswers) {
      answers.add(rawAnswer.toString());
    }

    return answers;
  }

  static int _correctIndexFromData(Map<String, dynamic> data) {
    final correctIndex = data[MissionFields.indiceCorrecto];

    if (correctIndex is int) {
      return correctIndex;
    }

    return 0;
  }
}
