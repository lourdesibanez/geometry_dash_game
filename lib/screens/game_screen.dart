import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../components/organisms/header.dart';
import '../components/organisms/control_panel.dart';
import '../components/organisms/game_canvas.dart';
import '../components/molecules/shop_modal.dart';
import '../components/molecules/ad_modal.dart';
import '../components/molecules/revive_modal.dart';
import '../components/molecules/account_modal.dart';
import '../components/molecules/game_modal.dart';
import '../services/storage_service.dart';

class GameScreen extends StatefulWidget {
  final Function(bool) onToggleTheme;

  const GameScreen({super.key, required this.onToggleTheme});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  PlayerState _playerState = PlayerState.initial();
  GameState _gameState = GameState.idle;
  int _round = 0; // Se incrementa en cada partida nueva para resetear el canvas
  int _reviveCount = 0;
  bool _hasRevived = false; // Un solo revivir por partida

  static const Duration _proGiftPeriod = Duration(days: 30);

  bool get _isPro => _playerState.accountType == 'pro';

  // PRO revive a mitad de precio
  int get _reviveCost => _isPro ? 5 : 10;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final state = await StorageService.getPlayerState();
    if (!mounted) return;
    setState(() {
      _playerState = state;
    });
    _grantMonthlyProDiamonds();
  }

  // Entrega los diamantes mensuales de PRO que se hayan acumulado desde la última vez
  void _grantMonthlyProDiamonds() {
    if (!_isPro) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    final last = _playerState.lastProGiftAt;

    // Cuentas PRO anteriores a esta función: empiezan a contar desde hoy
    if (last == null) {
      _updateState(_playerState.copyWith(lastProGiftAt: now));
      return;
    }

    final periods = (now - last) ~/ _proGiftPeriod.inMilliseconds;
    if (periods <= 0) return;

    final gift = periods * ShopModal.proMonthlyDiamonds;
    _updateState(_playerState.copyWith(
      diamonds: _playerState.diamonds + gift,
      lastProGiftAt: last + periods * _proGiftPeriod.inMilliseconds,
    ));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.ink,
        content: Text(
          '¡Recibiste $gift 💎 de tu cuenta PRO!',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
    );
  }

  Future<void> _updateState(PlayerState newState) async {
    setState(() {
      _playerState = newState;
    });
    await StorageService.savePlayerState(newState);
  }

  // Usado por INICIAR, NUEVA PARTIDA y REINICIAR: siempre arranca de cero
  void _handleStart() => _resetRound(GameState.playing);

  // Partida nueva desde cero; con GameState.idle vuelve a la pantalla de INICIAR PARTIDA
  void _resetRound(GameState startState) {
    _updateState(_playerState.copyWith(score: 0));
    setState(() {
      _round++;
      _hasRevived = false;
      _gameState = startState;
    });
  }

  void _handlePause() {
    setState(() => _gameState = GameState.paused);
  }

  void _handleResume() {
    setState(() => _gameState = GameState.playing);
  }

  Future<void> _handleRestartWithAd() async {
    // Pausamos para que el juego no siga corriendo detrás de los modales
    setState(() => _gameState = GameState.paused);

    final confirmed = await GameModal.confirm(
      context,
      title: '¿Reiniciar?',
      message: 'Vas a perder los ${_playerState.score} puntos de esta partida '
          'y volver al inicio.',
    );
    // NO: queda en pausa para que siga cuando toque REANUDAR
    if (!confirmed || !mounted) return;

    // PRO no ve publicidad; igual vuelve a la pantalla de inicio (INICIAR PARTIDA)
    if (_isPro) {
      _resetRound(GameState.idle);
      return;
    }
    AdModal.show(
      context,
      // Al cerrar el anuncio vuelve a la pantalla de inicio (INICIAR PARTIDA)
      () => _resetRound(GameState.idle),
      // "PRO": abre la tienda y, al cerrarla, vuelve a la pantalla de inicio
      onRemoveAds: () async {
        await _openShop();
        if (mounted) _resetRound(GameState.idle);
      },
    );
  }

  void _handlePlayerHit() {
    if (_hasRevived) {
      _handleGameOver();
      return;
    }
    // Congelamos el juego mientras se decide si revivir
    setState(() => _gameState = GameState.paused);
    _offerRevive();
  }

  Future<void> _offerRevive() async {
    final choice = await ReviveModal.show(
      context,
      score: _playerState.score,
      diamonds: _playerState.diamonds,
      cost: _reviveCost,
    );
    if (!mounted) return;

    switch (choice) {
      case ReviveChoice.revive:
        _updateState(_playerState.copyWith(diamonds: _playerState.diamonds - _reviveCost));
        // Queda en pausa: el jugador sigue cuando toca REANUDAR, no de golpe
        setState(() {
          _hasRevived = true;
          _reviveCount++;
          _gameState = GameState.paused;
        });
      case ReviveChoice.shop:
        await _openShop();
        if (mounted) _offerRevive(); // Al volver de la tienda, se vuelve a ofrecer
      case ReviveChoice.giveUp:
        _handleGameOver();
    }
  }

  Future<void> _openShop() {
    return ShopModal.show(
      context,
      onBuyDiamonds: _buyDiamonds,
      onBuyPro: _buyPro,
      isPro: _isPro,
      diamonds: _playerState.diamonds,
    );
  }

  // Desde el header: si se está jugando, pausa para que el juego no siga detrás del modal
  void _openShopFromHeader() {
    if (_gameState == GameState.playing) _handlePause();
    _openShop();
  }

  // Píldora de cuenta: PRO ve su suscripción (y puede cancelarla); BASIC va a la tienda
  void _handleAccountTap() {
    if (!_isPro) {
      _openShopFromHeader();
      return;
    }
    if (_gameState == GameState.playing) _handlePause();
    final last = _playerState.lastProGiftAt;
    AccountModal.show(
      context,
      nextGiftAt: last != null
          ? DateTime.fromMillisecondsSinceEpoch(last).add(_proGiftPeriod)
          : null,
      monthlyDiamonds: ShopModal.proMonthlyDiamonds,
      onCancelPro: _cancelPro,
    );
  }

  // Vuelve a BASIC; los diamantes que ya tiene se quedan
  void _cancelPro() {
    _updateState(_playerState.copyWith(accountType: 'basic'));
  }

  void _handleGameOver() {
    setState(() => _gameState = GameState.gameOver);
  }

  void _addScore() {
    _updateState(_playerState.copyWith(score: _playerState.score + 10));
  }

  void _buyDiamonds(int amount) {
    _updateState(_playerState.copyWith(diamonds: _playerState.diamonds + amount));
  }

  // PRO: sin publicidad + revivir más barato + diamantes mensuales (el primer mes se entrega ya)
  void _buyPro() {
    _updateState(_playerState.copyWith(
      accountType: 'pro',
      diamonds: _playerState.diamonds + ShopModal.proMonthlyDiamonds,
      lastProGiftAt: DateTime.now().millisecondsSinceEpoch,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Header(
            playerState: _playerState,
            onOpenShop: _openShopFromHeader,
            onAccountTap: _handleAccountTap,
            onToggleTheme: () {
              final newDark = !_playerState.isDarkMode;
              _updateState(_playerState.copyWith(isDarkMode: newDark));
              widget.onToggleTheme(newDark);
            },
          ),
          Expanded(
            child: GameCanvas(
              gameState: _gameState,
              round: _round,
              reviveCount: _reviveCount,
              onPlayerHit: _handlePlayerHit,
              onScoreTick: _addScore,
            ),
          ),
          ControlPanel(
            gameState: _gameState,
            onStart: _handleStart,
            onPause: _handlePause,
            onResume: _handleResume,
            onRestart: _handleRestartWithAd,
            onNewGame: _handleStart,
          ),
        ],
      ),
    );
  }
}