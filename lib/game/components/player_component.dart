import 'dart:math' as math;
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../services/audio_service.dart';
import '../dash_game.dart';
import '../game_config.dart';
import '../game_icons.dart';
import 'diamond_component.dart';
import 'obstacle_component.dart';

// Personaje componente del juego: cubo amarillo con carita que salta con gravedad y da una vuelta por salto
class PlayerComponent extends PositionComponent with HasGameReference<DashGame>, CollisionCallbacks {
  PlayerComponent() : super(size: Vector2.all(GameConfig.tamanoCubo));

  double _altura = 0; // Altura sobre el piso
  double _velocidad = 0;
  double _tiempoEnAire = 0;
  double _saltoAnticipado = 0;

  bool get enElAire => _altura > 0 || _velocidad > 0;

  // Una vuelta completa por salto: la carita siempre aterriza derecha
  double get _giro => enElAire ? 2 * math.pi * (_tiempoEnAire / GameConfig.duracionSalto).clamp(0.0, 1.0) : 0;

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

  // Suena acá (y no al tocar) para que el salto anticipado suene cuando de verdad salta
  void _iniciarSalto() {
    AudioService.salto();
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
    dibujarCubo(canvas, size.x);
    canvas.restore();
  }

  // Dibujo del personaje: cubo amarillo con carita, desde (0, 0) y de [lado] × [lado].
  // Es la única definición del aspecto del cubo: la usan el juego y el avatar del header.
  static void dibujarCubo(Canvas canvas, double lado) {
    final rect = Rect.fromLTWH(0, 0, lado, lado);
    final radio = Radius.circular(lado * 0.25);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, radio), Paint()..color = AppColors.amarillo);
    canvas.drawRRect(
      // Curva un poco menor que la del fondo: así el amarillo no asoma en las puntas
      RRect.fromRectAndRadius(rect.deflate(1.5), Radius.circular(lado * 0.25 - 1.5)),
      Paint()
        ..color = AppColors.tinta
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    final carita = pintorIcono(Icons.sentiment_very_satisfied, lado * 0.68, AppColors.tinta);
    carita.paint(canvas, Offset((lado - carita.width) / 2, (lado - carita.height) / 2));
  }
}
