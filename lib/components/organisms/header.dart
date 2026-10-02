import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../atoms/badge.dart';
import '../molecules/counter_item.dart';
import '../../services/storage_service.dart';

class Header extends StatelessWidget {
  final PlayerState playerState;
  final VoidCallback onToggleTheme;

  const Header({
    super.key,
    required this.playerState,
    required this.onToggleTheme,
  });

  @override
  Widget build(BuildContext context) {
    final isPro = playerState.accountType == 'pro';

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black, width: 3.5),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(5, 5),
            blurRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Fila Jugador + Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.accentLight,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 2.5),
                      ),
                      child: const Icon(Icons.sports_esports, color: Colors.black, size: 22),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        playerState.username.toUpperCase(),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    CustomBadge(
                      label: isPro ? 'PRO' : 'BASIC',
                      backgroundColor: isPro ? AppColors.accountPro : AppColors.accountBasic,
                    ),
                  ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    playerState.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  onPressed: onToggleTheme,
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Fila de Contadores Gamificados
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                CounterItem(
                  icon: Icons.emoji_events, // Trofeo
                  value: '${playerState.score} PTS',
                  badgeColor: AppColors.accentLight,
                ),
                CounterItem(
                  icon: Icons.diamond_outlined, // Gemas Arcade
                  value: '${playerState.diamonds}',
                  badgeColor: AppColors.cyanGamer,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}