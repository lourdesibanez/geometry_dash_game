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
// desde afuera con [corriendo], [reiniciar] y [quitarObstaculo]; el juego avisa lo que
// pasa por callbacks.
class DashGame extends FlameGame with TapCallbacks, HasCollisionDetection {
  final VoidCallback alChocar;
  final VoidCallback alSumarPuntos;
  final VoidCallback alAgarrarDiamante;
  final VoidCallback alSaltar;

  DashGame({
    required this.alChocar,
    required this.alSumarPuntos,
    required this.alAgarrarDiamante,
    required this.alSaltar,
  });

  // false = física congelada (inicio, pausa, game over). El motor sigue dibujando,
  // así los cambios de tema o de partida se ven aunque el juego no avance.
  bool corriendo = false;
  bool esNoche = false; // Cielo de noche en modo oscuro

  final PlayerComponent jugador = PlayerComponent();
  final ObstacleComponent obstaculo = ObstacleComponent();
  final GroundComponent piso = GroundComponent();

  double get bordePiso => size.y - GameConfig.alturaPiso;

  @override
  Color backgroundColor() => const Color(0x00000000); // El cielo lo dibuja SkyComponent

  @override
  Future<void> onLoad() async {
    // El orden define qué se dibuja encima
    await addAll([SkyComponent(), piso, obstaculo, jugador]);
  }

  @override
  void update(double dt) {
    super.update(corriendo ? math.min(dt, GameConfig.maximoTiempoCuadro) : 0);
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (!corriendo) return;
    jugador.saltar();
    alSaltar();
  }

  // Partida nueva: todo vuelve a la posición inicial
  void reiniciar() {
    jugador.reiniciar();
    obstaculo.reiniciar();
    piso.reiniciar();
  }

  // Al revivir: el obstáculo que nos golpeó reaparece en el borde derecho
  void quitarObstaculo() => obstaculo.reaparecerEnBorde();

  void manejarChoque() {
    if (!corriendo) return;
    corriendo = false; // Se congela en el acto, antes de que Flutter cambie de estado
    alChocar();
  }

  void agarrarDiamante(DiamondComponent diamante) {
    if (!corriendo) return;
    obstaculo.quitarDiamante();
    alAgarrarDiamante();
  }
}
