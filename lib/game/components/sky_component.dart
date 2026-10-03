import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../dash_game.dart';

// Cielo con degradé (día o noche), grilla suave y estrellas de noche
class SkyComponent extends Component with HasGameReference<DashGame> {
  // Posiciones fijas (semilla constante) en proporción a la pantalla, para que no titilen
  static final List<(double, double, double)> _stars = () {
    final random = math.Random(7);
    return List.generate(30, (_) => (random.nextDouble(), random.nextDouble() * 0.7, random.nextDouble() * 1.5 + 0.5));
  }();

  @override
  void render(Canvas canvas) {
    final size = game.size;
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final night = game.isNight;

    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: night
              ? const [AppColors.skyTopNight, AppColors.skyBottomNight]
              : const [AppColors.skyTop, AppColors.skyBottom],
        ).createShader(rect),
    );

    final grid = Paint()
      ..color = Colors.white.withValues(alpha: night ? 0.06 : 0.35)
      ..strokeWidth = 1;
    const step = 32.0;
    for (var x = 0.0; x < size.x; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.y), grid);
    }
    for (var y = 0.0; y < size.y; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.x, y), grid);
    }

    if (night) {
      final star = Paint()..color = Colors.white.withValues(alpha: 0.8);
      for (final (fx, fy, radius) in _stars) {
        canvas.drawCircle(Offset(fx * size.x, fy * size.y), radius, star);
      }
    }
  }
}
