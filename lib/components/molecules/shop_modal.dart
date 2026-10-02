import 'package:flutter/material.dart';
import '../../core/game_rules.dart';
import '../../core/theme.dart';
import '../atoms/badge.dart';
import '../atoms/button.dart';
import 'game_modal.dart';

// Paquete de diamantes a la venta
class _DiamondPack {
  final int amount;
  final String price;
  final String? tag; // Etiqueta destacada (ej: "POPULAR")
  final double iconSize;

  const _DiamondPack(this.amount, this.price, {this.tag, required this.iconSize});
}

class ShopModal extends StatelessWidget {
  final ValueChanged<int> onBuyDiamonds; // Recibe la cantidad comprada
  final VoidCallback onBuyPro;
  final bool isPro;
  final int diamonds;

  // Más diamantes = ícono más grande
  static const _packs = [
    _DiamondPack(50, '\$ 0,99', iconSize: 30),
    _DiamondPack(150, '\$ 2,49', tag: 'POPULAR', iconSize: 34),
    _DiamondPack(400, '\$ 4,99', iconSize: 38),
    _DiamondPack(1000, '\$ 9,99', tag: 'MEJOR PRECIO', iconSize: 44),
  ];

  const ShopModal({
    super.key,
    required this.onBuyDiamonds,
    required this.onBuyPro,
    required this.isPro,
    required this.diamonds,
  });

  // Devuelve un Future que se completa al cerrar la tienda
  static Future<void> show(
    BuildContext context, {
    required ValueChanged<int> onBuyDiamonds,
    required VoidCallback onBuyPro,
    required bool isPro,
    required int diamonds,
  }) {
    return GameModal.show(
      context,
      builder: (_) => ShopModal(
        onBuyDiamonds: onBuyDiamonds,
        onBuyPro: onBuyPro,
        isPro: isPro,
        diamonds: diamonds,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GameModal(
      title: 'Tienda',
      color: AppColors.orange,
      titleColor: AppColors.cream,
      topRight: Button(
        icon: Icons.close_rounded,
        onPress: () => Navigator.pop(context),
        backgroundColor: AppColors.pink,
        textColor: AppColors.ink,
        radius: 999,
        tooltip: 'Cerrar',
        size: 34,
      ),
      child: Column(
        children: [
          // Saldo actual
          Align(
            alignment: Alignment.centerLeft,
            child: CustomBadge(
              label: 'Tenés $diamonds diamantes',
              backgroundColor: AppColors.cream,
              icon: Icons.diamond_rounded,
              iconColor: AppColors.diamond,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),

          // Paquetes de diamantes en grilla de 2x2
          for (var row = 0; row < _packs.length; row += 2) ...[
            if (row > 0) const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildPack(context, _packs[row])),
                const SizedBox(width: 10),
                Expanded(child: _buildPack(context, _packs[row + 1])),
              ],
            ),
          ],
          const SizedBox(height: 14),

          _buildProCard(context),
          const SizedBox(height: 10),

          Text(
            'Compras simuladas: no se cobra dinero real',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.ink.withValues(alpha: 0.75), fontWeight: FontWeight.w700, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildPack(BuildContext context, _DiamondPack pack) {
    final tag = pack.tag;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(10, 14, 10, 10),
          decoration: BoxDecoration(
            color: AppColors.cream,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.ink, width: 2.5),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 46,
                child: Center(
                  child: Icon(Icons.diamond_rounded, color: AppColors.diamond, size: pack.iconSize, shadows: const [
                    Shadow(color: AppColors.ink, offset: Offset(1, 2)),
                  ]),
                ),
              ),
              Text(
                '${pack.amount}',
                style: const TextStyle(color: AppColors.ink, fontWeight: FontWeight.w900, fontSize: 24, height: 1.1),
              ),
              const Text(
                'diamantes',
                style: TextStyle(color: AppColors.inkMuted, fontWeight: FontWeight.w700, fontSize: 12),
              ),
              const SizedBox(height: 8),
              Button(
                label: pack.price,
                onPress: () {
                  onBuyDiamonds(pack.amount);
                  Navigator.pop(context);
                },
                backgroundColor: AppColors.green,
                textColor: AppColors.ink,
              ),
            ],
          ),
        ),
        // Etiqueta sobre el borde superior
        if (tag != null)
          Positioned(
            top: -10,
            child: CustomBadge(
              label: tag,
              backgroundColor: AppColors.pink,
              textColor: Colors.white,
              fontSize: 10,
            ),
          ),
      ],
    );
  }

  // Suscripción PRO: sin publicidad + diamantes de regalo
  Widget _buildProCard(BuildContext context) {
    return Semantics(
      button: true,
      enabled: !isPro,
      child: GestureDetector(
        onTap: isPro
            ? null
            : () {
                onBuyPro();
                Navigator.pop(context);
              },
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.teal,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.ink, width: 2.5),
          ),
          child: Row(
            children: [
              const Icon(Icons.workspace_premium_rounded, color: AppColors.accountPro, size: 38, shadows: [
                Shadow(color: AppColors.ink, offset: Offset(1, 2)),
              ]),
              const SizedBox(width: 8),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CUENTA PRO',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        shadows: [Shadow(color: AppColors.ink, offset: Offset(1, 1.5))],
                      ),
                    ),
                    Text(
                      'Sin publicidad · Revivir a ${GameRules.reviveCostPro} 💎 · ${GameRules.proMonthlyDiamonds} 💎 por mes',
                      style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w700, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Precio mensual, o "ACTIVO" si ya es PRO
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: isPro ? AppColors.green : AppColors.yellow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.ink, width: 2.5),
                ),
                child: isPro
                    ? const Text(
                        '✓ ACTIVO',
                        style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w900, fontSize: 13),
                      )
                    : const Column(
                        children: [
                          Text(
                            GameRules.proMonthlyPrice,
                            style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w900, fontSize: 14),
                          ),
                          Text(
                            '/MES',
                            style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w800, fontSize: 10),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
