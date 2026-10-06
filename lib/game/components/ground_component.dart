import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../dash_game.dart';
import '../game_config.dart';

// Piso con línea brillante y baldosas que avanzan a la velocidad de los obstáculos
class GroundComponent extends Component with HasGameReference<DashGame> {
  double _desplazamiento = 0; // Distancia recorrida

  void reiniciar() => _desplazamiento = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _desplazamiento += GameConfig.velocidadObstaculo * dt;
  }

  @override
  void render(Canvas canvas) {
    final ancho = game.size.x;
    final arriba = game.bordePiso;

    canvas.drawRect(
      Rect.fromLTWH(0, arriba, ancho, GameConfig.alturaPiso),
      Paint()..color = game.esNoche ? AppColors.pisoNoche : AppColors.piso,
    );

    const baldosa = 40.0;
    final pincelBaldosa = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..strokeWidth = 2;
    for (var x = -(_desplazamiento % baldosa); x < ancho; x += baldosa) {
      canvas.drawLine(Offset(x, arriba), Offset(x, arriba + GameConfig.alturaPiso), pincelBaldosa);
    }

    canvas.drawLine(
      Offset(0, arriba),
      Offset(ancho, arriba),
      Paint()
        ..color = AppColors.lineaPiso
        ..strokeWidth = 3,
    );
  }
}
