import 'package:flutter/material.dart';
import '../../core/theme.dart';

// Cartel tipo píldora que aparece sobre el juego (ayuda, pausa, puntos, game over).
// El relleno y la sombra crecen con el tamaño de letra.
class GameLabel extends StatelessWidget {
  final String text;
  final Color color;
  final Color textColor;
  final double fontSize;

  const GameLabel(
    this.text, {
    super.key,
    this.color = AppColors.cream,
    this.textColor = AppColors.ink,
    this.fontSize = 13,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: fontSize * 1.1, vertical: fontSize * 0.5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.ink, width: 3),
        boxShadow: [BoxShadow(color: AppColors.ink, offset: Offset(0, fontSize * 0.2))],
      ),
      child: Text(
        text,
        style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: fontSize, letterSpacing: 0.6),
      ),
    );
  }
}
