import 'package:flutter/material.dart';
import '../../core/theme.dart';

// Botón único de la app: contorno azul marino y sombra dura.
// Con texto se estira a lo ancho; sin texto es un botón cuadrado de solo ícono.
class Button extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final VoidCallback onPress;
  final Color backgroundColor;
  final Color textColor;
  final double radius; // 999 = circular
  final double size; // Lado del botón cuando es solo ícono
  final String? tooltip; // Descripción para lectores de pantalla (obligatoria si es solo ícono)

  const Button({
    super.key,
    this.label,
    this.icon,
    required this.onPress,
    this.backgroundColor = AppColors.green,
    this.textColor = Colors.white,
    this.radius = 16,
    this.size = 42,
    this.tooltip,
  })  : assert(label != null || icon != null, 'El botón necesita texto o ícono'),
        assert(label != null || tooltip != null, 'Un botón de solo ícono necesita tooltip');

  @override
  Widget build(BuildContext context) {
    final text = label;
    final iconOnly = text == null;

    final button = Semantics(
      button: true,
      child: GestureDetector(
        onTap: onPress,
        child: Container(
          width: iconOnly ? size : null,
          height: iconOnly ? size : null,
          padding: iconOnly ? null : const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: AppColors.ink, width: 3),
            boxShadow: const [
              BoxShadow(color: AppColors.ink, offset: Offset(0, 4), blurRadius: 0),
            ],
          ),
          child: iconOnly
              ? Icon(icon, color: textColor, size: size * 0.55)
              : Row(
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
                          text.toUpperCase(),
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
      ),
    );

    // El Tooltip aparece al mantener presionado y le da nombre al botón para TalkBack/VoiceOver
    final message = tooltip;
    return message != null ? Tooltip(message: message, child: button) : button;
  }
}
