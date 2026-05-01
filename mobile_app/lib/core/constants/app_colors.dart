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
  // --- COLORES CORPORATIVOS ---
  static const Color verdePrincipal = Color(
    0xFF007A3D,
  ); // Botón e interacciones
  static const Color verdeClaro = Color(0xFF4CAF70); // Variación para estados
  static const Color verdeBorde = Color(
    0xFF4A5D23,
  ); // El trazo oscuro de los inputs

  // --- SUPERFICIES Y FONDOS ---
  static const Color blancoPuro = Color(0xFFFFFFFF); // Fondo de la pantalla
  static const Color blancoTarjeta = Color(0xFFFBFBFB); // Superficie de tarjeta
  static const Color cremaInput = Color(
    0xFFF5F1E8,
  ); // El fondo de los campos de texto

  // --- NEUTROS Y SOMBRAS ---
  static const Color negroTexto = Color(0xFF0B0B0B); // Títulos y textos fuertes
  static const Color grisSombra = Color(
    0xFF2F3333,
  ); // Color de sombras y texto secundario
  static const Color grisNeutro = Color(0xFF7A8587); // Textos suaves o iconos

  // --- ESTADOS ---
  static const Color error = Color(0xFFFF0000); // Mensajes de error
  static const Color exito = Color(0xFF28A745); // Validaciones correctas

  // --- ATAJOS DE OPACIDAD (Getters) ---
  static Color get tarjetaTransparente => blancoTarjeta.withValues(alpha: 0.3);
  static Color get sombraSuave => grisSombra.withValues(alpha: 0.15);

  // ============================================
  // --- COLORES MODO OSCURO ---
  // ============================================

  // --- COLORES CORPORATIVOS (Modo Oscuro) ---
  static const Color verdePrincipalOscuro = Color(
    0xFF00B54F,
  ); // Más claro para mejor contraste
  static const Color verdeClaroOscuro = Color(
    0xFF66BB6A,
  ); // Variación más clara
  static const Color verdeBordeOscuro = Color(
    0xFF7CB342,
  ); // Más visible en fondo oscuro

  // --- SUPERFICIES Y FONDOS (Modo Oscuro) ---
  static const Color negroFondo = Color(0xFF121212); // Fondo principal oscuro
  static const Color negroTarjeta = Color(
    0xFF1E1E1E,
  ); // Tarjetas en modo oscuro
  static const Color grisInput = Color(
    0xFF2A2A2A,
  ); // El fondo de los campos de texto oscuros

  // --- NEUTROS Y SOMBRAS (Modo Oscuro) ---
  static const Color blancoTexto = Color(
    0xFFF5F5F5,
  ); // Títulos y textos fuertes
  static const Color grisClaro = Color(
    0xFFBDBDBD,
  ); // Color de sombras y texto secundario invertido
  static const Color grisNeutroOscuro = Color(
    0xFF9E9E9E,
  ); // Textos suaves o iconos

  // --- ESTADOS (Modo Oscuro) ---
  static const Color errorOscuro = Color(0xFFEF5350); // Rojo más visible
  static const Color exitoOscuro = Color(0xFF66BB6A); // Verde más visible

  // --- ATAJOS DE OPACIDAD (Getters) Modo Oscuro ---
  static Color get tarjetaTransparenteOscuro =>
      negroTarjeta.withValues(alpha: 0.5);
  static Color get sombraSuaveOscuro => grisClaro.withValues(alpha: 0.2);
}
