import 'package:flutter/material.dart';

import '../models/route_result_data.dart';

class QuestionResultsSheet extends StatelessWidget {
  final RouteResultData result;

  const QuestionResultsSheet({super.key, required this.result});

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
                    '${AnswerTextSanitizer.clean(poi)}: misión no realizada',
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
  final List<AnswerResultData> answers;

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
                AnswerTextSanitizer.clean(monumentName),
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
  final AnswerResultData answer;

  const _AnswerTile({required this.answer});

  @override
  Widget build(BuildContext context) {
    final question = AnswerTextSanitizer.clean(answer.question);
    final selectedAnswer = AnswerTextSanitizer.clean(answer.selectedAnswer);
    final correctAnswer = AnswerTextSanitizer.clean(answer.correctAnswer);

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
