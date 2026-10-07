import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../game/game_icons.dart';
import '../atoms/game_icon_image.dart';
import '../atoms/game_label.dart';
import '../atoms/info_box.dart';

// Resumen al terminar la partida: puntos, récord y diamantes agarrados.
// Sin botones: NUEVA PARTIDA está en la botonera, fuera del juego.
class GameOverCard extends StatelessWidget {
  final int puntaje;
  final int record;
  final bool nuevoRecord;
  final int diamantesAgarrados;

  const GameOverCard({
    super.key,
    required this.puntaje,
    required this.record,
    required this.nuevoRecord,
    required this.diamantesAgarrados,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const GameLabel('¡GAME OVER!', color: AppColors.rosa, colorTexto: Colors.white, tamanoLetra: 26),
          if (nuevoRecord) ...[
            const SizedBox(height: 10),
            const GameLabel('🏆 ¡NUEVO RÉCORD!', color: AppColors.amarillo, tamanoLetra: 15),
          ],
          const SizedBox(height: 14),
          InfoBox.personalizado(
            contenido: Column(
              children: [
                _Fila(icono: GameIcon.estrella, etiqueta: 'Puntos', valor: '$puntaje'),
                _Fila(icono: GameIcon.trofeo, etiqueta: 'Récord', valor: '$record'),
                _Fila(icono: GameIcon.diamante, etiqueta: 'Diamantes', valor: '+$diamantesAgarrados'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Una línea del resumen: ícono, etiqueta a la izquierda y valor a la derecha
class _Fila extends StatelessWidget {
  final GameIcon icono;
  final String etiqueta;
  final String valor;

  const _Fila({required this.icono, required this.etiqueta, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          GameIconImage(icono, tamano: 22),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              etiqueta,
              style: const TextStyle(color: AppColors.tinta, fontWeight: FontWeight.w700, fontSize: 15),
            ),
          ),
          Text(
            valor,
            style: const TextStyle(color: AppColors.tinta, fontWeight: FontWeight.w900, fontSize: 18),
          ),
        ],
      ),
    );
  }
}
