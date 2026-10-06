import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../game_config.dart';

// Diamante para agarrar saltando (mismo ícono que el header y la tienda).
// La hitbox no se achica: para agarrarlo alcanza con rozarlo.
class DiamondComponent extends PositionComponent {
  DiamondComponent() : super(size: Vector2.all(GameConfig.tamanoDiamante));

  static final _sombra = _pintorDiamante(AppColors.tinta);
  static final _icono = _pintorDiamante(AppColors.diamante);

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());
  }

  @override
  void render(Canvas canvas) {
    _sombra.paint(canvas, const Offset(1.5, 2));
    _icono.paint(canvas, Offset.zero);
  }
}

TextPainter _pintorDiamante(Color color) {
  const icono = Icons.diamond_rounded;
  return TextPainter(
    text: TextSpan(
      text: String.fromCharCode(icono.codePoint),
      style: TextStyle(
        fontFamily: icono.fontFamily,
        package: icono.fontPackage,
        fontSize: GameConfig.tamanoDiamante,
        color: color,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
}
