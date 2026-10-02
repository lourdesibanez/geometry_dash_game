import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../atoms/button.dart';
import 'game_modal.dart';

// Detalle de la suscripción PRO, con opción de cancelarla (pide confirmación)
class AccountModal extends StatefulWidget {
  final DateTime? nextGiftAt;
  final int monthlyDiamonds;
  final VoidCallback onCancelPro;

  const AccountModal({
    super.key,
    required this.nextGiftAt,
    required this.monthlyDiamonds,
    required this.onCancelPro,
  });

  static Future<void> show(
    BuildContext context, {
    required DateTime? nextGiftAt,
    required int monthlyDiamonds,
    required VoidCallback onCancelPro,
  }) {
    return GameModal.show(
      context,
      builder: (_) => AccountModal(
        nextGiftAt: nextGiftAt,
        monthlyDiamonds: monthlyDiamonds,
        onCancelPro: onCancelPro,
      ),
    );
  }

  @override
  State<AccountModal> createState() => _AccountModalState();
}

class _AccountModalState extends State<AccountModal> {
  bool _confirming = false; // Segundo paso: "¿Seguro?"

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final nextGift = widget.nextGiftAt;

    return GameModal(
      title: _confirming ? '¿Cancelar PRO?' : 'Tu cuenta PRO',
      color: AppColors.teal,
      titleColor: Colors.white,
      topRight: GameModal.closeButton(context),
      // Textos cortos: así los botones tienen letra del mismo tamaño
      actions: _confirming
          ? [
              Button(
                label: 'No',
                onPress: () => setState(() => _confirming = false),
                backgroundColor: AppColors.green,
                textColor: AppColors.ink,
              ),
              Button(
                label: 'Sí',
                onPress: () {
                  Navigator.pop(context);
                  widget.onCancelPro();
                },
                backgroundColor: AppColors.pink,
              ),
            ]
          : [
              Button(
                label: 'Volver',
                onPress: () => Navigator.pop(context),
                backgroundColor: AppColors.cream,
                textColor: AppColors.ink,
              ),
            ],
      child: _confirming
          ? GameModal.infoBox(
              'Vas a volver a ver publicidad, revivir te va a costar 10 💎 '
              'y no vas a recibir más ${widget.monthlyDiamonds} 💎 por mes.\n'
              'Tus diamantes actuales se quedan.',
            )
          : Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.cream,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.ink, width: 2.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.workspace_premium_rounded, color: AppColors.accountPro, size: 34, shadows: [
                        Shadow(color: AppColors.ink, offset: Offset(1, 2)),
                      ]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          nextGift != null
                              ? 'Próximos ${widget.monthlyDiamonds} 💎: ${_formatDate(nextGift)}'
                              : 'Suscripción activa',
                          style: const TextStyle(color: AppColors.ink, fontWeight: FontWeight.w900, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  for (final benefit in [
                    'Sin publicidad',
                    'Revivir a 5 💎',
                    '${widget.monthlyDiamonds} 💎 por mes',
                  ])
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, color: AppColors.green, size: 20),
                          const SizedBox(width: 6),
                          Text(
                            benefit,
                            style: const TextStyle(color: AppColors.ink, fontWeight: FontWeight.w700, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 12),
                  // Cancelar como link discreto (acción destructiva, no botón principal)
                  Center(
                    child: GestureDetector(
                      onTap: () => setState(() => _confirming = true),
                      child: const Text(
                        'Cancelar suscripción',
                        style: TextStyle(
                          color: AppColors.inkMuted,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.inkMuted,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
