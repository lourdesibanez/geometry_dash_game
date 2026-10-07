import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../atoms/button.dart';
import '../atoms/info_box.dart';

// Marco común de los modales (tienda, publicidad, revivir):
// tarjeta de color con contorno azul marino, título amarillo, contenido y botones.
class GameModal extends StatelessWidget {
  final String titulo;
  final Color color;
  final Color colorTitulo;
  final Widget? esquinaDerecha; // Ej: cuenta regresiva o botón de cerrar
  final Widget contenido;
  final List<Widget> acciones;  // Se reparten a lo ancho
  final Widget? pie;            // Debajo de los botones (ej: una opción secundaria)
  final bool cerrable;          // false: no se cierra con atrás ni tocando afuera

  const GameModal({
    super.key,
    required this.titulo,
    required this.color,
    required this.contenido,
    this.colorTitulo = AppColors.amarillo,
    this.esquinaDerecha,
    this.acciones = const [],
    this.pie,
    this.cerrable = true,
  });

  // Todos los modales aparecen en el centro con el mismo comportamiento
  static Future<T?> mostrar<T>(
    BuildContext context, {
    required WidgetBuilder constructor,
    bool cerrable = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: cerrable,
      barrierColor: AppColors.tinta.withValues(alpha: 0.45), // Oscurece el fondo
      builder: constructor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: cerrable,
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
            border: Border.all(color: AppColors.tinta, width: 3),
            boxShadow: const [BoxShadow(color: AppColors.tinta, offset: Offset(0, 6))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      titulo.toUpperCase(),
                      style: TextStyle(
                        color: colorTitulo,
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                        letterSpacing: 1,
                        shadows: const [Shadow(color: AppColors.tinta, offset: Offset(2, 2))],
                      ),
                    ),
                  ),
                  ?esquinaDerecha,
                ],
              ),
              const SizedBox(height: 12),
              // Flexible + scroll: si el contenido no entra en pantallas chicas, se desplaza
              Flexible(child: SingleChildScrollView(child: contenido)),
              if (acciones.isNotEmpty) ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    for (var i = 0; i < acciones.length; i++) ...[
                      if (i > 0) const SizedBox(width: 10),
                      Expanded(child: acciones[i]),
                    ],
                  ],
                ),
              ],
              if (pie != null) ...[
                const SizedBox(height: 12),
                pie!,
              ],
            ],
          ),
        ),
        ),
      ),
    );
  }

  // Pregunta de confirmación con NO / SÍ. Devuelve true solo si tocan SÍ
  static Future<bool> confirmar(
    BuildContext context, {
    required String titulo,
    required String mensaje,
    Color color = AppColors.naranja,
  }) async {
    final resultado = await mostrar<bool>(
      context,
      constructor: (contextoDialogo) => GameModal(
        titulo: titulo,
        color: color,
        colorTitulo: Colors.white,
        acciones: [
          Button(
            etiqueta: 'No',
            alPresionar: () => Navigator.pop(contextoDialogo, false),
            colorFondo: AppColors.crema,
            colorTexto: AppColors.tinta,
          ),
          Button(
            etiqueta: 'Sí',
            alPresionar: () => Navigator.pop(contextoDialogo, true),
            colorFondo: AppColors.rosa,
          ),
        ],
        contenido: InfoBox(mensaje),
      ),
    );
    return resultado ?? false; // Tocar afuera o "atrás" cuenta como NO
  }
}
