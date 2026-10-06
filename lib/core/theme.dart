// lib/core/theme.dart
import 'package:flutter/material.dart';

class AppColors {
  static const cuentaBasic = Color(0xFF22C3B4);
  static const cuentaPro = Color(0xFFFFC21A);

  // Estilo "arcade kids": colores saturados con contorno azul marino
  static const tinta = Color(0xFF26234D);        // Contornos y texto
  static const tintaSuave = Color(0xFF6E6A99);   // Etiquetas chicas
  static const crema = Color(0xFFFFF8EC);        // Tarjetas modo claro
  static const lila = Color(0xFFDCE3FF);         // Fondo modo claro
  static const noche = Color(0xFF15132E);        // Fondo modo oscuro
  static const tarjetaNoche = Color(0xFF2A2752); // Tarjetas modo oscuro
  static const amarillo = Color(0xFFFFD43B);     // Cubo / estrella
  static const verde = Color(0xFF4CD964);        // Iniciar / sumar
  static const naranja = Color(0xFFFF9F1C);      // Reiniciar
  static const rosa = Color(0xFFFF4FA0);         // Nueva partida
  static const violeta = Color(0xFF5B45B0);      // Botón de tema
  static const turquesa = Color(0xFF22C3B4);     // Marco del juego
  static const diamante = Color(0xFF3EC6FF);

  // Escenario del juego: cielo de día en modo claro, cielo de noche en modo oscuro
  static const cieloArriba = Color(0xFFBFE3FF);
  static const cieloAbajo = Color(0xFF8FB8FF);
  static const piso = Color(0xFF4A55C9);
  static const cieloArribaNoche = Color(0xFF2A2770);
  static const cieloAbajoNoche = Color(0xFF110F33);
  static const pisoNoche = Color(0xFF1C1F55);
  static const lineaPiso = Color(0xFF8CF3FF);
}

class AppTheme {
  static ThemeData temaClaro = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lila,
    fontFamily: 'Roboto', // Tipografía pesada
    colorScheme: const ColorScheme.light(
      primary: AppColors.violeta,
      secondary: AppColors.verde,
      surface: AppColors.crema,       // Tarjetas
      onSurface: AppColors.tinta,     // Texto sobre tarjetas
    ),
  );

  static ThemeData temaOscuro = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.noche,
    fontFamily: 'Roboto',
    colorScheme: const ColorScheme.dark(
      primary: AppColors.violeta,
      secondary: AppColors.verde,
      surface: AppColors.tarjetaNoche,
      onSurface: AppColors.crema,
    ),
  );
}
