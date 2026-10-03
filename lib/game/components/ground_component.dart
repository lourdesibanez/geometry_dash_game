import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../dash_game.dart';
import '../game_config.dart';

// Piso con línea brillante y baldosas que avanzan a la velocidad de los obstáculos
class GroundComponent extends Component with HasGameReference<DashGame> {
  double _scroll = 0; // Distancia recorrida

  void reset() => _scroll = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _scroll += GameConfig.obstacleSpeed * dt;
  }

  @override
  void render(Canvas canvas) {
    final width = game.size.x;
    final top = game.groundTop;

    canvas.drawRect(
      Rect.fromLTWH(0, top, width, GameConfig.groundHeight),
      Paint()..color = game.isNight ? AppColors.groundNight : AppColors.ground,
    );

    const tile = 40.0;
    final tilePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..strokeWidth = 2;
    for (var x = -(_scroll % tile); x < width; x += tile) {
      canvas.drawLine(Offset(x, top), Offset(x, top + GameConfig.groundHeight), tilePaint);
    }

    canvas.drawLine(
      Offset(0, top),
      Offset(width, top),
      Paint()
        ..color = AppColors.groundLine
        ..strokeWidth = 3,
    );
  }
}
