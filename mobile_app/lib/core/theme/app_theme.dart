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
        fillColor: const Color(0xFFE9E6DC),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: AppColors.verdeClaro,
            width: 2,
          ),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: AppColors.verdeClaro,
            width: 2,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: AppColors.verde,
            width: 2.5,
          ),
        ),
      ),

    );
  }
}