import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/player_state.dart';
import '../atoms/badge.dart';
import '../atoms/button.dart';
import '../../game/components/player_component.dart';
import '../../game/game_icons.dart';
import '../molecules/counter_item.dart';

class Header extends StatelessWidget {
  final PlayerState estadoJugador;
  final VoidCallback alCambiarTema;
  final VoidCallback alAbrirTienda;
  final VoidCallback alTocarCuenta;

  const Header({
    super.key,
    required this.estadoJugador,
    required this.alCambiarTema,
    required this.alAbrirTienda,
    required this.alTocarCuenta,
  });

  @override
  Widget build(BuildContext context) {
    final esPro = estadoJugador.esPro;
    final colores = Theme.of(context).colorScheme;

    return SafeArea(
      bottom: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: colores.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.tinta, width: 3),
          boxShadow: const [
            BoxShadow(color: AppColors.tinta, offset: Offset(0, 5), blurRadius: 0),
          ],
        ),
        child: Column(
          children: [
            // Fila Jugador + Tipo de cuenta + Tema
            Row(
              children: [
                // Avatar: el mismo dibujo que el cubo del juego (PlayerComponent)
                const CustomPaint(size: Size.square(46), painter: _AvatarPainter()),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        estadoJugador.nombreUsuario,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          color: colores.onSurface,
                        ),
                      ),
                      const SizedBox(height: 3),
                      // Wrap: si no entran en una línea, el récord baja a la siguiente
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          // Tocar la cuenta: PRO ve su suscripción, BASIC va a la tienda
                          Semantics(
                            button: true,
                            label: 'Cuenta',
                            child: GestureDetector(
                              onTap: alTocarCuenta,
                              child: CustomBadge(
                                etiqueta: esPro ? 'PRO' : 'BASIC',
                                colorFondo: esPro ? AppColors.cuentaPro : AppColors.cuentaBasic,
                                icono: esPro ? Icons.workspace_premium : null,
                              ),
                            ),
                          ),
                          CustomBadge(
                            etiqueta: 'RÉCORD ${estadoJugador.record}',
                            colorFondo: AppColors.amarillo,
                            icono: Icons.emoji_events_rounded,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Botón de tema claro/oscuro
                Button(
                  icono: estadoJugador.modoOscuro ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                  alPresionar: alCambiarTema,
                  colorFondo: AppColors.violeta,
                  colorTexto: AppColors.amarillo,
                  radio: 999,
                  descripcion: estadoJugador.modoOscuro ? 'Cambiar a modo claro' : 'Cambiar a modo oscuro',
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Contadores: puntos y diamantes
            Row(
              children: [
                Expanded(
                  child: CounterItem(
                    icono: GameIcon.estrella,
                    etiqueta: 'Puntos',
                    valor: '${estadoJugador.puntaje}',
                  ),
                ),
                const SizedBox(width: 10),
                // Toda la tarjeta abre la tienda (más lugar para números grandes)
                Expanded(
                  child: Semantics(
                    button: true,
                    hint: 'Abre la tienda',
                    child: GestureDetector(
                      onTap: alAbrirTienda,
                      child: CounterItem(
                        icono: GameIcon.diamante,
                        etiqueta: 'Diamantes',
                        valor: '${estadoJugador.diamantes}',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Pinta el avatar con el dibujo del personaje del juego: una sola definición del cubo
class _AvatarPainter extends CustomPainter {
  const _AvatarPainter();

  @override
  void paint(Canvas canvas, Size size) => PlayerComponent.dibujarCubo(canvas, size.width);

  @override
  bool shouldRepaint(_AvatarPainter oldDelegate) => false;
}
