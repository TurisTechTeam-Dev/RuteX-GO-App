import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
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
    final content = _buildQuestionContent(question);

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: content,
              ),
            ),
          ),
          Container(
            width: double.infinity,
            height: 2,
            color: AppColors.negroTexto,
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  List<Widget> _buildQuestionContent(QuizQuestion question) {
    final content = <Widget>[
      LinearProgressIndicator(
        value: (currentIndex + 1) / questions.length,
        backgroundColor: Colors.grey[200],
        color: AppColors.verdePrincipal,
      ),
      const SizedBox(height: 20),
      Center(
        child: Text(
          "${currentIndex + 1} de ${questions.length}",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
      ),
      const SizedBox(height: 25),
      Text(
        question.text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          height: 1.4,
        ),
      ),
      const SizedBox(height: 40),
    ];

    for (var index = 0; index < question.answers.length; index++) {
      content.add(
        QuizAnswerOption(
          index: index,
          text: question.answers[index],
          isSelected: selectedOption == index,
          onTap: () => onOptionSelected(index),
        ),
      );
    }

    content.add(const Spacer());
    content.add(
      CustomButton(text: _continueButtonText(), onPressed: onContinue),
    );
    content.add(const SizedBox(height: 15));

    return content;
  }

  String _continueButtonText() {
    final isLastQuestion = currentIndex == questions.length - 1;
    return isLastQuestion ? "FINALIZAR" : "SIGUIENTE";
  }
}
