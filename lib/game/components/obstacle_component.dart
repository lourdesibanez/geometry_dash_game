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
  ObstacleComponent() : super(size: Vector2.all(GameConfig.tamanoObstaculo));

  double? _x; // null = todavía no entró (aparece en el borde derecho)
  int _cantidad = 1; // Cuántos pinchos aparecieron en la partida (el actual incluido)
  DiamondComponent? _diamante;

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox(
      position: Vector2.all(GameConfig.margenHitbox),
      size: size - Vector2.all(GameConfig.margenHitbox * 2),
    ));
  }

  void reiniciar() {
    _x = null;
    _cantidad = 1;
    quitarDiamante();
  }

  void reaparecerEnBorde() => _x = null;

  void quitarDiamante() {
    _diamante?.removeFromParent();
    _diamante = null;
  }

  void _crearDiamante() {
    if (_diamante != null) return;
    // Centrado sobre el pincho y a la altura máxima del salto
    final diamante = DiamondComponent()
      ..position = Vector2(
        (size.x - GameConfig.tamanoDiamante) / 2,
        size.y - GameConfig.alturaMaximaSalto - GameConfig.tamanoDiamante / 2,
      );
    _diamante = diamante;
    add(diamante);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (game.size.x <= 0) return; // Todavía sin tamaño

    var x = (_x ?? game.size.x) - GameConfig.velocidadObstaculo * dt;
    if (x < -size.x) {
      x = game.size.x;
      _cantidad++;
      game.alSumarPuntos();
      if (_cantidad % GameRules.obstaculosPorDiamante == 0) {
        _crearDiamante();
      } else {
        quitarDiamante();
      }
    }
    _x = x;
    position.setValues(x, game.bordePiso - size.y);
  }

  @override
  void render(Canvas canvas) {
    final relleno = Paint()..color = AppColors.tinta;
    final contorno = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeJoin = StrokeJoin.round;
    final mitad = size.x / 2;
    final punta = size.y * 0.15; // Puntas cerca del borde de la hitbox

    for (var i = 0; i < 2; i++) {
      final izquierda = i * mitad;
      final camino = Path()
        ..moveTo(izquierda, size.y)
        ..lineTo(izquierda + mitad / 2, punta)
        ..lineTo(izquierda + mitad, size.y)
        ..close();
      canvas.drawPath(camino, relleno);
      canvas.drawPath(camino, contorno);
    }
  }
}
