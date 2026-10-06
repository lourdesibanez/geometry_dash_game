import 'package:flutter/material.dart';
import '../../core/theme.dart';

// Recuadro crema de los modales: texto explicativo centrado o contenido propio
class InfoBox extends StatelessWidget {
  final String? texto;
  final Widget? contenido;

  const InfoBox(String this.texto, {super.key}) : contenido = null;

  const InfoBox.personalizado({super.key, required Widget this.contenido}) : texto = null;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.crema,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.tinta, width: 2.5),
      ),
      child: contenido ??
          Text(
            texto!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.tinta, fontWeight: FontWeight.w700, fontSize: 14),
          ),
    );
  }
}
