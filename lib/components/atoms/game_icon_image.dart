import 'package:flutter/material.dart';
import '../../game/game_icons.dart';

// Ícono del juego (diamante, estrella, trofeo) en las pantallas de Flutter.
// Es un enchufe, toma ese dibujo que ya existe y lo convierte en un widget, para que las pantallas lo puedan usar.
class GameIconImage extends StatelessWidget {
  final GameIcon icono;
  final double tamano;

  const GameIconImage(this.icono, {super.key, this.tamano = 24});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(tamano), painter: _PintorIcono(icono, tamano));
  }
}

class _PintorIcono extends CustomPainter {
  final GameIcon icono;
  final double tamano;

  const _PintorIcono(this.icono, this.tamano);

  @override
  void paint(Canvas canvas, Size size) => icono.pintar(canvas, tamano);

  @override
  bool shouldRepaint(_PintorIcono oldDelegate) => oldDelegate.icono != icono || oldDelegate.tamano != tamano;
}
