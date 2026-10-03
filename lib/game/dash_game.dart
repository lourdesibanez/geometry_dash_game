import 'dart:math' as math;
import 'dart:ui';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'components/diamond_component.dart';
import 'components/ground_component.dart';
import 'components/obstacle_component.dart';
import 'components/player_component.dart';
import 'components/sky_component.dart';
import 'game_config.dart';

// Juego hecho con Flame. La UI (botonera, header, modales) es Flutter y lo controla
// desde afuera con [running], [reset] y [clearObstacle]; el juego avisa lo que pasa
// por callbacks.
class DashGame extends FlameGame with TapCallbacks, HasCollisionDetection {
  final VoidCallback onPlayerHit;
  final VoidCallback onScoreTick;
  final VoidCallback onDiamondCollected;
  final VoidCallback onJump;

  DashGame({
    required this.onPlayerHit,
    required this.onScoreTick,
    required this.onDiamondCollected,
    required this.onJump,
  });

  // false = física congelada (inicio, pausa, game over). El motor sigue dibujando,
  // así los cambios de tema o de partida se ven aunque el juego no avance.
  bool running = false;
  bool isNight = false; // Cielo de noche en modo oscuro

  final PlayerComponent player = PlayerComponent();
  final ObstacleComponent obstacle = ObstacleComponent();
  final GroundComponent ground = GroundComponent();

  double get groundTop => size.y - GameConfig.groundHeight;

  @override
  Color backgroundColor() => const Color(0x00000000); // El cielo lo dibuja SkyComponent

  @override
  Future<void> onLoad() async {
    // El orden define qué se dibuja encima
    await addAll([SkyComponent(), ground, obstacle, player]);
  }

  @override
  void update(double dt) {
    super.update(running ? math.min(dt, GameConfig.maxFrameTime) : 0);
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (!running) return;
    player.jump();
    onJump();
  }

  // Partida nueva: todo vuelve a la posición inicial
  void reset() {
    player.reset();
    obstacle.reset();
    ground.reset();
  }

  // Al revivir: el obstáculo que nos golpeó reaparece en el borde derecho
  void clearObstacle() => obstacle.respawnAtEdge();

  void handleHit() {
    if (!running) return;
    running = false; // Se congela en el acto, antes de que Flutter cambie de estado
    onPlayerHit();
  }

  void collectDiamond(DiamondComponent diamond) {
    if (!running) return;
    obstacle.removeDiamond();
    onDiamondCollected();
  }
}
