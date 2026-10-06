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
  PlayerComponent() : super(size: Vector2.all(GameConfig.tamanoCubo));

  double _altura = 0; // Altura sobre el piso
  double _velocidad = 0;
  double _tiempoEnAire = 0;
  double _saltoAnticipado = 0;

  bool get enElAire => _altura > 0 || _velocidad > 0;

  // Una vuelta completa por salto: la carita siempre aterriza derecha
  double get _giro => enElAire ? 2 * math.pi * (_tiempoEnAire / GameConfig.duracionSalto).clamp(0.0, 1.0) : 0;

  static final _carita = _pintorIcono(Icons.sentiment_very_satisfied, GameConfig.tamanoCubo * 0.68, AppColors.tinta);

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox(
      position: Vector2.all(GameConfig.margenHitbox),
      size: size - Vector2.all(GameConfig.margenHitbox * 2),
    ));
  }

  void reiniciar() {
    _altura = 0;
    _velocidad = 0;
    _tiempoEnAire = 0;
    _saltoAnticipado = 0;
  }

  void saltar() {
    if (enElAire) {
      _saltoAnticipado = GameConfig.tiempoSaltoAnticipado; // Se guarda y salta apenas toque el piso
    } else {
      _iniciarSalto();
    }
  }

  void _iniciarSalto() {
    _velocidad = GameConfig.velocidadSalto;
    _tiempoEnAire = 0;
    _saltoAnticipado = 0;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_saltoAnticipado > 0) _saltoAnticipado -= dt;
    if (enElAire) {
      _velocidad -= GameConfig.gravedad * dt;
      _altura += _velocidad * dt;
      _tiempoEnAire += dt;
      if (_altura <= 0) {
        reiniciar();
        if (_saltoAnticipado > 0) _iniciarSalto();
      }
    }
    // Se recalcula siempre por si cambia el tamaño de la pantalla
    position.setValues(
      game.size.x * GameConfig.posicionCuboX - size.x / 2,
      game.bordePiso - _altura - size.y,
    );
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is ObstacleComponent) {
      game.manejarChoque();
    } else if (other is DiamondComponent) {
      game.agarrarDiamante(other);
    }
  }

  @override
  void render(Canvas canvas) {
    // Estela de cuadraditos mientras vuela (sin rotar)
    if (enElAire) {
      for (var i = 1; i <= 3; i++) {
        final lado = 12.0 - i * 2;
        canvas.drawRect(
          Rect.fromLTWH(-i * 14.0, size.y / 2 + i * 4.0, lado, lado),
          Paint()..color = AppColors.crema.withValues(alpha: 0.6 - i * 0.15),
        );
      }
    }

    // Cubo girando sobre su centro
    canvas.save();
    canvas.translate(size.x / 2, size.y / 2);
    canvas.rotate(_giro);
    canvas.translate(-size.x / 2, -size.y / 2);

    final radio = Radius.circular(size.x * 0.25);
    canvas.drawRRect(RRect.fromRectAndRadius(size.toRect(), radio), Paint()..color = AppColors.amarillo);
    canvas.drawRRect(
      RRect.fromRectAndRadius(size.toRect().deflate(1.5), radio),
      Paint()
        ..color = AppColors.tinta
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    _carita.paint(canvas, Offset((size.x - _carita.width) / 2, (size.y - _carita.height) / 2));
    canvas.restore();
  }
}

// Ícono de Material dibujado en el canvas (mismo que usa el avatar del header)
TextPainter _pintorIcono(IconData icono, double tamano, Color color) {
  return TextPainter(
    text: TextSpan(
      text: String.fromCharCode(icono.codePoint),
      style: TextStyle(fontFamily: icono.fontFamily, package: icono.fontPackage, fontSize: tamano, color: color),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
}
