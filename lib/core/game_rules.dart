// Reglas de negocio del juego: si cambia un precio o un premio, se cambia solo acá
class GameRules {
  static const int puntosPorObstaculo = 10; // Puntos por cada obstáculo esquivado
  static const int diamantesIniciales = 50; // Diamantes con los que arranca un jugador nuevo

  // Diamantes para agarrar en el juego: aparecen flotando sobre el pincho
  static const int obstaculosPorDiamante = 3; // Uno de cada 3 pinchos trae diamante
  static const int diamantesPorAgarrar = 1;

  // Revivir (una vez por partida)
  static const int costoRevivirBasic = 10;
  static const int costoRevivirPro = 5;
  static const int segundosCuentaRegresiva = 3; // Después de revivir: 3, 2, 1 y sigue solo

  // Cuenta PRO
  static const int diamantesMensualesPro = 50; // Regalo mensual
  static const Duration periodoRegaloPro = Duration(days: 30);
  static const String precioMensualPro = '\$ 3,99';
}
