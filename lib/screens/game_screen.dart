import 'package:flutter/material.dart';
import '../components/organisms/header.dart';
import '../components/organisms/control_panel.dart';
import '../components/organisms/game_canvas.dart';
import '../components/molecules/shop_modal.dart';
import '../components/molecules/revive_modal.dart';
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
  static const int _reviveCost = 10;

  bool get _isPro => _playerState.accountType == 'pro';

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final state = await StorageService.getPlayerState();
    setState(() {
      _playerState = state;
    });
  }

  Future<void> _updateState(PlayerState newState) async {
    setState(() {
      _playerState = newState;
    });
    await StorageService.savePlayerState(newState);
  }

  // Usado por INICIAR, NUEVA PARTIDA y REINICIAR: siempre arranca de cero
  void _handleStart() {
    _updateState(_playerState.copyWith(score: 0));
    setState(() {
      _round++;
      _hasRevived = false;
      _gameState = GameState.playing;
    });
  }

  void _handlePause() {
    setState(() => _gameState = GameState.paused);
  }

  void _handleResume() {
    setState(() => _gameState = GameState.playing);
  }

  void _handleRestartWithAd() {
    // PRO no ve publicidad
    if (_isPro) {
      _handleStart();
      return;
    }
    // Pausamos para que el juego no siga corriendo detrás de la publicidad
    setState(() => _gameState = GameState.paused);
    AdModal.show(context, _handleStart);
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
    final choice = await ReviveModal.show(context, diamonds: _playerState.diamonds, cost: _reviveCost);
    if (!mounted) return;

    switch (choice) {
      case ReviveChoice.revive:
        _updateState(_playerState.copyWith(diamonds: _playerState.diamonds - _reviveCost));
        setState(() {
          _hasRevived = true;
          _reviveCount++;
          _gameState = GameState.playing;
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
    );
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

  void _buyPro() {
    _updateState(_playerState.copyWith(accountType: 'pro'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          GestureDetector(
            onTap: _openShop,
            child: Header(
              playerState: _playerState,
              onToggleTheme: () {
                final newDark = !_playerState.isDarkMode;
                _updateState(_playerState.copyWith(isDarkMode: newDark));
                widget.onToggleTheme(newDark);
              },
            ),
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