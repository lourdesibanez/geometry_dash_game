import 'package:flutter/material.dart';
import '../../core/theme.dart';

// Recuadro crema de los modales: texto explicativo centrado o contenido propio
class InfoBox extends StatelessWidget {
  final String? text;
  final Widget? child;

  const InfoBox(String this.text, {super.key}) : child = null;

  const InfoBox.custom({super.key, required Widget this.child}) : text = null;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.ink, width: 2.5),
      ),
      child: child ??
          Text(
            text!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.ink, fontWeight: FontWeight.w700, fontSize: 14),
          ),
    );
  }
}
