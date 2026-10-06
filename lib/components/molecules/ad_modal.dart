import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../atoms/badge.dart';
import '../atoms/button.dart';
import '../atoms/info_box.dart';
import 'game_modal.dart';

// Publicidad simulada: se puede cerrar recién cuando termina la cuenta regresiva
class AdModal extends StatefulWidget {
  final VoidCallback alCerrar;
  final VoidCallback? alQuitarAnuncios; // "Cambiar a PRO": lleva a la tienda para pasarse a PRO

  const AdModal({super.key, required this.alCerrar, this.alQuitarAnuncios});

  static void mostrar(BuildContext context, VoidCallback alCerrar, {VoidCallback? alQuitarAnuncios}) {
    GameModal.mostrar(
      context,
      cerrable: false,
      constructor: (_) => AdModal(alCerrar: alCerrar, alQuitarAnuncios: alQuitarAnuncios),
    );
  }

  @override
  State<AdModal> createState() => _AdModalState();
}

class _AdModalState extends State<AdModal> {
  static const int _segundosAnuncio = 5;
  int _restantes = _segundosAnuncio;
  Timer? _temporizador;

  bool get _puedeCerrar => _restantes == 0;

  @override
  void initState() {
    super.initState();
    _temporizador = Timer.periodic(const Duration(seconds: 1), (temporizador) {
      if (_restantes <= 1) temporizador.cancel();
      setState(() => _restantes--);
    });
  }

  @override
  void dispose() {
    _temporizador?.cancel();
    super.dispose();
  }

  void _cerrar() {
    if (!_puedeCerrar) return;
    Navigator.pop(context);
    widget.alCerrar();
  }

  void _quitarAnuncios() {
    Navigator.pop(context);
    widget.alQuitarAnuncios?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GameModal(
      titulo: 'Publicidad',
      color: AppColors.rosa,
      cerrable: false, // El botón atrás no saltea el anuncio
      esquinaDerecha: CustomBadge(
        etiqueta: '0:${_restantes.toString().padLeft(2, '0')}',
        colorFondo: AppColors.crema,
        tamanoLetra: 13,
      ),
      acciones: [
        Button(
          etiqueta: 'PRO',
          icono: Icons.workspace_premium_rounded,
          alPresionar: _quitarAnuncios,
          colorFondo: AppColors.turquesa,
        ),
        // Se habilita cuando termina la cuenta regresiva (el tiempo se ve arriba a la derecha).
        // Texto fijo y corto: así no cambia de tamaño al habilitarse
        Opacity(
          opacity: _puedeCerrar ? 1.0 : 0.5,
          child: Button(
            etiqueta: 'Cerrar',
            icono: Icons.close_rounded,
            alPresionar: _cerrar,
            colorFondo: AppColors.naranja,
          ),
        ),
      ],
      contenido: Column(
        children: [
          _construirVideoAnuncio(),
          const SizedBox(height: 12),
          const InfoBox('Después del anuncio arranca tu partida.\n¿Sin anuncios? ¡Pasate a PRO!'),
        ],
      ),
    );
  }

  // "Video" del anuncio
  Widget _construirVideoAnuncio() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.violeta,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.tinta, width: 3),
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
                  color: AppColors.amarillo,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.tinta, width: 3),
                ),
              ),
            ),
            // Estrellitas
            for (final estrella in const [Offset(28, 38), Offset(70, 20), Offset(40, 120), Offset(220, 130)])
              Positioned(
                left: estrella.dx,
                top: estrella.dy,
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
                    shadows: [Shadow(color: AppColors.tinta, offset: Offset(2, 3))],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'CHOCO COHETE',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 26,
                      letterSpacing: 1,
                      shadows: [Shadow(color: AppColors.tinta, offset: Offset(2, 3))],
                    ),
                  ),
                  Text(
                    '¡El cereal que despega tu mañana!',
                    style: TextStyle(color: AppColors.amarillo, fontWeight: FontWeight.w800, fontSize: 13),
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
                  color: AppColors.tinta.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.tinta, width: 2),
                ),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(seconds: _segundosAnuncio),
                  builder: (context, valor, _) => FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: valor,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.amarillo,
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
