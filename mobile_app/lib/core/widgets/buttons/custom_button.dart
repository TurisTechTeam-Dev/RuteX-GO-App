import 'package:flutter/material.dart';

class custom_button extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double height;
  final double? width;

  const custom_button({
    super.key,
    required this.text,
    required this.onPressed,
    this.height = 55,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }
}
