import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../../core/game_rules.dart';
import '../../core/theme.dart';
import '../../game/dash_game.dart';
import '../../models/game_state.dart';
import '../atoms/game_label.dart';

// App híbrida: el juego corre en Flame (DashGame) y se muestra dentro de un GameWidget.
// Este widget de Flutter lo controla desde afuera según el estado de la partida y
// dibuja encima los carteles (ayuda, pausa, puntos, game over).
class GameCanvas extends StatefulWidget {
  final GameState estadoJuego;
  final int ronda; // Cambia en cada partida nueva/reinicio para resetear el juego
  final int vecesRevivido; // Cambia al revivir: se quita el obstáculo que nos golpeó
  final VoidCallback alChocar;
  final VoidCallback alSumarPuntos;
  final VoidCallback alAgarrarDiamante;

  const GameCanvas({
    super.key,
    required this.estadoJuego,
    required this.ronda,
    required this.vecesRevivido,
    required this.alChocar,
    required this.alSumarPuntos,
    required this.alAgarrarDiamante,
  });

  @override
  State<GameCanvas> createState() => _GameCanvasState();
}

class _GameCanvasState extends State<GameCanvas> {
  // Los callbacks pasan por el widget actual: si el padre cambia de callback, se usa el nuevo
  late final DashGame _juego = DashGame(
    alChocar: () => widget.alChocar(),
    alSumarPuntos: _alSumarPuntos,
    alAgarrarDiamante: _alAgarrarDiamante,
    alSaltar: _alSaltar,
  );

  ({String texto, Color color})? _cartel; // Cartel flotante: "+10 PTS!" o "+1 💎"
  int _idCartel = 0; // Para que un cartel nuevo no se borre con el temporizador del anterior
  bool _yaSalto = false; // Para ocultar el cartel de ayuda tras el primer salto

  @override
  void initState() {
    super.initState();
    _juego.corriendo = widget.estadoJuego == GameState.playing;
  }

  @override
  void didUpdateWidget(GameCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.ronda != oldWidget.ronda || widget.estadoJuego == GameState.idle) {
      _juego.reiniciar();
      _yaSalto = false;
    } else if (widget.vecesRevivido != oldWidget.vecesRevivido) {
      _juego.quitarObstaculo();
    }
    // Iniciar / pausar / reanudar se controla desde la botonera de Flutter
    _juego.corriendo = widget.estadoJuego == GameState.playing;
  }

  void _alSumarPuntos() {
    widget.alSumarPuntos();
    _mostrarCartel('+${GameRules.puntosPorObstaculo} PTS!', AppColors.amarillo);
  }

  void _alAgarrarDiamante() {
    widget.alAgarrarDiamante();
    _mostrarCartel('+${GameRules.diamantesPorAgarrar} 💎', AppColors.diamante);
  }

  void _alSaltar() {
    if (!_yaSalto) setState(() => _yaSalto = true);
  }

  // Muestra un cartel flotante por 600 ms (feedback visual)
  void _mostrarCartel(String texto, Color color) {
    final id = ++_idCartel;
    setState(() => _cartel = (texto: texto, color: color));
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted && id == _idCartel) setState(() => _cartel = null);
    });
  }

  String? get _textoAyuda {
    switch (widget.estadoJuego) {
      case GameState.idle:
        return null; // El botón INICIAR PARTIDA ya indica qué hacer
      case GameState.playing:
        return _yaSalto ? null : 'TOCÁ LA PANTALLA PARA SALTAR';
      case GameState.paused:
        return 'PAUSA';
      case GameState.gameOver:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ayuda = _textoAyuda;
    final cartel = _cartel;
    _juego.esNoche = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      label: 'Área de juego',
      hint: 'Tocá para saltar',
      // Marco turquesa con contorno azul marino
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: AppColors.turquesa,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.tinta, width: 3),
          boxShadow: const [
            BoxShadow(color: AppColors.tinta, offset: Offset(0, 5), blurRadius: 0),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.tinta, width: 3),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Stack(
              children: [
                // El juego (Flame): cielo, piso, cubo, pinchos y diamantes. Los toques
                // para saltar los recibe el propio juego
                Positioned.fill(child: GameWidget(game: _juego)),

                // Carteles de Flutter encima del juego. IgnorePointer: no tapan los toques
                if (ayuda != null)
                  Positioned(
                    top: 16,
                    left: 0,
                    right: 0,
                    child: IgnorePointer(child: Center(child: GameLabel(ayuda))),
                  ),

                // Cartel flotante de feedback: "+10 PTS!" al esquivar, "+1 💎" al agarrar un diamante
                if (cartel != null)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: IgnorePointer(child: GameLabel(cartel.texto, color: cartel.color, tamanoLetra: 15)),
                  ),

                // Game over: oscurece el escenario y muestra el cartel
                if (widget.estadoJuego == GameState.gameOver)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        color: AppColors.tinta.withValues(alpha: 0.45),
                        alignment: Alignment.center,
                        child: const GameLabel(
                          '¡GAME OVER!',
                          color: AppColors.rosa,
                          colorTexto: Colors.white,
                          tamanoLetra: 26,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
