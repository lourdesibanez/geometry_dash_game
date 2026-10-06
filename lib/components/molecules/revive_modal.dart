import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../atoms/button.dart';
import '../atoms/info_box.dart';
import 'game_modal.dart';

enum ReviveChoice { revive, shop, giveUp }

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
      color: AppColors.amarillo,
      colorTitulo: Colors.white,
      cerrable: false,
      acciones: [
        Button(
          etiqueta: 'Terminar',
          alPresionar: () => Navigator.pop(context, ReviveChoice.giveUp),
          colorFondo: AppColors.crema,
          colorTexto: AppColors.tinta,
        ),
        Button(
          // Texto corto: así los dos botones tienen letra del mismo tamaño (el costo está arriba)
          etiqueta: alcanza ? 'Seguir' : 'Tienda',
          icono: alcanza ? null : Icons.diamond_rounded,
          alPresionar: () => Navigator.pop(context, alcanza ? ReviveChoice.revive : ReviveChoice.shop),
          colorFondo: AppColors.rosa,
        ),
      ],
      contenido: Column(
        children: [
          Text(
            'Hiciste $puntaje puntos · Tenés $diamantes 💎',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.tinta, fontWeight: FontWeight.w800, fontSize: 14),
          ),
          const SizedBox(height: 10),
          InfoBox(
            alcanza
                ? '¿Usás $costo 💎 para seguir desde donde chocaste?'
                : 'Necesitás $costo 💎 para seguir. ¡Conseguilos en la tienda!',
          ),
        ],
      ),
    );
  }
}
