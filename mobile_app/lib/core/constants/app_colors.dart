import 'package:flutter/material.dart';

class AppColors {
  // --- COLORES CORPORATIVOS ---
  static const Color verdePrincipal = Color(0xFF007A3D);  // Botón e interacciones
  static const Color verdeClaro = Color(0xFF4CAF70);      // Variación para estados
  static const Color verdeBorde = Color(0xFF4A5D23);      // El trazo oscuro de los inputs

  // --- SUPERFICIES Y FONDOS ---
  static const Color blancoPuro = Color(0xFFFFFFFF);      // Fondo de la pantalla
  static const Color blancoTarjeta = Color(0xFFFBFBFB);   // El de la AuthCard
  static const Color cremaInput = Color(0xFFF5F1E8);      // El fondo de los campos de texto

  // --- NEUTROS Y SOMBRAS ---
  static const Color negroTexto = Color(0xFF0B0B0B);      // Títulos y textos fuertes
  static const Color grisSombra = Color(0xFF2F3333);      // Color de sombras y texto secundario
  static const Color grisNeutro = Color(0xFF7A8587);      // Textos suaves o iconos

  // --- ESTADOS ---
  static const Color error = Color(0xFFFF0000);           // Mensajes de error
  static const Color exito = Color(0xFF28A745);           // Validaciones correctas

  // --- ATAJOS DE OPACIDAD (Getters) ---
  static Color get tarjetaTransparente => blancoTarjeta.withValues(alpha: 0.3);
  static Color get sombraSuave => grisSombra.withValues(alpha: 0.15);
}