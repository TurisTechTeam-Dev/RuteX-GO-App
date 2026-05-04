import '../../../../core/constants/firestore_contract.dart';
import 'admin_model_helpers.dart';

class AdminMissionQuestion {
  final String text;
  final List<String> answers;
  final int correctIndex;

  const AdminMissionQuestion({
    required this.text,
    required this.answers,
    required this.correctIndex,
  });

  factory AdminMissionQuestion.fromMap(Map<String, dynamic> data) {
    String? preguntaKey;
    for (final key in data.keys) {
      if (key.startsWith('pregunta_')) {
        preguntaKey = key;
        break;
      }
    }

    final rawAnswers = data[MissionFields.respuestas];
    final answersData = rawAnswers is List
        ? rawAnswers.map((e) => e.toString()).toList()
        : <String>[];

    return AdminMissionQuestion(
      text: preguntaKey == null ? '' : (data[preguntaKey] ?? '').toString(),
      answers: answersData,
      correctIndex: (data[MissionFields.indiceCorrecto] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap(int index) {
    return {
      'pregunta_${index + 1}': text.trim(),
      MissionFields.respuestas: answers.map((e) => e.trim()).toList(),
      MissionFields.indiceCorrecto: correctIndex,
    };
  }
}

class AdminMissionModel {
  final String? id;
  final String pointId;
  final String title;
  final List<AdminMissionQuestion> questions;

  const AdminMissionModel({
    this.id,
    required this.pointId,
    required this.title,
    required this.questions,
  });

  factory AdminMissionModel.fromFirestore(
    Map<String, dynamic> data,
    String id,
  ) {
    final rawQuestions = data[MissionFields.preguntas];
    final questionsData = rawQuestions is List
        ? rawQuestions
              .whereType<Map>()
              .map(
                (e) =>
                    AdminMissionQuestion.fromMap(Map<String, dynamic>.from(e)),
              )
              .toList()
        : <AdminMissionQuestion>[];

    return AdminMissionModel(
      id: id,
      pointId: adminIdFromFirestoreValue(
        data[MissionFields.puntosInteresId] ??
            data[MissionFields.puntoInteresId] ??
            data['id_punto_interes'] ??
            data['pointId'] ??
            data['punto_interes'] ??
            data['punto_interes_ref'] ??
            data['pointId'] ??
            data['poiId'],
      ),
      title: (data[MissionFields.titulo] ?? '').toString(),
      questions: questionsData,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      MissionFields.puntosInteresId: pointId,
      MissionFields.titulo: title.trim(),
      MissionFields.preguntas: questions
          .asMap()
          .entries
          .map((entry) => entry.value.toMap(entry.key))
          .toList(),
    };
  }
}
