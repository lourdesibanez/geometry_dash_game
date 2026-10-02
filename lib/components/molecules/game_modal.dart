import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../atoms/button.dart';

// Marco común de los modales (tienda, publicidad, revivir):
// tarjeta de color con contorno azul marino, título amarillo, contenido y botones.
class GameModal extends StatelessWidget {
  final String title;
  final Color color;
  final Color titleColor;
  final Widget? topRight;      // Ej: cuenta regresiva o botón de cerrar
  final Widget child;
  final List<Widget> actions;  // Se reparten a lo ancho
  final bool canDismiss;       // false: no se cierra con atrás ni tocando afuera

  const GameModal({
    super.key,
    required this.title,
    required this.color,
    required this.child,
    this.titleColor = AppColors.yellow,
    this.topRight,
    this.actions = const [],
    this.canDismiss = true,
  });

  // Todos los modales aparecen en el centro con el mismo comportamiento
  static Future<T?> show<T>(
    BuildContext context, {
    required WidgetBuilder builder,
    bool canDismiss = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: canDismiss,
      barrierColor: AppColors.ink.withValues(alpha: 0.45), // Oscurece el fondo
      builder: builder,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: canDismiss,
      // Desenfoca todo lo que queda detrás del modal
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.ink, width: 3),
            boxShadow: const [BoxShadow(color: AppColors.ink, offset: Offset(0, 6))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title.toUpperCase(),
                      style: TextStyle(
                        color: titleColor,
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                        letterSpacing: 1,
                        shadows: const [Shadow(color: AppColors.ink, offset: Offset(2, 2))],
                      ),
                    ),
                  ),
                  ?topRight,
                ],
              ),
              const SizedBox(height: 12),
              // Flexible + scroll: si el contenido no entra en pantallas chicas, se desplaza
              Flexible(child: SingleChildScrollView(child: child)),
              if (actions.isNotEmpty) ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    for (var i = 0; i < actions.length; i++) ...[
                      if (i > 0) const SizedBox(width: 10),
                      Expanded(child: actions[i]),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
        ),
      ),
    );
  }

  // Pregunta de confirmación con NO / SÍ. Devuelve true solo si tocan SÍ
  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    required String message,
    Color color = AppColors.orange,
  }) async {
    final result = await show<bool>(
      context,
      builder: (dialogContext) => GameModal(
        title: title,
        color: color,
        titleColor: Colors.white,
        actions: [
          Button(
            label: 'No',
            onPress: () => Navigator.pop(dialogContext, false),
            backgroundColor: AppColors.cream,
            textColor: AppColors.ink,
          ),
          Button(
            label: 'Sí',
            onPress: () => Navigator.pop(dialogContext, true),
            backgroundColor: AppColors.pink,
          ),
        ],
        child: infoBox(message),
      ),
    );
    return result ?? false; // Tocar afuera o "atrás" cuenta como NO
  }

  // Botón circular "X" para el rincón superior derecho
  static Widget closeButton(BuildContext context, {Color color = AppColors.cream}) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.ink, width: 2.5),
        ),
        child: const Icon(Icons.close_rounded, color: AppColors.ink, size: 20),
      ),
    );
  }

  // Recuadro crema para textos explicativos
  static Widget infoBox(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.ink, width: 2.5),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.ink, fontWeight: FontWeight.w700, fontSize: 14),
      ),
    );
  }
}
