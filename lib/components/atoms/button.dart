import 'package:flutter/material.dart';
import '../../core/theme.dart';

// Botón redondeado con ícono y texto, contorno azul marino y sombra dura
class Button extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onPress;
  final Color backgroundColor;
  final Color textColor;

  const Button({
    super.key,
    required this.label,
    this.icon,
    required this.onPress,
    this.backgroundColor = AppColors.green,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.ink, width: 3),
          boxShadow: const [
            BoxShadow(color: AppColors.ink, offset: Offset(0, 4), blurRadius: 0),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: textColor, size: 24),
              const SizedBox(width: 6),
            ],
            // En pantallas angostas el texto se achica en vez de cortarse
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label.toUpperCase(),
                  maxLines: 1,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    letterSpacing: 1.0,
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
