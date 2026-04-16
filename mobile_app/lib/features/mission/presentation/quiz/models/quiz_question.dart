class QuizQuestion {
  final String text;
  final List<String> answers;
  final int correctIndex;

  const QuizQuestion({
    required this.text,
    required this.answers,
    required this.correctIndex,
  });

  factory QuizQuestion.fromMap(Map<String, dynamic> data) {
    final questionText = data.entries
        .firstWhere(
          (entry) => entry.key.startsWith('pregunta_'),
          orElse: () => const MapEntry('pregunta', 'Cargando...'),
        )
        .value
        .toString();
    final answers = data['respuestas'];

    return QuizQuestion(
      text: questionText,
      answers: answers is List
          ? answers.map((answer) => answer.toString()).toList()
          : const [],
      correctIndex: data['indice_correcto'] is int
          ? data['indice_correcto'] as int
          : 0,
    );
  }
}
