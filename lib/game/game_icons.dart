import 'package:flutter/material.dart';
import '../core/theme.dart';

// Íconos del juego, cada uno con su color y la sombra azul marino de la app.
// Se dibujan en un canvas: así los usa Flame (diamante del juego, premios flotantes)
// y también Flutter (header, tienda, modales) a través de GameIconImage.
// Es la única definición de cómo se ve cada uno.
enum GameIcon {
  diamante(Icons.diamond_rounded, AppColors.diamante),
  estrella(Icons.star_rounded, AppColors.amarillo),
  trofeo(Icons.emoji_events_rounded, AppColors.cuentaPro);

  final IconData icono;
  final Color color;

  const GameIcon(this.icono, this.color);

  // Dibuja el ícono con su sombra en un cuadrado de [tamano], empezando en [en]
  void pintar(Canvas canvas, double tamano, {Offset en = Offset.zero}) {
    pintorIcono(icono, tamano, AppColors.tinta).paint(canvas, en + Offset(tamano / 20, tamano / 15));
    pintorIcono(icono, tamano, color).paint(canvas, en);
  }
}

// Ícono de Material listo para pintar en un canvas (Flame no usa widgets).
// Se guarda por ícono, tamaño y color para no recalcularlo en cada cuadro.
TextPainter pintorIcono(IconData icono, double tamano, Color color) {
  return _pintores.putIfAbsent(
    (icono.codePoint, tamano, color),
    () => TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icono.codePoint),
        style: TextStyle(fontFamily: icono.fontFamily, package: icono.fontPackage, fontSize: tamano, color: color),
      ),
      textDirection: TextDirection.ltr,
    )..layout(),
  );
}

final Map<(int, double, Color), TextPainter> _pintores = {};
