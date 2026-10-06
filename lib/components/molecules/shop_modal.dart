import 'package:flutter/material.dart';
import '../../core/game_rules.dart';
import '../../core/theme.dart';
import '../atoms/badge.dart';
import '../atoms/button.dart';
import 'game_modal.dart';

// Paquete de diamantes a la venta
class _DiamondPack {
  final int cantidad;
  final String precio;
  final String? etiqueta; // Etiqueta destacada (ej: "POPULAR")
  final double tamanoIcono;

  const _DiamondPack(this.cantidad, this.precio, {this.etiqueta, required this.tamanoIcono});
}

class ShopModal extends StatelessWidget {
  final ValueChanged<int> alComprarDiamantes; // Recibe la cantidad comprada
  final VoidCallback alComprarPro;
  final bool esPro;
  final int diamantes;

  // Más diamantes = ícono más grande
  static const _paquetes = [
    _DiamondPack(50, '\$ 0,99', tamanoIcono: 30),
    _DiamondPack(150, '\$ 2,49', etiqueta: 'POPULAR', tamanoIcono: 34),
    _DiamondPack(400, '\$ 4,99', tamanoIcono: 38),
    _DiamondPack(1000, '\$ 9,99', etiqueta: 'MEJOR PRECIO', tamanoIcono: 44),
  ];

  const ShopModal({
    super.key,
    required this.alComprarDiamantes,
    required this.alComprarPro,
    required this.esPro,
    required this.diamantes,
  });

  // Devuelve un Future que se completa al cerrar la tienda
  static Future<void> mostrar(
    BuildContext context, {
    required ValueChanged<int> alComprarDiamantes,
    required VoidCallback alComprarPro,
    required bool esPro,
    required int diamantes,
  }) {
    return GameModal.mostrar(
      context,
      constructor: (_) => ShopModal(
        alComprarDiamantes: alComprarDiamantes,
        alComprarPro: alComprarPro,
        esPro: esPro,
        diamantes: diamantes,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GameModal(
      titulo: 'Tienda',
      color: AppColors.naranja,
      colorTitulo: AppColors.crema,
      esquinaDerecha: Button(
        icono: Icons.close_rounded,
        alPresionar: () => Navigator.pop(context),
        colorFondo: AppColors.rosa,
        colorTexto: AppColors.tinta,
        radio: 999,
        descripcion: 'Cerrar',
        tamano: 34,
      ),
      contenido: Column(
        children: [
          // Saldo actual
          Align(
            alignment: Alignment.centerLeft,
            child: CustomBadge(
              etiqueta: 'Tenés $diamantes diamantes',
              colorFondo: AppColors.crema,
              icono: Icons.diamond_rounded,
              colorIcono: AppColors.diamante,
              tamanoLetra: 13,
            ),
          ),
          const SizedBox(height: 16),

          // Paquetes de diamantes en grilla de 2x2
          for (var fila = 0; fila < _paquetes.length; fila += 2) ...[
            if (fila > 0) const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _construirPaquete(context, _paquetes[fila])),
                const SizedBox(width: 10),
                Expanded(child: _construirPaquete(context, _paquetes[fila + 1])),
              ],
            ),
          ],
          const SizedBox(height: 14),

          _construirTarjetaPro(context),
          const SizedBox(height: 10),

          Text(
            'Compras simuladas: no se cobra dinero real',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.tinta.withValues(alpha: 0.75), fontWeight: FontWeight.w700, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _construirPaquete(BuildContext context, _DiamondPack paquete) {
    final etiqueta = paquete.etiqueta;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(10, 14, 10, 10),
          decoration: BoxDecoration(
            color: AppColors.crema,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.tinta, width: 2.5),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 46,
                child: Center(
                  child: Icon(Icons.diamond_rounded, color: AppColors.diamante, size: paquete.tamanoIcono, shadows: const [
                    Shadow(color: AppColors.tinta, offset: Offset(1, 2)),
                  ]),
                ),
              ),
              Text(
                '${paquete.cantidad}',
                style: const TextStyle(color: AppColors.tinta, fontWeight: FontWeight.w900, fontSize: 24, height: 1.1),
              ),
              const Text(
                'diamantes',
                style: TextStyle(color: AppColors.tintaSuave, fontWeight: FontWeight.w700, fontSize: 12),
              ),
              const SizedBox(height: 8),
              Button(
                etiqueta: paquete.precio,
                alPresionar: () {
                  alComprarDiamantes(paquete.cantidad);
                  Navigator.pop(context);
                },
                colorFondo: AppColors.verde,
                colorTexto: AppColors.tinta,
              ),
            ],
          ),
        ),
        // Etiqueta sobre el borde superior
        if (etiqueta != null)
          Positioned(
            top: -10,
            child: CustomBadge(
              etiqueta: etiqueta,
              colorFondo: AppColors.rosa,
              colorTexto: Colors.white,
              tamanoLetra: 10,
            ),
          ),
      ],
    );
  }

  // Suscripción PRO: sin publicidad + diamantes de regalo
  Widget _construirTarjetaPro(BuildContext context) {
    return Semantics(
      button: true,
      enabled: !esPro,
      child: GestureDetector(
        onTap: esPro
            ? null
            : () {
                alComprarPro();
                Navigator.pop(context);
              },
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.turquesa,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.tinta, width: 2.5),
          ),
          child: Row(
            children: [
              const Icon(Icons.workspace_premium_rounded, color: AppColors.cuentaPro, size: 38, shadows: [
                Shadow(color: AppColors.tinta, offset: Offset(1, 2)),
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
                        shadows: [Shadow(color: AppColors.tinta, offset: Offset(1, 1.5))],
                      ),
                    ),
                    Text(
                      'Sin publicidad · Revivir a ${GameRules.costoRevivirPro} 💎 · ${GameRules.diamantesMensualesPro} 💎 por mes',
                      style: TextStyle(color: AppColors.tinta, fontWeight: FontWeight.w700, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Precio mensual, o "ACTIVO" si ya es PRO
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: esPro ? AppColors.verde : AppColors.amarillo,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.tinta, width: 2.5),
                ),
                child: esPro
                    ? const Text(
                        '✓ ACTIVO',
                        style: TextStyle(color: AppColors.tinta, fontWeight: FontWeight.w900, fontSize: 13),
                      )
                    : const Column(
                        children: [
                          Text(
                            GameRules.precioMensualPro,
                            style: TextStyle(color: AppColors.tinta, fontWeight: FontWeight.w900, fontSize: 14),
                          ),
                          Text(
                            '/MES',
                            style: TextStyle(color: AppColors.tinta, fontWeight: FontWeight.w800, fontSize: 10),
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
