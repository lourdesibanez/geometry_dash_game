// lib/components/molecules/counter_item.dart
import 'package:flutter/material.dart';
import '../../core/theme.dart';

// Tarjeta de estadística: ícono + etiqueta chica + valor grande (+ acción opcional)
class CounterItem extends StatelessWidget {
  final IconData icono;
  final String etiqueta;
  final String valor;
  final Color colorIcono;
  final Widget? extra;

  const CounterItem({
    super.key,
    required this.icono,
    required this.etiqueta,
    required this.valor,
    required this.colorIcono,
    this.extra,
  });

  @override
  Widget build(BuildContext context) {
    final esOscuro = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: esOscuro ? AppColors.noche : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.tinta, width: 2.5),
      ),
      child: Row(
        children: [
          Icon(icono, color: colorIcono, size: 26, shadows: const [
            Shadow(color: AppColors.tinta, offset: Offset(1, 1.5)),
          ]),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  etiqueta.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: esOscuro ? AppColors.lila.withValues(alpha: 0.7) : AppColors.tintaSuave,
                  ),
                ),
                Text(
                  valor,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 20,
                    height: 1.1,
                    fontWeight: FontWeight.w900,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          ?extra,
        ],
      ),
    );
  }
}
