import 'package:flutter/material.dart';

void showAuthSnackBar(
  BuildContext context,
  String message, {
  Color? backgroundColor,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message.replaceAll("Exception: ", "")),
      backgroundColor: backgroundColor,
    ),
  );
}
