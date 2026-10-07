// Física y medidas del juego, en píxeles y segundos.
class GameConfig {
  static const double gravedad = 1800;
  static const double velocidadSalto = 630;
  static const double duracionSalto = 2 * velocidadSalto / gravedad; // ~0.7 s
  // Altura máxima del salto (v² / 2g ≈ 110 px): ahí flotan los diamantes
  static const double alturaMaximaSalto = velocidadSalto * velocidadSalto / (2 * gravedad);
  static const double tiempoSaltoAnticipado = 0.15; // Tap un poco antes de aterrizar igual cuenta

  static const double velocidadObstaculo = 220;
  static const double alturaPiso = 40;
  static const double tamanoCubo = 44;
  static const double posicionCuboX = 0.25; // Cubo a la izquierda: más tiempo para reaccionar
  static const double tamanoObstaculo = 36;
  static const double tamanoDiamante = 30;
  static const double margenHitbox = 6; // Hitbox más chica que el dibujo: rozar no mata

  static const double maximoTiempoCuadro = 0.05; // Evita saltos de física si un cuadro tarda mucho
}
