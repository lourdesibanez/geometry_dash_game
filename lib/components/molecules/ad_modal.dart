import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../atoms/button.dart';
import 'game_modal.dart';

// Publicidad simulada: se puede cerrar recién cuando termina la cuenta regresiva
class AdModal extends StatefulWidget {
  final VoidCallback onClose;
  final VoidCallback? onRemoveAds; // "Cambiar a PRO": lleva a la tienda para pasarse a PRO

  const AdModal({super.key, required this.onClose, this.onRemoveAds});

  static void show(BuildContext context, VoidCallback onClose, {VoidCallback? onRemoveAds}) {
    GameModal.show(
      context,
      canDismiss: false,
      builder: (_) => AdModal(onClose: onClose, onRemoveAds: onRemoveAds),
    );
  }

  @override
  State<AdModal> createState() => _AdModalState();
}

class _AdModalState extends State<AdModal> {
  static const int _adSeconds = 5;
  int _remaining = _adSeconds;
  Timer? _timer;

  bool get _canClose => _remaining == 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remaining <= 1) timer.cancel();
      setState(() => _remaining--);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _close() {
    if (!_canClose) return;
    Navigator.pop(context);
    widget.onClose();
  }

  void _removeAds() {
    Navigator.pop(context);
    widget.onRemoveAds?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GameModal(
      title: 'Publicidad',
      color: AppColors.pink,
      canDismiss: false, // El botón atrás no saltea el anuncio
      topRight: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.cream,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.ink, width: 2.5),
        ),
        child: Text(
          '0:${_remaining.toString().padLeft(2, '0')}',
          style: const TextStyle(color: AppColors.ink, fontWeight: FontWeight.w900, fontSize: 13),
        ),
      ),
      actions: [
        Button(
          label: 'PRO',
          icon: Icons.workspace_premium_rounded,
          onPress: _removeAds,
          backgroundColor: AppColors.teal,
        ),
        // Se habilita cuando termina la cuenta regresiva (el tiempo se ve arriba a la derecha).
        // Texto fijo y corto: así no cambia de tamaño al habilitarse
        Opacity(
          opacity: _canClose ? 1.0 : 0.5,
          child: Button(
            label: 'Cerrar',
            icon: Icons.close_rounded,
            onPress: _close,
            backgroundColor: AppColors.orange,
          ),
        ),
      ],
      child: Column(
        children: [
          _buildAdVideo(),
          const SizedBox(height: 12),
          GameModal.infoBox('Después del anuncio arranca tu partida.\n¿Sin anuncios? ¡Pasate a PRO!'),
        ],
      ),
    );
  }

  // "Video" del anuncio
  Widget _buildAdVideo() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.purple,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.ink, width: 3),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          children: [
            // Planeta amarillo
            Positioned(
              top: -45,
              right: -45,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: AppColors.yellow,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.ink, width: 3),
                ),
              ),
            ),
            // Estrellitas
            for (final star in const [Offset(28, 38), Offset(70, 20), Offset(40, 120), Offset(220, 130)])
              Positioned(
                left: star.dx,
                top: star.dy,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                ),
              ),
            // Producto
            const Positioned.fill(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.rocket_launch_rounded,
                    color: Colors.white,
                    size: 54,
                    shadows: [Shadow(color: AppColors.ink, offset: Offset(2, 3))],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'CHOCO COHETE',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 26,
                      letterSpacing: 1,
                      shadows: [Shadow(color: AppColors.ink, offset: Offset(2, 3))],
                    ),
                  ),
                  Text(
                    '¡El cereal que despega tu mañana!',
                    style: TextStyle(color: AppColors.yellow, fontWeight: FontWeight.w800, fontSize: 13),
                  ),
                ],
              ),
            ),
            // Barra de progreso del anuncio
            Positioned(
              left: 14,
              right: 14,
              bottom: 14,
              child: Container(
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.ink.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.ink, width: 2),
                ),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(seconds: _adSeconds),
                  builder: (context, value, _) => FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: value,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.yellow,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
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
