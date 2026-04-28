import 'package:flutter/material.dart';
import 'package:mobile_app/core/widgets/cards/custom_cards.dart';

class QuestionForm extends StatefulWidget {
  final String? initialQuestion;
  final String? initialAnswerOne;
  final String? initialAnswerTwo;
  final String? initialAnswerThree;

  const QuestionForm({
    super.key,
    this.initialQuestion,
    this.initialAnswerOne,
    this.initialAnswerTwo,
    this.initialAnswerThree,
  });

  @override
  State<QuestionForm> createState() => _QuestionFormState();
}

class _QuestionFormState extends State<QuestionForm> {
  late TextEditingController _questionController;
  late TextEditingController _answerOneController;
  late TextEditingController _answerTwoController;
  late TextEditingController _answerThreeController;

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(text: widget.initialQuestion);
    _answerOneController = TextEditingController(text: widget.initialAnswerOne);
    _answerTwoController = TextEditingController(text: widget.initialAnswerTwo);
    _answerThreeController = TextEditingController(
      text: widget.initialAnswerThree,
    );
  }

  @override
  void dispose() {
    _questionController.dispose();
    _answerOneController.dispose();
    _answerTwoController.dispose();
    _answerThreeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel("Pregunta"),
            _buildTextField(
              _questionController,
              hint: "¿Cuál es el monumento...?",
            ),
            const SizedBox(height: 16),

            _buildLabel("Respuesta 1"),
            _buildTextField(_answerOneController),
            const SizedBox(height: 16),

            _buildLabel("Respuesta 2"),
            _buildTextField(_answerTwoController),
            const SizedBox(height: 16),

            _buildLabel("Respuesta 3"),
            _buildTextField(_answerThreeController),

            const SizedBox(height: 40), // Espacio antes del botón

            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Lógica para guardar la pregunta
                  debugPrint("Pregunta: ${_questionController.text}");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007D40),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 4,
                ),
                child: const Text(
                  "Guardar",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, {String? hint}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF2F1E6),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF6B7249), width: 1),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}
