import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../atoms/button.dart';
import '../atoms/info_box.dart';
import 'game_modal.dart';

enum ReviveChoice { revive, shop, giveUp }

class ReviveModal extends StatelessWidget {
  final int score;
  final int diamonds;
  final int cost;

  const ReviveModal({super.key, required this.score, required this.diamonds, required this.cost});

  // Devuelve lo que eligió el jugador
  static Future<ReviveChoice> show(
    BuildContext context, {
    required int score,
    required int diamonds,
    required int cost,
  }) async {
    final choice = await GameModal.show<ReviveChoice>(
      context,
      canDismiss: false, // Hay que elegir sí o sí
      builder: (_) => ReviveModal(score: score, diamonds: diamonds, cost: cost),
    );
    return choice ?? ReviveChoice.giveUp;
  }

  @override
  Widget build(BuildContext context) {
    final canAfford = diamonds >= cost;

    return GameModal(
      title: '¡Chocaste!',
      color: AppColors.yellow,
      titleColor: Colors.white,
      canDismiss: false,
      actions: [
        Button(
          label: 'Terminar',
          onPress: () => Navigator.pop(context, ReviveChoice.giveUp),
          backgroundColor: AppColors.cream,
          textColor: AppColors.ink,
        ),
        Button(
          // Texto corto: así los dos botones tienen letra del mismo tamaño (el costo está arriba)
          label: canAfford ? 'Seguir' : 'Tienda',
          icon: canAfford ? null : Icons.diamond_rounded,
          onPress: () => Navigator.pop(context, canAfford ? ReviveChoice.revive : ReviveChoice.shop),
          backgroundColor: AppColors.pink,
        ),
      ],
      child: Column(
        children: [
          Text(
            'Hiciste $score puntos · Tenés $diamonds 💎',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.ink, fontWeight: FontWeight.w800, fontSize: 14),
          ),
          const SizedBox(height: 10),
          InfoBox(
            canAfford
                ? '¿Usás $cost 💎 para seguir desde donde chocaste?'
                : 'Necesitás $cost 💎 para seguir. ¡Conseguilos en la tienda!',
          ),
        ],
      ),
    );
  }
}
