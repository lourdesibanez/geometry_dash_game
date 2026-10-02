import 'package:flutter/material.dart';
import '../../core/theme.dart';

// Píldora con contorno (ej: "CUENTA BASIC", saldo, cuenta regresiva, "POPULAR")
class CustomBadge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;
  final Color? iconColor; // Por defecto, el mismo color del texto
  final double fontSize;

  const CustomBadge({
    super.key,
    required this.label,
    required this.backgroundColor,
    this.textColor = AppColors.ink,
    this.icon,
    this.iconColor,
    this.fontSize = 11,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: AppColors.ink, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize + 2, color: iconColor ?? textColor),
            const SizedBox(width: 4.0),
          ],
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}
