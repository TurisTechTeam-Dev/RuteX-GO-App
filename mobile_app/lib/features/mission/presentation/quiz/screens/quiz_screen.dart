import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/routes/app_routes.dart';
import '../models/quiz_mission.dart';
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

    if (_selectedOption == question.correctIndex) {
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
    QuizRouteProgress.addMissionPoints(_points);
    setState(() => _isSaving = true);

    await Future.delayed(const Duration(milliseconds: 600));

    final targetMonuments = await _resolveTargetMonuments();

    if (QuizRouteProgress.visitedMonuments < targetMonuments) {
      if (!mounted) return;

      Navigator.pushNamed(
        context,
        AppRoutes.missionQrScanner,
        arguments: {'routeId': _routeId, 'totalPois': targetMonuments},
      );
      return;
    }

    final routeId = _routeId;
    if (routeId != null && routeId.isNotEmpty) {
      try {
        await _markRouteAsCompleted(routeId, targetMonuments);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("No se pudo guardar la ruta: $e"),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }

    QuizRouteProgress.reset();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.home,
      (route) => false,
    );
  }

  Future<int> _resolveTargetMonuments() async {
    final routeId = _routeId;
    if (routeId == null || routeId.isEmpty) return _mission.totalPois;

    final routeDoc = await FirebaseFirestore.instance
        .collection('rutas')
        .doc(routeId)
        .get();
    final data = routeDoc.data();
    final pointsOfInterest = data?['id_puntos_interes'];

    if (pointsOfInterest is List && pointsOfInterest.isNotEmpty) {
      return pointsOfInterest.length;
    }

    return _mission.totalPois;
  }

  Future<void> _markRouteAsCompleted(
    String routeId,
    int visitedMonuments,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userRef = FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(userRef);
      final data = snapshot.data() ?? {};
      final completedRoutes = List<dynamic>.from(
        data['rutas_completadas'] ?? [],
      );

      final hasDetailedCompletion = completedRoutes.any((route) {
        if (route is Map) {
          final savedRouteId =
              route['rutaId'] ?? route['id_ruta'] ?? route['routeId'];
          return savedRouteId?.toString() == routeId;
        }

        return false;
      });

      if (hasDetailedCompletion) return;

      final hasLegacyCompletion = completedRoutes.any(
        (route) => route is String && route == routeId,
      );

      final updates = <String, dynamic>{
        'rutas_completadas': FieldValue.arrayUnion([
          {
            'rutaId': routeId,
            'puntos_obtenidos': QuizRouteProgress.routePoints,
            'monumentos_visitados': visitedMonuments,
            'misiones_completadas': visitedMonuments,
          },
        ]),
      };

      if (!hasLegacyCompletion) {
        updates['puntos'] = FieldValue.increment(QuizRouteProgress.routePoints);
      }

      transaction.update(userRef, updates);
    });
  }
}
