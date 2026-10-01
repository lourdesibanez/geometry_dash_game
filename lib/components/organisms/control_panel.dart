import 'package:flutter/material.dart';
import '../atoms/button.dart';

enum GameState { idle, playing, paused, gameOver }

class ControlPanel extends StatelessWidget {
  final GameState gameState;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onNewGame;

  const ControlPanel({
    super.key,
    required this.gameState,
    required this.onStart,
    required this.onPause,
    required this.onResume,
    required this.onRestart,
    required this.onNewGame,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Botones principales según el estado del juego
            Row(
              children: [
                if (gameState == GameState.idle)
                  Expanded(
                    child: Button(
                      label: 'INICIAR PARTIDA',
                      onPress: onStart,
                      backgroundColor: Colors.green,
                    ),
                  ),
                if (gameState == GameState.playing) ...[
                  Expanded(
                    child: Button(
                      label: 'PAUSAR',
                      onPress: onPause,
                      backgroundColor: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Button(
                      label: 'REINICIAR',
                      onPress: onRestart,
                      backgroundColor: Colors.redAccent,
                    ),
                  ),
                ],
                if (gameState == GameState.paused) ...[
                  Expanded(
                    child: Button(
                      label: 'REANUDAR',
                      onPress: onResume,
                      backgroundColor: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Button(
                      label: 'REINICIAR',
                      onPress: onRestart,
                      backgroundColor: Colors.redAccent,
                    ),
                  ),
                ],
                if (gameState == GameState.gameOver)
                  Expanded(
                    child: Button(
                      label: 'NUEVA PARTIDA',
                      onPress: onNewGame,
                      backgroundColor: Colors.green,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}