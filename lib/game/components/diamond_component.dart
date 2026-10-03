import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../game_config.dart';

// Diamante para agarrar saltando (mismo ícono que el header y la tienda).
// La hitbox no se achica: para agarrarlo alcanza con rozarlo.
class DiamondComponent extends PositionComponent {
  DiamondComponent() : super(size: Vector2.all(GameConfig.diamondSize));

  static final _shadow = _diamondPainter(AppColors.ink);
  static final _icon = _diamondPainter(AppColors.diamond);

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());
  }

  @override
  void render(Canvas canvas) {
    _shadow.paint(canvas, const Offset(1.5, 2));
    _icon.paint(canvas, Offset.zero);
  }
}

TextPainter _diamondPainter(Color color) {
  const icon = Icons.diamond_rounded;
  return TextPainter(
    text: TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
        fontFamily: icon.fontFamily,
        package: icon.fontPackage,
        fontSize: GameConfig.diamondSize,
        color: color,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
}
