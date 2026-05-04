/*
  -----------------------------------------------------------------------------
  Proyecto: RuteX Go
  Desarrollado por: TurisTechTeam
  Descripción: Esta aplicación y su código fuente son propiedad intelectual de
  TurisTechTeam. Queda prohibida su copia, distribución o uso no autorizado.
  Año: 2026
  -----------------------------------------------------------------------------
*/
import 'package:flutter/material.dart';

import '../models/route_result_data.dart';

class QuestionResultsSheet extends StatelessWidget {
  final RouteResultData result;

  const QuestionResultsSheet({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final hasResults =
        result.groupedAnswers.isNotEmpty || result.skippedPois.isNotEmpty;

    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _ResultsHeader(),
            Flexible(
              child: hasResults
                  ? _ResultsList(result: result)
                  : const _EmptyResultsMessage(),
            ),
            const _CloseButton(),
          ],
        ),
      ),
    );
  }
}

class _ResultsHeader extends StatelessWidget {
  const _ResultsHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF009640),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
      child: const Column(
        children: [
          Text(
            'Resultados',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyResultsMessage extends StatelessWidget {
  const _EmptyResultsMessage();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Text('No se respondieron preguntas en esta ruta.'),
    );
  }
}

class _ResultsList extends StatelessWidget {
  final RouteResultData result;

  const _ResultsList({required this.result});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
      children: _buildResultItems(),
    );
  }

  List<Widget> _buildResultItems() {
    final items = <Widget>[];

    for (final group in result.groupedAnswers.entries) {
      items.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: _MonumentAnswerGroup(
            monumentName: group.key,
            answers: group.value,
          ),
        ),
      );
    }

    if (result.skippedPois.isNotEmpty) {
      items.add(_SkippedPoisGroup(skippedPois: result.skippedPois));
    }

    return items;
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton();

  @override
  Widget build(BuildContext context) {
    return Padding(
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
    );
  }
}

class _SkippedPoisGroup extends StatelessWidget {
  final List<String> skippedPois;

  const _SkippedPoisGroup({required this.skippedPois});

  @override
  Widget build(BuildContext context) {
    final skippedRows = _buildSkippedRows();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 28),
        const Text(
          'Puntos de interés saltados',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        for (final row in skippedRows) row,
      ],
    );
  }

  List<Widget> _buildSkippedRows() {
    final rows = <Widget>[];

    for (final poi in skippedPois) {
      rows.add(
        Padding(
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
      );
    }

    return rows;
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
    final answerTiles = _buildAnswerTiles();

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
        for (final tile in answerTiles) tile,
      ],
    );
  }

  List<Widget> _buildAnswerTiles() {
    final tiles = <Widget>[];

    for (final answer in answers) {
      tiles.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: _AnswerTile(answer: answer),
        ),
      );
    }

    return tiles;
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
    final theme = Theme.of(context);
    final answerTexts = _buildAnswerTexts(
      context,
      question,
      selectedAnswer,
      correctAnswer,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.14),
        ),
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
              children: answerTexts,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAnswerTexts(
    BuildContext context,
    String question,
    String selectedAnswer,
    String correctAnswer,
  ) {
    final texts = <Widget>[];
    final theme = Theme.of(context);

    if (question.isNotEmpty) {
      texts.add(
        Text(
          question,
          style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface),
        ),
      );
      texts.add(const SizedBox(height: 6));
    }

    texts.add(
      Text(
        selectedAnswer,
        style: TextStyle(
          color: theme.colorScheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
      ),
    );

    final shouldShowCorrectAnswer =
        !answer.isCorrect && correctAnswer.isNotEmpty;
    if (shouldShowCorrectAnswer) {
      texts.add(const SizedBox(height: 6));
      texts.add(
        Text(
          'Respuesta correcta: $correctAnswer',
          style: const TextStyle(color: Color(0xFF007E35), fontSize: 12),
        ),
      );
    }

    return texts;
  }
}
