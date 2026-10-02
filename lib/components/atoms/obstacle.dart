import 'package:flutter/material.dart';
import '../../core/theme.dart';

// Obstáculo: dos pinchos azul marino con contorno blanco
class Obstacle extends StatelessWidget {
  final double size;

  const Obstacle({super.key, this.size = 36});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: _SpikesPainter());
  }
}

class _SpikesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()..color = AppColors.ink;
    final stroke = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeJoin = StrokeJoin.round;
    final half = size.width / 2;
    final top = size.height * 0.15; // Puntas cerca del borde de la hitbox

    for (var i = 0; i < 2; i++) {
      final left = i * half;
      final path = Path()
        ..moveTo(left, size.height)
        ..lineTo(left + half / 2, top)
        ..lineTo(left + half, size.height)
        ..close();
      canvas.drawPath(path, fill);
      canvas.drawPath(path, stroke);
    }
  }

  @override
  bool shouldRepaint(_SpikesPainter oldDelegate) => false;
}
