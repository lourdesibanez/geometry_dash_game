import 'package:flutter/material.dart';
import '../controllers/game_controller.dart';
import '../core/theme.dart';
import '../components/organisms/header.dart';
import '../components/organisms/control_panel.dart';
import '../components/organisms/game_canvas.dart';
import '../components/molecules/shop_modal.dart';
import '../components/molecules/ad_modal.dart';
import '../components/molecules/revive_modal.dart';
import '../components/molecules/account_modal.dart';
import '../components/molecules/game_modal.dart';

// Pantalla principal: arma la interfaz y muestra los modales.
// Las reglas del juego viven en GameController; acá solo se le dice qué hacer.
class GameScreen extends StatefulWidget {
  final GameController controller;

  const GameScreen({super.key, required this.controller});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  GameController get _game => widget.controller;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final gift = await _game.load();
    if (!mounted || gift == 0) return;
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

  Future<void> _handleRestartWithAd() async {
    // Pausamos para que el juego no siga corriendo detrás de los modales
    _game.pause();

    final confirmed = await GameModal.confirm(
      context,
      title: '¿Reiniciar?',
      message: 'Vas a perder los ${_game.player.score} puntos de esta partida '
          'y volver al inicio.',
    );
    // NO: queda en pausa para que siga cuando toque REANUDAR
    if (!confirmed || !mounted) return;

    // PRO no ve publicidad; igual vuelve a la pantalla de inicio (INICIAR PARTIDA)
    if (_game.isPro) {
      _game.backToStart();
      return;
    }
    AdModal.show(
      context,
      // Al cerrar el anuncio vuelve a la pantalla de inicio (INICIAR PARTIDA)
      _game.backToStart,
      // "PRO": abre la tienda y, al cerrarla, vuelve a la pantalla de inicio
      onRemoveAds: () async {
        await _openShop();
        if (mounted) _game.backToStart();
      },
    );
  }

  void _handlePlayerHit() {
    if (_game.hit()) _offerRevive();
  }

  Future<void> _offerRevive() async {
    final choice = await ReviveModal.show(
      context,
      score: _game.player.score,
      diamonds: _game.player.diamonds,
      cost: _game.reviveCost,
    );
    if (!mounted) return;

    switch (choice) {
      case ReviveChoice.revive:
        _game.revive();
      case ReviveChoice.shop:
        await _openShop();
        if (mounted) _offerRevive(); // Al volver de la tienda, se vuelve a ofrecer
      case ReviveChoice.giveUp:
        _game.gameOver();
    }
  }

  Future<void> _openShop() {
    return ShopModal.show(
      context,
      onBuyDiamonds: _game.buyDiamonds,
      onBuyPro: _game.buyPro,
      isPro: _game.isPro,
      diamonds: _game.player.diamonds,
    );
  }

  // Desde el header: si se está jugando, pausa para que el juego no siga detrás del modal
  void _openShopFromHeader() {
    _game.pauseIfPlaying();
    _openShop();
  }

  // Píldora de cuenta: PRO ve su suscripción (y puede cancelarla); BASIC va a la tienda
  void _handleAccountTap() {
    if (!_game.isPro) {
      _openShopFromHeader();
      return;
    }
    _game.pauseIfPlaying();
    AccountModal.show(
      context,
      nextGiftAt: _game.nextProGiftAt,
      onCancelPro: _game.cancelPro,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Se redibuja cada vez que el controller llama a notifyListeners()
    return ListenableBuilder(
      listenable: _game,
      builder: (context, _) => Scaffold(
        body: Column(
          children: [
            Header(
              playerState: _game.player,
              onOpenShop: _openShopFromHeader,
              onAccountTap: _handleAccountTap,
              onToggleTheme: _game.toggleTheme,
            ),
            Expanded(
              child: GameCanvas(
                gameState: _game.gameState,
                round: _game.round,
                reviveCount: _game.reviveCount,
                onPlayerHit: _handlePlayerHit,
                onScoreTick: _game.addScore,
                onDiamondCollected: _game.collectDiamond,
              ),
            ),
            ControlPanel(
              gameState: _game.gameState,
              onStart: _game.startGame,
              onPause: _game.pause,
              onResume: _game.resume,
              onRestart: _handleRestartWithAd,
              onNewGame: _game.startGame,
            ),
          ],
        ),
      ),
    );
  }
}
