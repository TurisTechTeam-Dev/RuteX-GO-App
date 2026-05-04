import 'package:flutter/material.dart';

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
