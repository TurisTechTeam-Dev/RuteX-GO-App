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
          ? rawQuestions
                .whereType<Map>()
                .map(
                  (question) => MissionQuestionModel.fromMap(
                    Map<String, dynamic>.from(question),
                  ),
                )
                .toList()
          : const [],
    );
  }
}

class MissionQuestionModel extends MissionQuestion {
  const MissionQuestionModel({
    required super.text,
    required super.answers,
    required super.correctIndex,
  });

  factory MissionQuestionModel.fromMap(Map<String, dynamic> data) {
    final questionText = data.entries
        .firstWhere(
          (entry) => entry.key.startsWith('pregunta_'),
          orElse: () => const MapEntry('pregunta', 'Cargando...'),
        )
        .value
        .toString();
    final answers = data[MissionFields.respuestas];

    return MissionQuestionModel(
      text: questionText,
      answers: answers is List
          ? answers.map((answer) => answer.toString()).toList()
          : const [],
      correctIndex: data[MissionFields.indiceCorrecto] is int
          ? data[MissionFields.indiceCorrecto] as int
          : 0,
    );
  }
}
