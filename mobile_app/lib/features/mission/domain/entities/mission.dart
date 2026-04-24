class Mission {
  final String id;
  final String title;
  final List<MissionQuestion> questions;

  const Mission({
    required this.id,
    required this.title,
    required this.questions,
  });
}

class MissionQuestion {
  final String text;
  final List<String> answers;
  final int correctIndex;

  const MissionQuestion({
    required this.text,
    required this.answers,
    required this.correctIndex,
  });
}
