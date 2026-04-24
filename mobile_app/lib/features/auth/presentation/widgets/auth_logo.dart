import 'package:flutter/material.dart';

class AuthLogo extends StatelessWidget {
  final double height;

  const AuthLogo({super.key, required this.height});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'logo',
      child: Image.asset('assets/Logo_Color_Rutexgo.png', height: height),
    );
  }
}
