// Reglas de negocio del juego: si cambia un precio o un premio, se cambia solo acá
class GameRules {
  static const int pointsPerObstacle = 10; // Puntos por cada obstáculo esquivado
  static const int initialDiamonds = 50; // Diamantes con los que arranca un jugador nuevo

  // Revivir (una vez por partida)
  static const int reviveCostBasic = 10;
  static const int reviveCostPro = 5;

  // Cuenta PRO
  static const int proMonthlyDiamonds = 50; // Regalo mensual
  static const Duration proGiftPeriod = Duration(days: 30);
  static const String proMonthlyPrice = '\$ 3,99';
}
