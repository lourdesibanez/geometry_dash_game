import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/game_state.dart';
import '../atoms/button.dart';

class ControlPanel extends StatelessWidget {
  final GameState estadoJuego;
  final VoidCallback alIniciar;
  final VoidCallback alPausar;
  final VoidCallback alReanudar;
  final VoidCallback alReiniciar;
  final VoidCallback alNuevaPartida;

  const ControlPanel({
    super.key,
    required this.estadoJuego,
    required this.alIniciar,
    required this.alPausar,
    required this.alReanudar,
    required this.alReiniciar,
    required this.alNuevaPartida,
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
          border: Border.all(color: AppColors.tinta, width: 3),
          boxShadow: const [
            BoxShadow(color: AppColors.tinta, offset: Offset(0, 5), blurRadius: 0),
          ],
        ),
        // Solo se muestran los botones que sirven en cada estado
        child: Row(
          children: [
            if (estadoJuego == GameState.idle)
              Expanded(
                child: Button(
                  etiqueta: 'Iniciar partida',
                  icono: Icons.play_arrow_rounded,
                  alPresionar: alIniciar,
                  colorFondo: AppColors.verde,
                ),
              ),
            if (estadoJuego == GameState.playing) ...[
              Expanded(
                child: Button(
                  etiqueta: 'Pausar',
                  icono: Icons.pause_rounded,
                  alPresionar: alPausar,
                  colorFondo: AppColors.amarillo,
                  colorTexto: AppColors.tinta,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Button(
                  etiqueta: 'Reiniciar',
                  icono: Icons.replay_rounded,
                  alPresionar: alReiniciar,
                  colorFondo: AppColors.naranja,
                ),
              ),
            ],
            if (estadoJuego == GameState.paused) ...[
              Expanded(
                child: Button(
                  etiqueta: 'Reanudar',
                  icono: Icons.play_arrow_rounded,
                  alPresionar: alReanudar,
                  colorFondo: AppColors.verde,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Button(
                  etiqueta: 'Reiniciar',
                  icono: Icons.replay_rounded,
                  alPresionar: alReiniciar,
                  colorFondo: AppColors.naranja,
                ),
              ),
            ],
            if (estadoJuego == GameState.gameOver)
              Expanded(
                child: Button(
                  etiqueta: 'Nueva partida',
                  icono: Icons.add_rounded,
                  alPresionar: alNuevaPartida,
                  colorFondo: AppColors.rosa,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
