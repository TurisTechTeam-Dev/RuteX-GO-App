import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/routes/app_routes.dart';
import '../../../../../core/widgets/backgrounds/extremadura_map_background.dart';
import '../../../../../core/widgets/bars/top_app_bar.dart';

class RouteResultScreen extends StatelessWidget {
  const RouteResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map? ?? {};
    final result = _RouteResultData.fromArgs(args);

    return Scaffold(
      appBar: const TopAppBar(showBack: false),
      endDrawer: const CustomDrawer(),
      body: Stack(
        children: [
          const ExtremaduraMapBackground(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 24, 28, 32),
                child: _ResultPanel(result: result),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultPanel extends StatelessWidget {
  final _RouteResultData result;

  const _ResultPanel({required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 360),
      padding: const EdgeInsets.fromLTRB(22, 28, 22, 28),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.84),
        border: Border.all(color: AppColors.negroTexto, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.emoji_events, size: 58, color: Color(0xFFE0A526)),
          const SizedBox(height: 16),
          Text(
            '${result.routeName}\nCompletada',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF214B2E),
              height: 1.15,
            ),
          ),
          const SizedBox(height: 28),
          _InfoRow(label: 'Mejor puntuación', value: result.scoreLabel),
          _InfoRow(
            label: 'Puntuación del intento',
            value: '${result.attemptScore}/${result.totalPossiblePoints}',
          ),
          _InfoRow(
            label: 'Puntos de interés visitados',
            value: result.visitedPoisLabel,
          ),
          if (result.skippedPois.isNotEmpty)
            _InfoRow(
              label: 'Puntos de interés saltados',
              value: '${result.skippedPois.length}/${result.totalPois}',
            ),
          _InfoRow(label: 'Tiempo del intento', value: result.time),
          const SizedBox(height: 28),
          _ActionButton(
            label: 'Ver\nresultados',
            color: const Color(0xFF4DB46E),
            onPressed: () => _showQuestionResults(context, result),
          ),
          const SizedBox(height: 14),
          const _ActionButton(
            label: 'Compartir',
            color: Color(0xFF4DB46E),
            onPressed: null,
          ),
          const SizedBox(height: 14),
          _ActionButton(
            label: 'Finalizar ruta',
            color: const Color(0xFF007E35),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.home,
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  void _showQuestionResults(BuildContext context, _RouteResultData result) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.86,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      builder: (context) => _QuestionResultsSheet(result: result),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.negroTexto),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback? onPressed;

  const _ActionButton({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 170,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: onPressed == null ? Colors.grey.shade400 : color,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade400,
          disabledForegroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        child: Text(label, textAlign: TextAlign.center),
      ),
    );
  }
}

class _QuestionResultsSheet extends StatelessWidget {
  final _RouteResultData result;

  const _QuestionResultsSheet({required this.result});

