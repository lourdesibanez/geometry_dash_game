import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../core/game_rules.dart';
import '../../core/theme.dart';
import '../dash_game.dart';
import '../game_config.dart';
import 'diamond_component.dart';

// Obstáculo: dos pinchos que avanzan hacia el cubo. Al salir por la izquierda
// vuelve a entrar por la derecha como un pincho nuevo (y suma puntos).
// Uno de cada N trae un diamante flotando encima.
class ObstacleComponent extends PositionComponent with HasGameReference<DashGame> {
  ObstacleComponent() : super(size: Vector2.all(GameConfig.obstacleSize));

  double? _x; // null = todavía no entró (aparece en el borde derecho)
  int _count = 1; // Cuántos pinchos aparecieron en la partida (el actual incluido)
  DiamondComponent? _diamond;

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox(
      position: Vector2.all(GameConfig.hitboxInset),
      size: size - Vector2.all(GameConfig.hitboxInset * 2),
    ));
  }

  void reset() {
    _x = null;
    _count = 1;
    removeDiamond();
  }

  void respawnAtEdge() => _x = null;

  void removeDiamond() {
    _diamond?.removeFromParent();
    _diamond = null;
  }

  void _spawnDiamond() {
    if (_diamond != null) return;
    // Centrado sobre el pincho y a la altura máxima del salto
    final diamond = DiamondComponent()
      ..position = Vector2(
        (size.x - GameConfig.diamondSize) / 2,
        size.y - GameConfig.jumpPeak - GameConfig.diamondSize / 2,
      );
    _diamond = diamond;
    add(diamond);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (game.size.x <= 0) return; // Todavía sin tamaño

    var x = (_x ?? game.size.x) - GameConfig.obstacleSpeed * dt;
    if (x < -size.x) {
      x = game.size.x;
      _count++;
      game.onScoreTick();
      if (_count % GameRules.obstaclesPerDiamond == 0) {
        _spawnDiamond();
      } else {
        removeDiamond();
      }
    }
    _x = x;
    position.setValues(x, game.groundTop - size.y);
  }

  @override
  void render(Canvas canvas) {
    final fill = Paint()..color = AppColors.ink;
    final stroke = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeJoin = StrokeJoin.round;
    final half = size.x / 2;
    final top = size.y * 0.15; // Puntas cerca del borde de la hitbox

    for (var i = 0; i < 2; i++) {
      final left = i * half;
      final path = Path()
        ..moveTo(left, size.y)
        ..lineTo(left + half / 2, top)
        ..lineTo(left + half, size.y)
        ..close();
      canvas.drawPath(path, fill);
      canvas.drawPath(path, stroke);
    }
  }
}
