import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/game_state.dart';
import '../atoms/button.dart';

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
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 4, 12, 12),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.ink, width: 3),
          boxShadow: const [
            BoxShadow(color: AppColors.ink, offset: Offset(0, 5), blurRadius: 0),
          ],
        ),
        // Solo se muestran los botones que sirven en cada estado
        child: Row(
          children: [
            if (gameState == GameState.idle)
              Expanded(
                child: Button(
                  label: 'Iniciar partida',
                  icon: Icons.play_arrow_rounded,
                  onPress: onStart,
                  backgroundColor: AppColors.green,
                ),
              ),
            if (gameState == GameState.playing) ...[
              Expanded(
                child: Button(
                  label: 'Pausar',
                  icon: Icons.pause_rounded,
                  onPress: onPause,
                  backgroundColor: AppColors.yellow,
                  textColor: AppColors.ink,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Button(
                  label: 'Reiniciar',
                  icon: Icons.replay_rounded,
                  onPress: onRestart,
                  backgroundColor: AppColors.orange,
                ),
              ),
            ],
            if (gameState == GameState.paused) ...[
              Expanded(
                child: Button(
                  label: 'Reanudar',
                  icon: Icons.play_arrow_rounded,
                  onPress: onResume,
                  backgroundColor: AppColors.green,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Button(
                  label: 'Reiniciar',
                  icon: Icons.replay_rounded,
                  onPress: onRestart,
                  backgroundColor: AppColors.orange,
                ),
              ),
            ],
            if (gameState == GameState.gameOver)
              Expanded(
                child: Button(
                  label: 'Nueva partida',
                  icon: Icons.add_rounded,
                  onPress: onNewGame,
                  backgroundColor: AppColors.pink,
                ),
              ),
          ],
        ),
      ),
    );
  }
}