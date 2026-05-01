/*
  -----------------------------------------------------------------------------
  Proyecto: RuteX Go
  Desarrollado por: TurisTechTeam
  Descripción: Esta aplicación y su código fuente son propiedad intelectual de
  TurisTechTeam. Queda prohibida su copia, distribución o uso no autorizado.
  Año: 2026
  -----------------------------------------------------------------------------
*/
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
