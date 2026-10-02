import 'package:flutter/material.dart';

enum ReviveChoice { revive, shop, giveUp }

class ReviveModal extends StatelessWidget {
  final int diamonds;
  final int cost;

  const ReviveModal({super.key, required this.diamonds, required this.cost});

  // Devuelve lo que eligió el jugador
  static Future<ReviveChoice> show(BuildContext context, {required int diamonds, required int cost}) async {
    final choice = await showDialog<ReviveChoice>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ReviveModal(diamonds: diamonds, cost: cost),
    );
    return choice ?? ReviveChoice.giveUp;
  }

  @override
  Widget build(BuildContext context) {
    final canAfford = diamonds >= cost;

    return PopScope(
      canPop: false, // El botón atrás no cierra el modal sin elegir
      child: AlertDialog(
        backgroundColor: const Color(0xFF00E5FF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.black, width: 4),
        ),
        title: const Text('¡OUCH!', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 26)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.favorite, size: 60, color: Color(0xFFFF5252)),
            const SizedBox(height: 12),
            Text(
              canAfford
                  ? '¿Usar $cost 💎 para seguir jugando?'
                  : 'Necesitás $cost 💎 para seguir jugando',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text('Tenés $diamonds 💎', style: const TextStyle(fontSize: 13)),
          ],
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, ReviveChoice.giveUp),
            child: const Text('TERMINAR', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, canAfford ? ReviveChoice.revive : ReviveChoice.shop),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFEA00),
              side: const BorderSide(color: Colors.black, width: 2.5),
            ),
            child: Text(
              canAfford ? 'REVIVIR' : 'IR A LA TIENDA',
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}
