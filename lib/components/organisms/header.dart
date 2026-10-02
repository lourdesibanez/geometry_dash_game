import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/player_state.dart';
import '../atoms/badge.dart';
import '../atoms/button.dart';
import '../atoms/player.dart';
import '../molecules/counter_item.dart';

class Header extends StatelessWidget {
  final PlayerState playerState;
  final VoidCallback onToggleTheme;
  final VoidCallback onOpenShop;
  final VoidCallback onAccountTap;

  const Header({
    super.key,
    required this.playerState,
    required this.onToggleTheme,
    required this.onOpenShop,
    required this.onAccountTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPro = playerState.isPro;
    final colors = Theme.of(context).colorScheme;

    return SafeArea(
      bottom: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.ink, width: 3),
          boxShadow: const [
            BoxShadow(color: AppColors.ink, offset: Offset(0, 5), blurRadius: 0),
          ],
        ),
        child: Column(
          children: [
            // Fila Jugador + Tipo de cuenta + Tema
            Row(
              children: [
                // Avatar: el mismo cubo del juego
                const Player(size: 46),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        playerState.username,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          color: colors.onSurface,
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
                              onTap: onAccountTap,
                              child: CustomBadge(
                                label: isPro ? 'PRO' : 'BASIC',
                                backgroundColor: isPro ? AppColors.accountPro : AppColors.accountBasic,
                                icon: isPro ? Icons.workspace_premium : null,
                              ),
                            ),
                          ),
                          CustomBadge(
                            label: 'RÉCORD ${playerState.highScore}',
                            backgroundColor: AppColors.yellow,
                            icon: Icons.emoji_events_rounded,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Botón de tema claro/oscuro
                Button(
                  icon: playerState.isDarkMode ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                  onPress: onToggleTheme,
                  backgroundColor: AppColors.purple,
                  textColor: AppColors.yellow,
                  radius: 999,
                  tooltip: playerState.isDarkMode ? 'Cambiar a modo claro' : 'Cambiar a modo oscuro',
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Contadores: puntos y diamantes
            Row(
              children: [
                Expanded(
                  child: CounterItem(
                    icon: Icons.star_rounded,
                    label: 'Puntos',
                    value: '${playerState.score}',
                    badgeColor: AppColors.yellow,
                  ),
                ),
                const SizedBox(width: 10),
                // Toda la tarjeta abre la tienda (más lugar para números grandes)
                Expanded(
                  child: Semantics(
                    button: true,
                    hint: 'Abre la tienda',
                    child: GestureDetector(
                      onTap: onOpenShop,
                      child: CounterItem(
                        icon: Icons.diamond_rounded,
                        label: 'Diamantes',
                        value: '${playerState.diamonds}',
                        badgeColor: AppColors.diamond,
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
