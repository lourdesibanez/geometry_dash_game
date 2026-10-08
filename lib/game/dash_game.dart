import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../core/game_rules.dart';
import '../services/audio_service.dart';
import 'components/diamond_component.dart';
import 'components/floating_reward_component.dart';
import 'components/ground_component.dart';
import 'components/obstacle_component.dart';
import 'components/player_component.dart';
import 'components/sky_component.dart';
import 'game_config.dart';
import 'game_icons.dart';

// El juego en sí. Junta las piezas, recibe el toque para saltar, 
//congela la física en pausa y le avisa a Flutter cuando chocás, esquivás o agarrás un diamante
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
    // Premios flotantes que quedaron a medio animar
    removeAll(children.whereType<FloatingRewardComponent>().toList());
  }

  // Al revivir: el obstáculo que nos golpeó reaparece en el borde derecho
  void quitarObstaculo() => obstaculo.reaparecerEnBorde();

  void manejarChoque() {
    if (!corriendo) return;
    corriendo = false; // Se congela en el acto, antes de que Flutter cambie de estado
    AudioService.choque();
    alChocar();
  }

  void agarrarDiamante(DiamondComponent diamante) {
    if (!corriendo) return;
    obstaculo.quitarDiamante();
    AudioService.diamante();
    // "+1" con diamante que sale desde arriba del cubo, sube y se desvanece
    add(FloatingRewardComponent(
      texto: '+${GameRules.diamantesPorAgarrar}',
      icono: GameIcon.diamante,
      posicion: jugador.position + Vector2(jugador.size.x / 2, -4),
    ));
    alAgarrarDiamante();
  }

  // Un pincho salió por la izquierda: "+10" con estrella en la esquina superior derecha
  // (arranca 60 px más abajo para terminar de subir a 16 px del borde)
  void esquivarObstaculo() {
    add(FloatingRewardComponent(
      texto: '+${GameRules.puntosPorObstaculo}',
      icono: GameIcon.estrella,
      posicion: Vector2(size.x - 16, 76),
      ancla: Anchor.topRight,
    ));
    alSumarPuntos();
  }
}
