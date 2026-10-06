import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../dash_game.dart';

// Cielo con degradé (día o noche), grilla suave y estrellas de noche
class SkyComponent extends Component with HasGameReference<DashGame> {
  // Posiciones fijas (semilla constante) en proporción a la pantalla, para que no titilen
  static final List<(double, double, double)> _estrellas = () {
    final azar = math.Random(7);
    return List.generate(30, (_) => (azar.nextDouble(), azar.nextDouble() * 0.7, azar.nextDouble() * 1.5 + 0.5));
  }();

  @override
  void render(Canvas canvas) {
    final tamano = game.size;
    final rect = Rect.fromLTWH(0, 0, tamano.x, tamano.y);
    final noche = game.esNoche;

    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: noche
              ? const [AppColors.cieloArribaNoche, AppColors.cieloAbajoNoche]
              : const [AppColors.cieloArriba, AppColors.cieloAbajo],
        ).createShader(rect),
    );

    final grilla = Paint()
      ..color = Colors.white.withValues(alpha: noche ? 0.06 : 0.35)
      ..strokeWidth = 1;
    const paso = 32.0;
    for (var x = 0.0; x < tamano.x; x += paso) {
      canvas.drawLine(Offset(x, 0), Offset(x, tamano.y), grilla);
    }
    for (var y = 0.0; y < tamano.y; y += paso) {
      canvas.drawLine(Offset(0, y), Offset(tamano.x, y), grilla);
    }

    if (noche) {
      final estrella = Paint()..color = Colors.white.withValues(alpha: 0.8);
      for (final (fx, fy, radio) in _estrellas) {
        canvas.drawCircle(Offset(fx * tamano.x, fy * tamano.y), radio, estrella);
      }
    }
  }
}
