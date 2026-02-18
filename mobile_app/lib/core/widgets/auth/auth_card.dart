import 'package:flutter/material.dart';
import 'package:mobile_app/core/widgets/inputs/custom_inputs.dart';

class AuthCard extends StatelessWidget {
  final List<Widget> children;
  const AuthCard({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: children,
        )
      ),
    );
  }
}
