// Física y medidas del juego, en píxeles y segundos.
// Ajustada para niños: salto alto y con margen, pero con la sensación de
// Geometry Dash (sube rápido, flota, cae acelerando).
class GameConfig {
  static const double gravity = 1800;
  static const double jumpVelocity = 630;
  static const double airTime = 2 * jumpVelocity / gravity; // ~0.7 s
  // Altura máxima del salto (v² / 2g ≈ 110 px): ahí flotan los diamantes
  static const double jumpPeak = jumpVelocity * jumpVelocity / (2 * gravity);
  static const double jumpBufferTime = 0.15; // Tap un poco antes de aterrizar igual cuenta

  static const double obstacleSpeed = 220;
  static const double groundHeight = 40;
  static const double cubeSize = 44;
  static const double cubeXFactor = 0.25; // Cubo a la izquierda: más tiempo para reaccionar
  static const double obstacleSize = 36;
  static const double diamondSize = 30;
  static const double hitboxInset = 6; // Hitbox más chica que el dibujo: rozar no mata

  static const double maxFrameTime = 0.05; // Evita saltos de física si un cuadro tarda mucho
}
