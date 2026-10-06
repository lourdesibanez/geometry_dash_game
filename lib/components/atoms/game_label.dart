import 'package:flutter/material.dart';
import '../../core/theme.dart';

// Cartel tipo píldora que aparece sobre el juego (ayuda, pausa, puntos, game over).
// El relleno y la sombra crecen con el tamaño de letra.
class GameLabel extends StatelessWidget {
  final String texto;
  final Color color;
  final Color colorTexto;
  final double tamanoLetra;

  const GameLabel(
    this.texto, {
    super.key,
    this.color = AppColors.crema,
    this.colorTexto = AppColors.tinta,
    this.tamanoLetra = 13,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: tamanoLetra * 1.1, vertical: tamanoLetra * 0.5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.tinta, width: 3),
        boxShadow: [BoxShadow(color: AppColors.tinta, offset: Offset(0, tamanoLetra * 0.2))],
      ),
      child: Text(
        texto,
        style: TextStyle(color: colorTexto, fontWeight: FontWeight.w900, fontSize: tamanoLetra, letterSpacing: 0.6),
      ),
    );
  }
}
