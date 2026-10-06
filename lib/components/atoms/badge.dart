import 'package:flutter/material.dart';
import '../../core/theme.dart';

// Píldora con contorno (ej: "CUENTA BASIC", saldo, cuenta regresiva, "POPULAR")
class CustomBadge extends StatelessWidget {
  final String etiqueta;
  final Color colorFondo;
  final Color colorTexto;
  final IconData? icono;
  final Color? colorIcono; // Por defecto, el mismo color del texto
  final double tamanoLetra;

  const CustomBadge({
    super.key,
    required this.etiqueta,
    required this.colorFondo,
    this.colorTexto = AppColors.tinta,
    this.icono,
    this.colorIcono,
    this.tamanoLetra = 11,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.0),
      decoration: BoxDecoration(
        color: colorFondo,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: AppColors.tinta, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icono != null) ...[
            Icon(icono, size: tamanoLetra + 2, color: colorIcono ?? colorTexto),
            const SizedBox(width: 4.0),
          ],
          Text(
            etiqueta,
            style: TextStyle(
              color: colorTexto,
              fontSize: tamanoLetra,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}
