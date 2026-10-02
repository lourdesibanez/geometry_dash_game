import 'package:flutter/material.dart';
import '../../core/theme.dart';

// Personaje: cubo amarillo con carita. Se usa en el juego y como avatar del header
class Player extends StatelessWidget {
  final double size;
  final double angle; // Rotación en radianes (gira mientras salta)

  const Player({super.key, this.size = 44, this.angle = 0});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.yellow,
          borderRadius: BorderRadius.circular(size * 0.25),
          border: Border.all(color: AppColors.ink, width: 3),
        ),
        child: Icon(Icons.sentiment_very_satisfied, color: AppColors.ink, size: size * 0.68),
      ),
    );
  }
}
