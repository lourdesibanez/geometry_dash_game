// lib/core/theme.dart
import 'package:flutter/material.dart';

class AppColors {
  static const accountBasic = Color(0xFF22C3B4);
  static const accountPro = Color(0xFFFFC21A);

  // Estilo "arcade kids": colores saturados con contorno azul marino
  static const ink = Color(0xFF26234D);          // Contornos y texto
  static const inkMuted = Color(0xFF6E6A99);     // Etiquetas chicas
  static const cream = Color(0xFFFFF8EC);        // Tarjetas modo claro
  static const lilac = Color(0xFFDCE3FF);        // Fondo modo claro
  static const night = Color(0xFF15132E);        // Fondo modo oscuro
  static const nightCard = Color(0xFF2A2752);    // Tarjetas modo oscuro
  static const yellow = Color(0xFFFFD43B);       // Cubo / estrella
  static const green = Color(0xFF4CD964);        // Iniciar / sumar
  static const orange = Color(0xFFFF9F1C);       // Reiniciar
  static const pink = Color(0xFFFF4FA0);         // Nueva partida
  static const purple = Color(0xFF5B45B0);       // Botón de tema
  static const teal = Color(0xFF22C3B4);         // Marco del juego
  static const diamond = Color(0xFF3EC6FF);

  // Escenario del juego: cielo de día en modo claro, cielo de noche en modo oscuro
  static const skyTop = Color(0xFFBFE3FF);
  static const skyBottom = Color(0xFF8FB8FF);
  static const ground = Color(0xFF4A55C9);
  static const skyTopNight = Color(0xFF2A2770);
  static const skyBottomNight = Color(0xFF110F33);
  static const groundNight = Color(0xFF1C1F55);
  static const groundLine = Color(0xFF8CF3FF);
}

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lilac,
    fontFamily: 'Roboto', // Tipografía pesada
    colorScheme: const ColorScheme.light(
      primary: AppColors.purple,
      secondary: AppColors.green,
      surface: AppColors.cream,       // Tarjetas
      onSurface: AppColors.ink,       // Texto sobre tarjetas
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.night,
    fontFamily: 'Roboto',
    colorScheme: const ColorScheme.dark(
      primary: AppColors.purple,
      secondary: AppColors.green,
      surface: AppColors.nightCard,
      onSurface: AppColors.cream,
    ),
  );
}