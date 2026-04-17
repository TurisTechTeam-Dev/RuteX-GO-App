import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/firestore_contract.dart';
import '../../mission_flow_result.dart';
import '../models/quiz_mission.dart';
import '../models/quiz_question.dart';
import '../quiz_route_progress.dart';
import '../widgets/quiz_content.dart';

class QuizScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  const QuizScreen({super.key, required this.data});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late final QuizMission _mission = QuizMission.fromArgs(widget.data);

  int _currentIndex = 0;
  int? _selectedOption;
  int _points = 0;
  bool _isSaving = false;
  final List<QuizAnswerResult> _answerResults = <QuizAnswerResult>[];

  String? get _routeId => _mission.routeId ?? QuizRouteProgress.activeRouteId;

  @override
  void initState() {
    super.initState();
    QuizRouteProgress.ensureRoute(_routeId);
  }

  @override
  Widget build(BuildContext context) {
    if (_mission.questions.isEmpty) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.verdePrincipal),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          _mission.title,
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isSaving
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.verdePrincipal),
            )
          : QuizContent(
              questions: _mission.questions,
              currentIndex: _currentIndex,
              selectedOption: _selectedOption,
              onOptionSelected: (option) {
                setState(() => _selectedOption = option);
              },
              onContinue: _selectedOption == null
                  ? null
                  : () => _continueQuiz(),
            ),
    );
  }

  Future<void> _continueQuiz() async {
    final question = _mission.questions[_currentIndex];
    final selectedIndex = _selectedOption!;
    final correctIndex = question.correctIndex;
    final isCorrect = selectedIndex == correctIndex;

    _answerResults.add(
      QuizAnswerResult(
        monumentName: _mission.pointName,
        question: question.text,
        selectedAnswer: _answerAt(question, selectedIndex),
        correctAnswer: _answerAt(question, correctIndex),
        isCorrect: isCorrect,
      ),
    );

    if (isCorrect) {
      _points += 10;
    }

    if (_currentIndex < _mission.questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOption = null;
      });
      return;
    }

    await _finishQuiz();
  }

  Future<void> _finishQuiz() async {
    final wasAdded = QuizRouteProgress.addMonumentResult(
      pointId: _mission.pointId,
      points: _points,
      answers: _answerResults,
    );
    setState(() => _isSaving = true);

    await Future.delayed(const Duration(milliseconds: 600));

    final targetMonuments = await _resolveTargetMonuments();

    if (!wasAdded) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Este punto de interes ya estaba completado"),
          backgroundColor: AppColors.error,
        ),
      );

      Navigator.pop(context);
      return;
    }

    if (QuizRouteProgress.visitedMonuments < targetMonuments) {
      if (!mounted) return;

      Navigator.pop(context, MissionFlowResult.pointCompleted);
      return;
    }

    if (!mounted) return;

    Navigator.pop(context, MissionFlowResult.pointCompleted);
  }

  String _answerAt(QuizQuestion question, int index) {
    if (index < 0 || index >= question.answers.length) return 'Sin respuesta';

    return question.answers[index];
  }

  Future<int> _resolveTargetMonuments() async {
    final routeId = _routeId;
    if (routeId == null || routeId.isEmpty) return _mission.totalPois;

    final routeDoc = await FirebaseFirestore.instance
        .collection(FirestoreCollections.rutas)
        .doc(routeId)
        .get();
    final data = routeDoc.data();
    final pointsOfInterest = data?[RouteFields.idPuntosInteres];

    if (pointsOfInterest is List && pointsOfInterest.isNotEmpty) {
      return pointsOfInterest.length;
    }

    return _mission.totalPois;
  }
}
