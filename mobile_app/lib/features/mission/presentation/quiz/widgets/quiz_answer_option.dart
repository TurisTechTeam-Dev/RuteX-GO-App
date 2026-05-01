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

import '../../../../../core/constants/app_colors.dart';

class QuizAnswerOption extends StatelessWidget {
  final int index;
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const QuizAnswerOption({
    super.key,
    required this.index,
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedBackground = theme.brightness == Brightness.dark
        ? AppColors.verdePrincipalOscuro.withValues(alpha: 0.22)
        : const Color(0xFFE8F5E9);
    final defaultBackground = theme.colorScheme.surface;
    final defaultBorder = theme.colorScheme.onSurface.withValues(alpha: 0.18);
    final avatarBackground = isSelected
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurface.withValues(alpha: 0.10);
    final avatarForeground = isSelected
        ? Colors.white
        : theme.colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isSelected ? selectedBackground : defaultBackground,
            border: Border.all(
              color: isSelected ? theme.colorScheme.primary : defaultBorder,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: avatarBackground,
                child: Text(
                  String.fromCharCode(65 + index),
                  style: TextStyle(
                    color: avatarForeground,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
