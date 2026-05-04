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

class AppColors {
  static const Color verdePrincipal = Color(0xFF007A3D);
  static const Color verdeClaro = Color(0xFF4CAF70);
  static const Color verdeBorde = Color(0xFF4A5D23);

  static const Color blancoPuro = Color(0xFFFFFFFF);
  static const Color blancoTarjeta = Color(0xFFFBFBFB);
  static const Color cremaInput = Color(0xFFF5F1E8);

  static const Color negroTexto = Color(0xFF0B0B0B);
  static const Color grisSombra = Color(0xFF2F3333);
  static const Color grisNeutro = Color(0xFF7A8587);

  static const Color error = Color(0xFFFF0000);
  static const Color exito = Color(0xFF28A745);

  static Color get tarjetaTransparente => blancoTarjeta.withValues(alpha: 0.3);
  static Color get sombraSuave => grisSombra.withValues(alpha: 0.15);

  static const Color verdePrincipalOscuro = Color(0xFF00B54F);
  static const Color verdeClaroOscuro = Color(0xFF66BB6A);
  static const Color verdeBordeOscuro = Color(0xFF7CB342);

  static const Color negroFondo = Color(0xFF121212);
  static const Color negroTarjeta = Color(0xFF1E1E1E);
  static const Color grisInput = Color(0xFF2A2A2A);

  static const Color blancoTexto = Color(0xFFF5F5F5);
  static const Color grisClaro = Color(0xFFBDBDBD);
  static const Color grisNeutroOscuro = Color(0xFF9E9E9E);

  static const Color errorOscuro = Color(0xFFEF5350);
  static const Color exitoOscuro = Color(0xFF66BB6A);

  static Color get tarjetaTransparenteOscuro =>
      negroTarjeta.withValues(alpha: 0.5);
  static Color get sombraSuaveOscuro => grisClaro.withValues(alpha: 0.2);
}
