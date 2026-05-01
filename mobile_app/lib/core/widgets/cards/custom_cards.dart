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

import '../../constants/app_colors.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;

  const CustomCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark
        ? AppColors.grisClaro.withValues(alpha: 0.55)
        : AppColors.negroTexto;
    final shadowColor = isDark
        ? Colors.black.withValues(alpha: 0.45)
        : Colors.black;

    return Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: isDark ? 1.2 : 2),

        boxShadow: [
          BoxShadow(
            color: shadowColor,
            offset: const Offset(0, 4),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
      ),
      child: child,
    );
  }
}
