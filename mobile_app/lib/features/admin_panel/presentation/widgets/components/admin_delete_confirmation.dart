import 'package:flutter/material.dart';

Future<void> showAdminDeleteConfirmation({
  required BuildContext context,
  required String itemName,
  required VoidCallback onConfirm,
  bool warnCannotUndo = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Confirmar borrado"),
      content: Text(_confirmationMessage(itemName, warnCannotUndo)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text("CANCELAR"),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text("ELIMINAR"),
        ),
      ],
    ),
  );

  if (result == true) onConfirm();
}

String _confirmationMessage(String itemName, bool warnCannotUndo) {
  final baseMessage = "¿Estás seguro de que quieres eliminar '$itemName'?";
  if (!warnCannotUndo) return baseMessage;

  return "$baseMessage Esta acción no se puede deshacer.";
}
