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

import '../../../../../core/widgets/buttons/custom_button.dart';
import '../models/quiz_question.dart';
import 'quiz_answer_option.dart';

class QuizContent extends StatelessWidget {
  final List<QuizQuestion> questions;
  final int currentIndex;
  final int? selectedOption;
  final ValueChanged<int> onOptionSelected;
  final VoidCallback? onContinue;

  const QuizContent({
    super.key,
    required this.questions,
    required this.currentIndex,
    required this.selectedOption,
    required this.onOptionSelected,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final question = questions[currentIndex];

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: _buildQuestionContent(context, question),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: CustomButton(
            text: _continueButtonText(),
            onPressed: onContinue,
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionContent(BuildContext context, QuizQuestion question) {
    final theme = Theme.of(context);
    final children = <Widget>[
      LinearProgressIndicator(
        value: (currentIndex + 1) / questions.length,
        backgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.14),
        color: theme.colorScheme.primary,
      ),
      const SizedBox(height: 20),
      Center(
        child: Text(
          "${currentIndex + 1} de ${questions.length}",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.68),
          ),
        ),
      ),
      const SizedBox(height: 25),
      Text(
        question.text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: MediaQuery.sizeOf(context).width < 340 ? 19 : 22,
          fontWeight: FontWeight.bold,
          height: 1.4,
          color: theme.colorScheme.onSurface,
        ),
      ),
      SizedBox(height: MediaQuery.sizeOf(context).height < 620 ? 24 : 40),
    ];

    for (var index = 0; index < question.answers.length; index++) {
      children.add(
        QuizAnswerOption(
          index: index,
          text: question.answers[index],
          isSelected: selectedOption == index,
          onTap: () => onOptionSelected(index),
        ),
      );
    }

    children.add(const SizedBox(height: 4));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }

  String _continueButtonText() {
    final isLastQuestion = currentIndex == questions.length - 1;
    return isLastQuestion ? "FINALIZAR" : "SIGUIENTE";
  }
}
