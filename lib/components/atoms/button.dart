import 'package:flutter/material.dart';
import '../../core/theme.dart';

// Botón único de la app: contorno azul marino y sombra dura.
// Con texto se estira a lo ancho; sin texto es un botón cuadrado de solo ícono.
class Button extends StatelessWidget {
  final String? etiqueta;
  final IconData? icono;
  final VoidCallback alPresionar;
  final Color colorFondo;
  final Color colorTexto;
  final double radio; // 999 = circular
  final double tamano; // Lado del botón cuando es solo ícono
  final String? descripcion; // Para lectores de pantalla (obligatoria si es solo ícono)

  const Button({
    super.key,
    this.etiqueta,
    this.icono,
    required this.alPresionar,
    this.colorFondo = AppColors.verde,
    this.colorTexto = Colors.white,
    this.radio = 16,
    this.tamano = 42,
    this.descripcion,
  })  : assert(etiqueta != null || icono != null, 'El botón necesita texto o ícono'),
        assert(etiqueta != null || descripcion != null, 'Un botón de solo ícono necesita descripción');

  @override
  Widget build(BuildContext context) {
    final texto = etiqueta;
    final soloIcono = texto == null;

    final boton = Semantics(
      button: true,
      child: GestureDetector(
        onTap: alPresionar,
        child: Container(
          width: soloIcono ? tamano : null,
          height: soloIcono ? tamano : null,
          padding: soloIcono ? null : const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            color: colorFondo,
            borderRadius: BorderRadius.circular(radio),
            border: Border.all(color: AppColors.tinta, width: 3),
            boxShadow: const [
              BoxShadow(color: AppColors.tinta, offset: Offset(0, 4), blurRadius: 0),
            ],
          ),
          child: soloIcono
              ? Icon(icono, color: colorTexto, size: tamano * 0.55)
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icono != null) ...[
                      Icon(icono, color: colorTexto, size: 24),
                      const SizedBox(width: 6),
                    ],
                    // En pantallas angostas el texto se achica en vez de cortarse
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          texto.toUpperCase(),
                          maxLines: 1,
                          style: TextStyle(
                            color: colorTexto,
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
    final mensaje = descripcion;
    return mensaje != null ? Tooltip(message: mensaje, child: boton) : boton;
  }
}
