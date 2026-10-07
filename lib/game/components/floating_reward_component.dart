import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../game_icons.dart';

// Premio flotante ("+1" con diamante al agarrar uno, "+10" con estrella al esquivar):
// aparece, sube y se desvanece con efectos de Flame, y se borra solo al terminar.
// Como los efectos avanzan con el dt del juego, en pausa se congela igual que todo.
class FloatingRewardComponent extends PositionComponent implements OpacityProvider {
  static const double _duracion = 0.8; // Segundos
  static const double _subida = 60; // Píxeles que sube
  static const double _tamanoLetra = 22;

  final GameIcon _icono;
  final TextPainter _texto;
  final TextPainter _sombraTexto;
  double _opacidad = 1;

  FloatingRewardComponent({
    required String texto,
    required GameIcon icono,
    required Vector2 posicion,
    Anchor ancla = Anchor.bottomCenter,
  })  : _icono = icono,
        _texto = _pintorTexto(texto, icono.color),
        _sombraTexto = _pintorTexto(texto, AppColors.tinta),
        super(position: posicion, anchor: ancla);

  @override
  double get opacity => _opacidad;

  @override
  set opacity(double valor) => _opacidad = valor;

  @override
  Future<void> onLoad() async {
    size = Vector2(_texto.width + 2 + _tamanoLetra, math.max(_texto.height, _tamanoLetra));
    addAll([
      MoveByEffect(Vector2(0, -_subida), EffectController(duration: _duracion, curve: Curves.easeOut)),
      OpacityEffect.fadeOut(EffectController(duration: _duracion, curve: Curves.easeIn)),
      RemoveEffect(delay: _duracion),
    ]);
  }

  @override
  void render(Canvas canvas) {
    // Una capa con la opacidad actual: así texto, ícono y sombras se desvanecen juntos
    canvas.saveLayer(null, Paint()..color = Colors.white.withValues(alpha: _opacidad));
    final yTexto = (size.y - _texto.height) / 2;
    _sombraTexto.paint(canvas, Offset(1.5, yTexto + 2));
    _texto.paint(canvas, Offset(0, yTexto));
    _icono.pintar(canvas, _tamanoLetra, en: Offset(_texto.width + 2, (size.y - _tamanoLetra) / 2));
    canvas.restore();
  }

  static TextPainter _pintorTexto(String texto, Color color) {
    return TextPainter(
      text: TextSpan(
        text: texto,
        style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: _tamanoLetra),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
  }
}
