import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme{
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Montserrat',
      primaryColor: AppColors.verde,
      scaffoldBackgroundColor: AppColors.blanco,

      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.verde,
        primary: AppColors.verde,
        secondary: AppColors.verdeClaro,
        surface: AppColors.blanco,
        onSurface: AppColors.negro,
        error: AppColors.error
      ),

      textTheme: const TextTheme(
        //H1 Titulos
        displayLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: AppColors.negro
        ),

        //H2 Subtitulos
        displayMedium: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.negro
        ),

        // Body / Informacion
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.negro
        ),

        // Inputs
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.negroSuave
        ),

        // FootNote
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.negroSuave
        ),
      ),

      // 2. CARD THEME
      cardTheme: CardThemeData(
        color: AppColors.blanco,
        elevation: 10,
        shadowColor: Colors.black26,
        surfaceTintColor: Colors.white,
        margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),

        ),
      ),

      // 3. INPUT DECORATION THEME
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF3F5F1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.verdeClaro),
        ),
      ),
    );
  }
}