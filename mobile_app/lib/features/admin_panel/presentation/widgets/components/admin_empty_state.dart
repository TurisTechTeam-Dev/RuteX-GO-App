/*
  -----------------------------------------------------------------------------
  Proyecto: RuteX Go
  Desarrollado por: TurisTechTeam
  Descripción: Esta aplicación y su código fuente son propiedad intelectual de
  TurisTechTeam. Queda prohibida su copia, distribución o uso no autorizado.
  Año: 2026
  -----------------------------------------------------------------------------
*/import 'package:flutter/material.dart';

class AdminEmptyState extends StatelessWidget {
  final String message;
  final VoidCallback? onBack;
  final double iconSize;

  const AdminEmptyState({
    super.key,
    required this.message,
    this.onBack,
    this.iconSize = 42,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.info_outline, size: iconSize, color: Colors.grey),
        const SizedBox(height: 12),
        Text(message, style: const TextStyle(color: Colors.grey)),
        if (onBack != null)
          TextButton(onPressed: onBack, child: const Text("Volver")),
      ],
    );
  }
}
