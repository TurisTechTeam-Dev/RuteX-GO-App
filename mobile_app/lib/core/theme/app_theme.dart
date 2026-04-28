import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Montserrat',
      primaryColor: AppColors.verdePrincipal,
      scaffoldBackgroundColor: AppColors.blancoPuro,

      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.verdePrincipal,
        primary: AppColors.verdePrincipal,
        secondary: AppColors.verdeClaro,
        surface: AppColors.blancoPuro,
        onSurface: AppColors.negroTexto,
        error: AppColors.error,
      ),

      textTheme: const TextTheme(
        // H1 Títulos grandes
        displayLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: AppColors.negroTexto,
        ),

        // H2 Subtítulos
        displayMedium: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.negroTexto,
        ),

        // Título de pantallas / AppBar
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.negroTexto,
        ),

        // Body / Información
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.negroTexto,
        ),

        // Inputs
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.grisSombra,
        ),

        // TextButton
        labelLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.verdePrincipal,
        ),

        // Footnote
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.grisSombra,
        ),
      ),

      // 2. CARD THEME
      cardTheme: CardThemeData(
        color: AppColors.tarjetaTransparente,
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      // 3. INPUT DECORATION THEME
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cremaInput,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.verdeBorde, width: 2),
        ),
        // Borde al seleccionar (Focused)
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: AppColors.verdePrincipal,
            width: 2.5,
          ),
        ),
        // Estilo del hint
        hintStyle: TextStyle(
          color: AppColors.grisSombra.withValues(alpha: 0.4),
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),

      // 4. ELEVATED BUTTON THEME
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.verdePrincipal,
          foregroundColor: AppColors.blancoPuro,
          elevation: 2,
          shadowColor: AppColors.sombraSuave,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Montserrat',
      primaryColor: AppColors.verdePrincipalOscuro,
      scaffoldBackgroundColor: AppColors.negroFondo,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.verdePrincipalOscuro,
        brightness: Brightness.dark,
        primary: AppColors.verdePrincipalOscuro,
        secondary: AppColors.verdeClaroOscuro,
        surface: AppColors.negroTarjeta,
        onSurface: AppColors.blancoTexto,
        error: AppColors.errorOscuro,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: AppColors.blancoTexto,
        ),
        displayMedium: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.blancoTexto,
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.blancoTexto,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.blancoTexto,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.grisClaro,
        ),
        labelLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.verdePrincipalOscuro,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.grisClaro,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.tarjetaTransparenteOscuro,
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.grisInput,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: AppColors.verdeBordeOscuro,
            width: 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: AppColors.verdePrincipalOscuro,
            width: 2.5,
          ),
        ),
        hintStyle: TextStyle(
          color: AppColors.grisClaro.withValues(alpha: 0.5),
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.verdePrincipalOscuro,
          foregroundColor: AppColors.negroTexto,
          elevation: 2,
          shadowColor: AppColors.sombraSuaveOscuro,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
