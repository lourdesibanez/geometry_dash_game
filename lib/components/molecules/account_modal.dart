import 'package:flutter/material.dart';
import '../../core/game_rules.dart';
import '../../core/theme.dart';
import '../atoms/button.dart';
import '../atoms/info_box.dart';
import 'game_modal.dart';

// Detalle de la suscripción PRO, con opción de cancelarla (pide confirmación)
class AccountModal extends StatefulWidget {
  final DateTime? proximoRegalo;
  final VoidCallback alCancelarPro;

  const AccountModal({
    super.key,
    required this.proximoRegalo,
    required this.alCancelarPro,
  });

  static Future<void> mostrar(
    BuildContext context, {
    required DateTime? proximoRegalo,
    required VoidCallback alCancelarPro,
  }) {
    return GameModal.mostrar(
      context,
      constructor: (_) => AccountModal(
        proximoRegalo: proximoRegalo,
        alCancelarPro: alCancelarPro,
      ),
    );
  }

  @override
  State<AccountModal> createState() => _AccountModalState();
}

class _AccountModalState extends State<AccountModal> {
  bool _confirmando = false; // Segundo paso: "¿Seguro?"

  String _formatearFecha(DateTime fecha) =>
      '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final proximoRegalo = widget.proximoRegalo;

    return GameModal(
      titulo: _confirmando ? '¿Cancelar PRO?' : 'Tu cuenta PRO',
      color: AppColors.turquesa,
      colorTitulo: Colors.white,
      esquinaDerecha: Button(
        icono: Icons.close_rounded,
        alPresionar: () => Navigator.pop(context),
        colorFondo: AppColors.crema,
        colorTexto: AppColors.tinta,
        radio: 999,
        descripcion: 'Cerrar',
        tamano: 34,
      ),
      // Textos cortos: así los botones tienen letra del mismo tamaño
      acciones: _confirmando
          ? [
              Button(
                etiqueta: 'No',
                alPresionar: () => setState(() => _confirmando = false),
                colorFondo: AppColors.verde,
                colorTexto: AppColors.tinta,
              ),
              Button(
                etiqueta: 'Sí',
                alPresionar: () {
                  Navigator.pop(context);
                  widget.alCancelarPro();
                },
                colorFondo: AppColors.rosa,
              ),
            ]
          : [
              Button(
                etiqueta: 'Volver',
                alPresionar: () => Navigator.pop(context),
                colorFondo: AppColors.crema,
                colorTexto: AppColors.tinta,
              ),
            ],
      contenido: _confirmando
          ? InfoBox(
              'Vas a volver a ver publicidad, revivir te va a costar ${GameRules.costoRevivirBasic} 💎 '
              'y no vas a recibir más ${GameRules.diamantesMensualesPro} 💎 por mes.\n'
              'Tus diamantes actuales se quedan.',
            )
          : InfoBox.personalizado(
              contenido: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.workspace_premium_rounded, color: AppColors.cuentaPro, size: 34, shadows: [
                        Shadow(color: AppColors.tinta, offset: Offset(1, 2)),
                      ]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          proximoRegalo != null
                              ? 'Próximos ${GameRules.diamantesMensualesPro} 💎: ${_formatearFecha(proximoRegalo)}'
                              : 'Suscripción activa',
                          style: const TextStyle(color: AppColors.tinta, fontWeight: FontWeight.w900, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  for (final beneficio in [
                    'Sin publicidad',
                    'Revivir a ${GameRules.costoRevivirPro} 💎',
                    '${GameRules.diamantesMensualesPro} 💎 por mes',
                  ])
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, color: AppColors.verde, size: 20),
                          const SizedBox(width: 6),
                          Text(
                            beneficio,
                            style: const TextStyle(color: AppColors.tinta, fontWeight: FontWeight.w700, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 12),
                  // Cancelar como link discreto (acción destructiva, no botón principal)
                  Center(
                    child: Semantics(
                      button: true,
                      child: GestureDetector(
                        onTap: () => setState(() => _confirmando = true),
                        child: const Text(
                          'Cancelar suscripción',
                          style: TextStyle(
                            color: AppColors.tintaSuave,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.tintaSuave,
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
