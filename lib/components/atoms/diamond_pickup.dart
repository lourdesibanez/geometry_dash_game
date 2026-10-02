import 'package:flutter/material.dart';
import '../../core/theme.dart';

// Diamante que aparece en el juego para agarrar saltando (mismo ícono que el header y la tienda)
class DiamondPickup extends StatelessWidget {
  final double size;

  const DiamondPickup({super.key, this.size = 30});

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.diamond_rounded,
      color: AppColors.diamond,
      size: size,
      shadows: const [Shadow(color: AppColors.ink, offset: Offset(1.5, 2))],
    );
  }
}
