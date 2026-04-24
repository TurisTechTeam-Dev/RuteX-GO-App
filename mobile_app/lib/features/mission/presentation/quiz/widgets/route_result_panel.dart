import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/routes/app_routes.dart';
import '../models/route_result_data.dart';
import 'question_results_sheet.dart';

class RouteResultPanel extends StatelessWidget {
  final RouteResultData result;

  const RouteResultPanel({super.key, required this.result});

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
          _InfoRow(
            label: 'Mejor puntuación anterior',
            value: result.previousBestScoreLabel,
          ),
          _InfoRow(
            label: 'Puntuación del intento',
            value: '${result.attemptScore}/${result.totalPossiblePoints}',
          ),
          if (result.hasNewBestScore)
            _InfoRow(
              label: 'Nueva mejor puntuación',
              value: result.savedBestScoreLabel,
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

  void _showQuestionResults(BuildContext context, RouteResultData result) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.86,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      builder: (context) => QuestionResultsSheet(result: result),
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