  @override
  Widget build(BuildContext context) {
    final groupedResults = result.groupedAnswers;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            color: const Color(0xFF009640),
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
            child: const Column(
              children: [
                Text(
                  'Resultados',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Flexible(
            child: groupedResults.isEmpty && result.skippedPois.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('No se respondieron preguntas en esta ruta.'),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                    children: [
                      ...groupedResults.entries.map(
                        (entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: _MonumentAnswerGroup(
                            monumentName: entry.key,
                            answers: entry.value,
                          ),
                        ),
                      ),
                      if (result.skippedPois.isNotEmpty)
                        _SkippedPoisGroup(skippedPois: result.skippedPois),
                    ],
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
            child: SizedBox(
              width: 170,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007E35),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text('Cerrar'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SkippedPoisGroup extends StatelessWidget {
  final List<String> skippedPois;

  const _SkippedPoisGroup({required this.skippedPois});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 28),
        const Text(
          'Puntos de interés saltados',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        ...skippedPois.map(
          (poi) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.skip_next, size: 18, color: Colors.orange),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${_AnswerTextSanitizer.clean(poi)}: misión no realizada',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MonumentAnswerGroup extends StatelessWidget {
  final String monumentName;
  final List<_AnswerResultData> answers;

  const _MonumentAnswerGroup({
    required this.monumentName,
    required this.answers,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.account_balance, color: Color(0xFF007E35)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _AnswerTextSanitizer.clean(monumentName),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...answers.map(
          (answer) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _AnswerTile(answer: answer),
          ),
        ),
      ],
    );
  }
}

class _AnswerTile extends StatelessWidget {
  final _AnswerResultData answer;

  const _AnswerTile({required this.answer});

  @override
  Widget build(BuildContext context) {
    final question = _AnswerTextSanitizer.clean(answer.question);
    final selectedAnswer = _AnswerTextSanitizer.clean(answer.selectedAnswer);
    final correctAnswer = _AnswerTextSanitizer.clean(answer.correctAnswer);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            answer.isCorrect ? Icons.check : Icons.close,
            size: 18,
            color: answer.isCorrect ? const Color(0xFF007E35) : Colors.red,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (question.isNotEmpty)
                  Text(question, style: const TextStyle(fontSize: 13)),
                if (question.isNotEmpty) const SizedBox(height: 6),
                Text(
                  selectedAnswer,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                if (!answer.isCorrect && correctAnswer.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Respuesta correcta: $correctAnswer',
                    style: const TextStyle(
                      color: Color(0xFF007E35),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnswerTextSanitizer {
  static String clean(String value) {
    return value
        .replaceAll('\r\n', '\n')
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .join('\n')
        .trim();
  }
}

class _RouteResultData {
  final String routeName;
  final int score;
  final int attemptScore;
  final int visitedMonuments;
  final int totalPois;
  final int totalPossiblePoints;
  final int correctAnswers;
  final int totalAnswers;
  final String time;
  final List<_AnswerResultData> answerResults;
  final List<String> skippedPois;

  const _RouteResultData({
    required this.routeName,
    required this.score,
    required this.attemptScore,
    required this.visitedMonuments,
    required this.totalPois,
    required this.totalPossiblePoints,
    required this.correctAnswers,
    required this.totalAnswers,
    required this.time,
    required this.answerResults,
    required this.skippedPois,
  });

  String get scoreLabel => '$score/$totalPossiblePoints';

  String get visitedPoisLabel => '$visitedMonuments/$totalPois';

  Map<String, List<_AnswerResultData>> get groupedAnswers {
    final grouped = <String, List<_AnswerResultData>>{};

    for (final answer in answerResults) {
      grouped.putIfAbsent(answer.monumentName, () => []).add(answer);
    }

    return grouped;
  }

  factory _RouteResultData.fromArgs(Map args) {
    final rawAnswers = args['answerResults'];
    final answers = rawAnswers is List
        ? rawAnswers.whereType<Map>().map(_AnswerResultData.fromMap).toList()
        : <_AnswerResultData>[];
    final rawSkippedPois = args['skippedPois'];
    final skippedPois = rawSkippedPois is List
        ? rawSkippedPois.map((poi) => poi.toString()).toList()
        : <String>[];

    return _RouteResultData(
      routeName: args['routeName']?.toString() ?? 'Ruta',
      score: _asInt(args['puntuacion']),
      attemptScore: _asInt(args['puntuacionIntento']),
      visitedMonuments: _asInt(args['monumentos']),
      totalPois: _asInt(args['totalPois']),
      totalPossiblePoints: _asInt(args['puntosTotales'], defaultValue: 100),
      correctAnswers: _asInt(args['correctAnswers']),
      totalAnswers: _asInt(args['totalAnswers']),
      time: args['tiempo']?.toString() ?? '--',
      answerResults: answers,
      skippedPois: skippedPois,
    );
  }

  static int _asInt(dynamic value, {int defaultValue = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;

    return defaultValue;
  }
}

class _AnswerResultData {
  final String monumentName;
  final String question;
  final String selectedAnswer;
  final String correctAnswer;
  final bool isCorrect;

  const _AnswerResultData({
    required this.monumentName,
    required this.question,
    required this.selectedAnswer,
    required this.correctAnswer,
    required this.isCorrect,
  });

  factory _AnswerResultData.fromMap(Map data) {
    return _AnswerResultData(
      monumentName: data['monumentName']?.toString() ?? 'Punto de interés',
      question: data['question']?.toString() ?? '',
      selectedAnswer: data['selectedAnswer']?.toString() ?? '',
      correctAnswer: data['correctAnswer']?.toString() ?? '',
      isCorrect: data['isCorrect'] == true,
    );
  }
}
