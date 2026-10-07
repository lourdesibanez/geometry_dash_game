import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../game/game_icons.dart';
import '../atoms/button.dart';
import '../atoms/game_icon_image.dart';
import '../atoms/info_box.dart';
import 'game_modal.dart';

enum ReviveChoice { revive, shop, giveUp }

// Se muestra al chocar. Pensado para entenderse sin leer: los puntos logrados,
// cuántos diamantes quedan después de revivir y UN botón grande con el costo.
class ReviveModal extends StatelessWidget {
  final int puntaje;
  final int diamantes;
  final int costo;

  const ReviveModal({super.key, required this.puntaje, required this.diamantes, required this.costo});

  // Devuelve lo que eligió el jugador
  static Future<ReviveChoice> mostrar(
    BuildContext context, {
    required int puntaje,
    required int diamantes,
    required int costo,
  }) async {
    final eleccion = await GameModal.mostrar<ReviveChoice>(
      context,
      cerrable: false, // Hay que elegir sí o sí
      constructor: (_) => ReviveModal(puntaje: puntaje, diamantes: diamantes, costo: costo),
    );
    return eleccion ?? ReviveChoice.giveUp;
  }

  @override
  Widget build(BuildContext context) {
    final alcanza = diamantes >= costo;

    return GameModal(
      titulo: '¡Chocaste!',
      color: AppColors.violeta,
      cerrable: false,
      // Una sola acción principal; terminar queda como opción secundaria abajo
      acciones: [
        alcanza
            ? Button(
                etiqueta: 'Seguir · 💎 $costo',
                icono: Icons.play_arrow_rounded,
                alPresionar: () => Navigator.pop(context, ReviveChoice.revive),
                colorFondo: AppColors.verde,
                colorTexto: AppColors.tinta,
              )
            : Button(
                etiqueta: 'Conseguir diamantes',
                icono: Icons.diamond_rounded,
                alPresionar: () => Navigator.pop(context, ReviveChoice.shop),
                colorFondo: AppColors.rosa,
              ),
      ],
      pie: Semantics(
        button: true,
        child: GestureDetector(
          onTap: () => Navigator.pop(context, ReviveChoice.giveUp),
          child: const Text(
            'Terminar partida',
            style: TextStyle(
              color: AppColors.crema,
              fontWeight: FontWeight.w800,
              fontSize: 14,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.crema,
            ),
          ),
        ),
      ),
      contenido: Column(
        children: [
          // Lo que lograste, bien grande
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const GameIconImage(GameIcon.estrella, tamano: 30),
                const SizedBox(width: 6),
                Text(
                  '$puntaje puntos',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 24,
                    shadows: [Shadow(color: AppColors.tinta, offset: Offset(1.5, 2))],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // La consecuencia, visual: diamantes antes → después (o cuántos faltan)
          InfoBox.personalizado(
            contenido: Column(
              children: [
                // FittedBox: con cantidades grandes o pantallas angostas se achica en vez de desbordar
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: alcanza
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _Saldo(diamantes),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Icon(Icons.arrow_forward_rounded, color: AppColors.tintaSuave, size: 26),
                            ),
                            _Saldo(diamantes - costo),
                          ],
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Te faltan ',
                              style: TextStyle(color: AppColors.tinta, fontWeight: FontWeight.w800, fontSize: 18),
                            ),
                            _Saldo(costo - diamantes),
                          ],
                        ),
                ),
                const SizedBox(height: 6),
                Text(
                  alcanza ? 'Seguís desde donde chocaste' : 'Seguir cuesta 💎 $costo',
                  style: const TextStyle(color: AppColors.tintaSuave, fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Cantidad de diamantes con su ícono, para mostrar el antes y el después
class _Saldo extends StatelessWidget {
  final int cantidad;

  const _Saldo(this.cantidad);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const GameIconImage(GameIcon.diamante),
        const SizedBox(width: 4),
        Text(
          '$cantidad',
          style: const TextStyle(color: AppColors.tinta, fontWeight: FontWeight.w900, fontSize: 22),
        ),
      ],
    );
  }
}
