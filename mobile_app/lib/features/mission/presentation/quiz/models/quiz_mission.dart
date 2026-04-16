import 'quiz_question.dart';

class QuizMission {
  final String title;
  final List<QuizQuestion> questions;
  final String? routeId;
  final int totalPois;

  const QuizMission({
    required this.title,
    required this.questions,
    required this.routeId,
    required this.totalPois,
  });

  factory QuizMission.fromArgs(Map<String, dynamic> args) {
    final data = _extractMissionData(args);
    final questions = data['preguntas'];

    return QuizMission(
      title: data['titulo']?.toString() ?? "Mision",
      questions: questions is List
          ? questions
                .whereType<Map>()
                .map(
                  (question) =>
                      QuizQuestion.fromMap(Map<String, dynamic>.from(question)),
                )
                .toList()
          : const [],
      routeId: args['routeId']?.toString(),
      totalPois: _resolveTotalPois(args['totalPois']),
    );
  }

  static Map<String, dynamic> _extractMissionData(Map<String, dynamic> args) {
    final mission = args['mision'];

    if (mission is Map) {
      return Map<String, dynamic>.from(mission);
    }

    return args;
  }

  static int _resolveTotalPois(dynamic totalPois) {
    if (totalPois is int && totalPois > 0) return totalPois;
    if (totalPois is num && totalPois > 0) return totalPois.toInt();
    if (totalPois is String) return int.tryParse(totalPois) ?? 3;

    return 3;
  }
}
