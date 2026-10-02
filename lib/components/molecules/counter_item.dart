// lib/components/molecules/counter_item.dart
import 'package:flutter/material.dart';
import '../../core/theme.dart';

// Tarjeta de estadística: ícono + etiqueta chica + valor grande (+ acción opcional)
class CounterItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color badgeColor; // Color del ícono
  final Widget? trailing;

  const CounterItem({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.badgeColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.night : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.ink, width: 2.5),
      ),
      child: Row(
        children: [
          Icon(icon, color: badgeColor, size: 26, shadows: const [
            Shadow(color: AppColors.ink, offset: Offset(1, 1.5)),
          ]),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: isDark ? AppColors.lilac.withValues(alpha: 0.7) : AppColors.inkMuted,
                  ),
                ),
                Text(
                  value,
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
          ?trailing,
        ],
      ),
    );
  }
}
