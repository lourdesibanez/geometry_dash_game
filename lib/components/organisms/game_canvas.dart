import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../../core/game_rules.dart';
import '../../core/theme.dart';
import '../../game/dash_game.dart';
import '../../models/game_state.dart';
import '../atoms/game_label.dart';

// App híbrida: el juego corre en Flame (DashGame) y se muestra dentro de un GameWidget.
// Este widget de Flutter lo controla desde afuera según el estado de la partida y
// dibuja encima los carteles (ayuda, pausa, puntos, game over).
class GameCanvas extends StatefulWidget {
  final GameState gameState;
  final int round; // Cambia en cada partida nueva/reinicio para resetear el juego
  final int reviveCount; // Cambia al revivir: se quita el obstáculo que nos golpeó
  final VoidCallback onPlayerHit;
  final VoidCallback onScoreTick;
  final VoidCallback onDiamondCollected;

  const GameCanvas({
    super.key,
    required this.gameState,
    required this.round,
    required this.reviveCount,
    required this.onPlayerHit,
    required this.onScoreTick,
    required this.onDiamondCollected,
  });

  @override
  State<GameCanvas> createState() => _GameCanvasState();
}

class _GameCanvasState extends State<GameCanvas> {
  // Los callbacks pasan por el widget actual: si el padre cambia de callback, se usa el nuevo
  late final DashGame _game = DashGame(
    onPlayerHit: () => widget.onPlayerHit(),
    onScoreTick: _handleScore,
    onDiamondCollected: _handleDiamond,
    onJump: _handleJump,
  );

  ({String text, Color color})? _pop; // Cartel flotante: "+10 PTS!" o "+1 💎"
  int _popId = 0; // Para que un cartel nuevo no se borre con el temporizador del anterior
  bool _hasJumped = false; // Para ocultar el cartel de ayuda tras el primer salto

  @override
  void initState() {
    super.initState();
    _game.running = widget.gameState == GameState.playing;
  }

  @override
  void didUpdateWidget(GameCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.round != oldWidget.round || widget.gameState == GameState.idle) {
      _game.reset();
      _hasJumped = false;
    } else if (widget.reviveCount != oldWidget.reviveCount) {
      _game.clearObstacle();
    }
    // Iniciar / pausar / reanudar se controla desde la botonera de Flutter
    _game.running = widget.gameState == GameState.playing;
  }

  void _handleScore() {
    widget.onScoreTick();
    _showPop('+${GameRules.pointsPerObstacle} PTS!', AppColors.yellow);
  }

  void _handleDiamond() {
    widget.onDiamondCollected();
    _showPop('+${GameRules.diamondsPerPickup} 💎', AppColors.diamond);
  }

  void _handleJump() {
    if (!_hasJumped) setState(() => _hasJumped = true);
  }

  // Muestra un cartel flotante por 600 ms (feedback visual)
  void _showPop(String text, Color color) {
    final id = ++_popId;
    setState(() => _pop = (text: text, color: color));
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted && id == _popId) setState(() => _pop = null);
    });
  }

  String? get _hintText {
    switch (widget.gameState) {
      case GameState.idle:
        return null; // El botón INICIAR PARTIDA ya indica qué hacer
      case GameState.playing:
        return _hasJumped ? null : 'TOCÁ LA PANTALLA PARA SALTAR';
      case GameState.paused:
        return 'PAUSA';
      case GameState.gameOver:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hint = _hintText;
    final pop = _pop;
    _game.isNight = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      label: 'Área de juego',
      hint: 'Tocá para saltar',
      // Marco turquesa con contorno azul marino
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: AppColors.teal,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.ink, width: 3),
          boxShadow: const [
            BoxShadow(color: AppColors.ink, offset: Offset(0, 5), blurRadius: 0),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.ink, width: 3),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Stack(
              children: [
                // El juego (Flame): cielo, piso, cubo, pinchos y diamantes. Los toques
                // para saltar los recibe el propio juego
                Positioned.fill(child: GameWidget(game: _game)),

                // Carteles de Flutter encima del juego. IgnorePointer: no tapan los toques
                if (hint != null)
                  Positioned(
                    top: 16,
                    left: 0,
                    right: 0,
                    child: IgnorePointer(child: Center(child: GameLabel(hint))),
                  ),

                // Cartel flotante de feedback: "+10 PTS!" al esquivar, "+1 💎" al agarrar un diamante
                if (pop != null)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: IgnorePointer(child: GameLabel(pop.text, color: pop.color, fontSize: 15)),
                  ),

                // Game over: oscurece el escenario y muestra el cartel
                if (widget.gameState == GameState.gameOver)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        color: AppColors.ink.withValues(alpha: 0.45),
                        alignment: Alignment.center,
                        child: const GameLabel(
                          '¡GAME OVER!',
                          color: AppColors.pink,
                          textColor: Colors.white,
                          fontSize: 26,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
