import 'dart:math' as math;
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../dash_game.dart';
import '../game_config.dart';
import 'diamond_component.dart';
import 'obstacle_component.dart';

// Personaje: cubo amarillo con carita que salta con gravedad y da una vuelta por salto
class PlayerComponent extends PositionComponent with HasGameReference<DashGame>, CollisionCallbacks {
  PlayerComponent() : super(size: Vector2.all(GameConfig.cubeSize));

  double _height = 0; // Altura sobre el piso
  double _velocity = 0;
  double _timeInAir = 0;
  double _jumpBuffer = 0;

  bool get isAirborne => _height > 0 || _velocity > 0;

  // Una vuelta completa por salto: la carita siempre aterriza derecha
  double get _spin => isAirborne ? 2 * math.pi * (_timeInAir / GameConfig.airTime).clamp(0.0, 1.0) : 0;

  static final _face = _iconPainter(Icons.sentiment_very_satisfied, GameConfig.cubeSize * 0.68, AppColors.ink);

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox(
      position: Vector2.all(GameConfig.hitboxInset),
      size: size - Vector2.all(GameConfig.hitboxInset * 2),
    ));
  }

  void reset() {
    _height = 0;
    _velocity = 0;
    _timeInAir = 0;
    _jumpBuffer = 0;
  }

  void jump() {
    if (isAirborne) {
      _jumpBuffer = GameConfig.jumpBufferTime; // Se guarda y salta apenas toque el piso
    } else {
      _startJump();
    }
  }

  void _startJump() {
    _velocity = GameConfig.jumpVelocity;
    _timeInAir = 0;
    _jumpBuffer = 0;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_jumpBuffer > 0) _jumpBuffer -= dt;
    if (isAirborne) {
      _velocity -= GameConfig.gravity * dt;
      _height += _velocity * dt;
      _timeInAir += dt;
      if (_height <= 0) {
        reset();
        if (_jumpBuffer > 0) _startJump();
      }
    }
    // Se recalcula siempre por si cambia el tamaño de la pantalla
    position.setValues(
      game.size.x * GameConfig.cubeXFactor - size.x / 2,
      game.groundTop - _height - size.y,
    );
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is ObstacleComponent) {
      game.handleHit();
    } else if (other is DiamondComponent) {
      game.collectDiamond(other);
    }
  }

  @override
  void render(Canvas canvas) {
    // Estela de cuadraditos mientras vuela (sin rotar)
    if (isAirborne) {
      for (var i = 1; i <= 3; i++) {
        final side = 12.0 - i * 2;
        canvas.drawRect(
          Rect.fromLTWH(-i * 14.0, size.y / 2 + i * 4.0, side, side),
          Paint()..color = AppColors.cream.withValues(alpha: 0.6 - i * 0.15),
        );
      }
    }

    // Cubo girando sobre su centro
    canvas.save();
    canvas.translate(size.x / 2, size.y / 2);
    canvas.rotate(_spin);
    canvas.translate(-size.x / 2, -size.y / 2);

    final radius = Radius.circular(size.x * 0.25);
    canvas.drawRRect(RRect.fromRectAndRadius(size.toRect(), radius), Paint()..color = AppColors.yellow);
    canvas.drawRRect(
      RRect.fromRectAndRadius(size.toRect().deflate(1.5), radius),
      Paint()
        ..color = AppColors.ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    _face.paint(canvas, Offset((size.x - _face.width) / 2, (size.y - _face.height) / 2));
    canvas.restore();
  }
}

// Ícono de Material dibujado en el canvas (mismo que usa el avatar del header)
TextPainter _iconPainter(IconData icon, double size, Color color) {
  return TextPainter(
    text: TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(fontFamily: icon.fontFamily, package: icon.fontPackage, fontSize: size, color: color),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
}
