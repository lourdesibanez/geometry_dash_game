import 'package:flutter/material.dart';

class ShopModal extends StatelessWidget {
  final Function(int count) onBuyDiamonds;
  final VoidCallback onBuyPro;
  final bool isPro;

  const ShopModal({
    super.key,
    required this.onBuyDiamonds,
    required this.onBuyPro,
    required this.isPro,
  });

  // Devuelve un Future que se completa al cerrar la tienda
  static Future<void> show(
    BuildContext context, {
    required Function(int) onBuyDiamonds,
    required VoidCallback onBuyPro,
    required bool isPro,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ShopModal(onBuyDiamonds: onBuyDiamonds, onBuyPro: onBuyPro, isPro: isPro),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: const Border(top: BorderSide(color: Colors.black, width: 4)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 6,
            decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(10)),
          ),
          const SizedBox(height: 16),
          const Text('TIENDA DE DIAMANTES', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 20),
          _buildItem(context, 'BOLSA DE DIAMANTES', '+50 Gems', '\$0.99', () {
            onBuyDiamonds(50);
            Navigator.pop(context);
          }),
          const SizedBox(height: 12),
          _buildItem(context, 'COFRE GAMER', '+200 Gems', '\$2.99', () {
            onBuyDiamonds(200);
            Navigator.pop(context);
          }),
          const SizedBox(height: 12),
          // Compra permanente: cuenta PRO (sin publicidad)
          _buildItem(
            context,
            'CUENTA PRO',
            'Sin publicidad',
            isPro ? 'ACTIVO' : '\$4.99',
            isPro
                ? null
                : () {
                    onBuyPro();
                    Navigator.pop(context);
                  },
            icon: Icons.workspace_premium,
            iconColor: const Color(0xFFFFD700),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildItem(
    BuildContext context,
    String title,
    String amount,
    String price,
    VoidCallback? onTap, {
    IconData icon = Icons.diamond_outlined,
    Color iconColor = const Color(0xFF00E5FF),
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black, width: 3),
        boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(3, 3))],
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 30),
          const SizedBox(width: 10),
          // Expanded: el texto usa solo el espacio que deja el botón
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  amount,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.green),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFEA00)),
            child: Text(price, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class AdModal extends StatelessWidget {
  final VoidCallback onClose;

  const AdModal({super.key, required this.onClose});

  static void show(BuildContext context, VoidCallback onClose) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AdModal(onClose: onClose),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFFFFEA00),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colors.black, width: 4),
      ),
      title: const Text('PUBLICIDAD RECOMPENSADA', style: TextStyle(fontWeight: FontWeight.w900)),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.live_tv, size: 60, color: Colors.black),
          SizedBox(height: 12),
          Text('¡Mira este anuncio para reiniciar la partida!', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('Pasate a PRO en la tienda y no veas más anuncios', textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onClose();
          },
          child: const Text('CERRAR ANUNCIO', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}