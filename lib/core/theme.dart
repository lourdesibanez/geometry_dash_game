// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppColors {
  // Neo-Brutalist Pop Colors
  static const primaryLight = Color(0xFFFF5252);   // Rojo Neón
  static const secondaryLight = Color(0xFF00E676); // Verde Gamer
  static const accentLight = Color(0xFFFFEA00);    // Amarillo Pop
  static const cyanGamer = Color(0xFF00E5FF);      // Cían Neón
  static const backgroundLight = Color(0xFFF4F4F0); // Crema Retro
  static const surfaceLight = Color(0xFFFFFFFF);
  static const textPrimaryLight = Color(0xFF181818);

  // Dark Mode Brutalism
  static const primaryDark = Color(0xFFFF5252);
  static const secondaryDark = Color(0xFF00E676);
  static const accentDark = Color(0xFFFFEA00);
  static const backgroundDark = Color(0xFF121212);
  static const surfaceDark = Color(0xFF222222);
  static const textPrimaryDark = Color(0xFFF4F4F0);

  static const accountBasic = Color(0xFF9E9E9E);
  static const accountPro = Color(0xFFFFD700);
}

class AppTheme {
  // Constante para el borde brutalista característico
  static const BorderSide brutalBorder = BorderSide(color: Colors.black, width: 3.5);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.backgroundLight,
    fontFamily: 'Roboto', // Tipografía pesada
    colorScheme: const ColorScheme.light(
      primary: AppColors.primaryLight,
      secondary: AppColors.secondaryLight,
      surface: AppColors.surfaceLight,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.backgroundDark,
    fontFamily: 'Roboto',
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryDark,
      secondary: AppColors.secondaryDark,
      surface: AppColors.surfaceDark,
    ),
  );
}