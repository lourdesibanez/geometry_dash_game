import 'package:flutter/foundation.dart';
import '../core/game_rules.dart';
import '../models/game_state.dart';
import '../models/player_state.dart';
import '../services/storage_service.dart';

// Lógica del juego separada de la UI (patrón ViewModel).
// Guarda el estado de la app, aplica las reglas y avisa a la UI con notifyListeners().
// La física del salto (60 cuadros por segundo) NO está acá: es estado efímero del GameCanvas.
class GameController extends ChangeNotifier {
  PlayerState _player = PlayerState.initial();
  GameState _gameState = GameState.idle;
  int _round = 0; // Se incrementa en cada partida nueva para resetear el canvas
  int _reviveCount = 0; // Se incrementa al revivir para sacar el obstáculo que nos golpeó
  bool _hasRevived = false; // Un solo revivir por partida

  // Getters de solo lectura: la UI puede leer el estado, pero solo lo cambia con los métodos
  PlayerState get player => _player;
  GameState get gameState => _gameState;
  int get round => _round;
  int get reviveCount => _reviveCount;
  bool get isPro => _player.isPro;
  bool get isDarkMode => _player.isDarkMode;
  int get reviveCost => isPro ? GameRules.reviveCostPro : GameRules.reviveCostBasic;

  // Fecha de la próxima entrega de diamantes PRO (null si nunca recibió)
  DateTime? get nextProGiftAt {
    final last = _player.lastProGiftAt;
    if (last == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(last).add(GameRules.proGiftPeriod);
  }

  // Carga lo guardado. Devuelve cuántos diamantes PRO se regalaron (0 si no correspondía)
  Future<int> load() async {
    _player = await StorageService.getPlayerState();
    notifyListeners();
    return _grantMonthlyProDiamonds();
  }

  // Entrega los diamantes mensuales de PRO que se hayan acumulado desde la última vez
  int _grantMonthlyProDiamonds() {
    if (!isPro) return 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    final last = _player.lastProGiftAt;

    // Cuentas PRO anteriores a esta función: empiezan a contar desde hoy
    if (last == null) {
      _update(_player.copyWith(lastProGiftAt: now));
      return 0;
    }

    final periods = (now - last) ~/ GameRules.proGiftPeriod.inMilliseconds;
    if (periods <= 0) return 0;

    final gift = periods * GameRules.proMonthlyDiamonds;
    _update(_player.copyWith(
      diamonds: _player.diamonds + gift,
      lastProGiftAt: last + periods * GameRules.proGiftPeriod.inMilliseconds,
    ));
    return gift;
  }

  // ---------- Partida ----------

  // INICIAR, NUEVA PARTIDA: arranca de cero y jugando
  void startGame() => _resetRound(GameState.playing);

  // Después de REINICIAR: arranca de cero en la pantalla de INICIAR PARTIDA
  void backToStart() => _resetRound(GameState.idle);

  void _resetRound(GameState startState) {
    _round++;
    _hasRevived = false;
    _gameState = startState;
    _update(_player.copyWith(score: 0));
  }

  void pause() => _setGameState(GameState.paused);

  void resume() => _setGameState(GameState.playing);

  // Antes de abrir un modal: que el juego no siga corriendo detrás
  void pauseIfPlaying() {
    if (_gameState == GameState.playing) pause();
  }

  void gameOver() => _setGameState(GameState.gameOver);

  // Suma puntos y, si se supera, actualiza el récord
  void addScore() {
    final score = _player.score + GameRules.pointsPerObstacle;
    _update(_player.copyWith(
      score: score,
      highScore: score > _player.highScore ? score : null,
    ));
  }

  // Choque con un obstáculo. Devuelve true si hay que ofrecer revivir
  bool hit() {
    if (_hasRevived) {
      gameOver();
      return false;
    }
    pause(); // Congelado mientras el jugador decide
    return true;
  }

  // Gasta diamantes para seguir. Queda en pausa: sigue cuando toque REANUDAR
  void revive() {
    if (_player.diamonds < reviveCost) return;
    _hasRevived = true;
    _reviveCount++;
    _gameState = GameState.paused;
    _update(_player.copyWith(diamonds: _player.diamonds - reviveCost));
  }

  // ---------- Tienda y cuenta ----------

  void buyDiamonds(int amount) {
    _update(_player.copyWith(diamonds: _player.diamonds + amount));
  }

  // PRO: sin publicidad + revivir más barato + diamantes mensuales (el primer mes se entrega ya)
  void buyPro() {
    _update(_player.copyWith(
      accountType: AccountType.pro,
      diamonds: _player.diamonds + GameRules.proMonthlyDiamonds,
      lastProGiftAt: DateTime.now().millisecondsSinceEpoch,
    ));
  }

  // Vuelve a BASIC; los diamantes que ya tiene se quedan
  void cancelPro() {
    _update(_player.copyWith(accountType: AccountType.basic));
  }

  void toggleTheme() {
    _update(_player.copyWith(isDarkMode: !_player.isDarkMode));
  }

  // ---------- Internos ----------

  // Cambios que no se guardan (estado de la partida en curso)
  void _setGameState(GameState state) {
    _gameState = state;
    notifyListeners();
  }

  // Cambios del jugador: se guardan en el dispositivo y se avisa a la UI
  void _update(PlayerState newState) {
    _player = newState;
    StorageService.savePlayerState(newState);
    notifyListeners();
  }
}
