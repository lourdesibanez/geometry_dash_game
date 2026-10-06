import 'package:flutter/material.dart';
import '../../core/theme.dart';

// Personaje: cubo amarillo con carita. Se usa como avatar del header
class Player extends StatelessWidget {
  final double tamano;
  final double angulo; // Rotación en radianes

  const Player({super.key, this.tamano = 44, this.angulo = 0});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angulo,
      child: Container(
        width: tamano,
        height: tamano,
        decoration: BoxDecoration(
          color: AppColors.amarillo,
          borderRadius: BorderRadius.circular(tamano * 0.25),
          border: Border.all(color: AppColors.tinta, width: 3),
        ),
        child: Icon(Icons.sentiment_very_satisfied, color: AppColors.tinta, size: tamano * 0.68),
      ),
    );
  }
}
