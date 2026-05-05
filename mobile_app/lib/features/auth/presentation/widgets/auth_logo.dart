/*
  -----------------------------------------------------------------------------
  Proyecto: RuteX Go
  Desarrollado por: TurisTechTeam
  Descripción: Esta aplicación y su código fuente son propiedad intelectual de
  TurisTechTeam. Queda prohibida su copia, distribución o uso no autorizado.
  Año: 2026
  -----------------------------------------------------------------------------
*/import 'package:flutter/material.dart';

class AuthLogo extends StatelessWidget {
  final double height;

  const AuthLogo({super.key, required this.height});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'logo',
      child: Image.asset(
        'assets/Logo_Color_Rutexgo.png',
        height: height,
        semanticLabel: 'Logotipo de RuteX Go',
      ),
    );
  }
}
