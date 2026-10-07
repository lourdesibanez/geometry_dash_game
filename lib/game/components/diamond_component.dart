import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../game_config.dart';
import '../game_icons.dart';

// Diamante para agarrar saltando (mismo dibujo que el header y la tienda: GameIcon.diamante).
// La hitbox no se achica: para agarrarlo alcanza con rozarlo.
class DiamondComponent extends PositionComponent {
  DiamondComponent() : super(size: Vector2.all(GameConfig.tamanoDiamante));

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());
  }

  @override
  void render(Canvas canvas) => GameIcon.diamante.pintar(canvas, size.x);
}
