import 'dart:async';
import 'package:flutter/material.dart';
import '../organisms/control_panel.dart';
import 'dart:math' as math;

class GameCanvas extends StatefulWidget {
  final GameState gameState;
  final int round; // Cambia en cada partida nueva/reinicio para resetear la física
  final int reviveCount; // Cambia al revivir: se quita el obstáculo que nos golpeó
  final VoidCallback onPlayerHit;
  final VoidCallback onScoreTick;

  const GameCanvas({
    super.key,
    required this.gameState,
    required this.round,
    required this.reviveCount,
    required this.onPlayerHit,
    required this.onScoreTick,
  });

  @override
  State<GameCanvas> createState() => _GameCanvasState();
}

class _GameCanvasState extends State<GameCanvas> {
  // Física en píxeles y segundos. Ajustada para niños: salto alto y con margen,
  // pero con la sensación de Geometry Dash (sube rápido, flota, cae acelerando).
  static const double _gravity = 1800;
  static const double _jumpVelocity = 630;
  static const double _airTime = 2 * _jumpVelocity / _gravity; // ~0.7 s
  static const double _obstacleSpeed = 220;
  static const double _jumpBufferTime = 0.15; // Tap un poco antes de aterrizar igual cuenta
  static const double _groundHeight = 40;
  static const double _cubeSize = 44;
  static const double _obstacleSize = 36;
  static const double _hitboxInset = 6; // Hitbox más chica que el dibujo: rozar no mata
  static const double _cubeXFactor = 0.25; // Cubo a la izquierda: más tiempo para reaccionar

  double _cubeY = 0.0; // Altura sobre el piso
  double _velocityY = 0.0;
  double _timeInAir = 0.0;
  double _jumpBuffer = 0.0;
  double? _obstacleX; // Borde izquierdo; null hasta conocer el tamaño del canvas
  bool _showScorePop = false; // Efecto visual flotante +10
  Size? _canvasSize;
  Timer? _gameLoop;
  final Stopwatch _clock = Stopwatch()..start();
  double _lastTick = 0.0;

  bool get _isAirborne => _cubeY > 0.0 || _velocityY > 0.0;

  // Una vuelta completa por salto: la carita siempre aterriza derecha
  double get _rotationAngle =>
      _isAirborne ? 2 * math.pi * (_timeInAir / _airTime).clamp(0.0, 1.0) : 0.0;

  @override
  void didUpdateWidget(GameCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.round != oldWidget.round || widget.gameState == GameState.idle) {
      _resetPositions();
    } else if (widget.reviveCount != oldWidget.reviveCount) {
      setState(() => _obstacleX = null); // Reaparece en el borde derecho
    }
    if (widget.gameState == GameState.playing) {
      if (_gameLoop == null) _startGameLoop();
    } else {
      _stopGameLoop();
    }
  }

  void _resetPositions() {
    setState(() {
      _cubeY = 0.0;
      _velocityY = 0.0;
      _timeInAir = 0.0;
      _jumpBuffer = 0.0;
      _obstacleX = null;
    });
  }

  void _startGameLoop() {
    _gameLoop?.cancel();
    _lastTick = _clock.elapsedMicroseconds / 1e6;
    _gameLoop = Timer.periodic(const Duration(milliseconds: 16), (_) => _tick());
  }

  void _tick() {
    final size = _canvasSize;
    if (size == null) return;

    final now = _clock.elapsedMicroseconds / 1e6;
    final dt = (now - _lastTick).clamp(0.0, 0.05);
    _lastTick = now;
    var scored = false;
    var hit = false;

    setState(() {
      // Obstáculo
      var obstacleX = (_obstacleX ?? size.width) - _obstacleSpeed * dt;
      if (obstacleX < -_obstacleSize) {
        obstacleX = size.width;
        scored = true;
      }
      _obstacleX = obstacleX;

      // Salto con gravedad
      if (_jumpBuffer > 0) _jumpBuffer -= dt;
      if (_isAirborne) {
        _velocityY -= _gravity * dt;
        _cubeY += _velocityY * dt;
        _timeInAir += dt;
        if (_cubeY <= 0.0) {
          _cubeY = 0.0;
          _velocityY = 0.0;
          _timeInAir = 0.0;
          if (_jumpBuffer > 0) _startJump();
        }
      }

      hit = _cubeRect(size).overlaps(_obstacleRect(size));
    });

    if (hit) {
      _stopGameLoop();
      widget.onPlayerHit();
    } else if (scored) {
      widget.onScoreTick();
      _triggerScorePop(); // Activa animación de feedback visual
    }
  }

  double _groundTop(Size size) => size.height - _groundHeight;

  double _cubeLeft(Size size) => size.width * _cubeXFactor - _cubeSize / 2;

  Rect _cubeRect(Size size) => Rect.fromLTWH(
        _cubeLeft(size),
        _groundTop(size) - _cubeY - _cubeSize,
        _cubeSize,
        _cubeSize,
      ).deflate(_hitboxInset);

  Rect _obstacleRect(Size size) => Rect.fromLTWH(
        _obstacleX ?? size.width,
        _groundTop(size) - _obstacleSize,
        _obstacleSize,
        _obstacleSize,
      ).deflate(_hitboxInset);

  void _triggerScorePop() {
    setState(() => _showScorePop = true);
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _showScorePop = false);
    });
  }

  void _stopGameLoop() {
    _gameLoop?.cancel();
    _gameLoop = null;
  }

  void _startJump() {
    _velocityY = _jumpVelocity;
    _timeInAir = 0.0;
    _jumpBuffer = 0.0;
  }

  void _jump() {
    if (widget.gameState != GameState.playing) return;
    if (_isAirborne) {
      _jumpBuffer = _jumpBufferTime; // Se guarda y salta apenas toque el piso
    } else {
      setState(_startJump);
    }
  }

  @override
  void dispose() {
    _stopGameLoop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _jump(), // onTapDown responde al instante, sin esperar a soltar
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black, width: 3.5),
          boxShadow: const [
            BoxShadow(color: Colors.black, offset: Offset(5, 5), blurRadius: 0),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final size = constraints.biggest;
              _canvasSize = size;
              final groundTop = _groundTop(size);

              return Stack(
                children: [
                  // Fondo espacial / Arcade
                  Positioned.fill(
                    child: Container(
                      color: widget.gameState == GameState.gameOver
                          ? const Color(0xFFFFCDD2)
                          : const Color(0xFF1E1E2C),
                    ),
                  ),

                  // Suelo Neo-Brutalista
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: _groundHeight,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFF00E676),
                        border: Border(top: BorderSide(color: Colors.black, width: 3.5)),
                      ),
                    ),
                  ),

                  // Personaje: Cubo con Rotación Dynamica
                  Positioned(
                    left: _cubeLeft(size),
                    top: groundTop - _cubeY - _cubeSize,
                    child: Transform.rotate(
                      angle: _rotationAngle,
                      child: Container(
                        width: _cubeSize,
                        height: _cubeSize,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEA00),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.black, width: 3),
                          boxShadow: const [
                            BoxShadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 0),
                          ],
                        ),
                        child: const Icon(Icons.face_retouching_natural, color: Colors.black, size: 28),
                      ),
                    ),
                  ),

                  // Obstáculo: Spike Rojo Neón
                  if (_obstacleX != null)
                    Positioned(
                      left: _obstacleX,
                      top: groundTop - _obstacleSize,
                      child: Container(
                        width: _obstacleSize,
                        height: _obstacleSize,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF5252),
                          border: Border.all(color: Colors.black, width: 3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(Icons.warning_amber_rounded, color: Colors.black, size: 24),
                      ),
                    ),

                  // Pop-up flotante de puntos "+10 PTS" para Niños
                  if (_showScorePop)
                    Positioned(
                      top: 40,
                      right: 40,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00E5FF),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.black, width: 2.5),
                          boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(2, 2))],
                        ),
                        child: const Text(
                          '+10 PTS!',
                          style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black, fontSize: 16),
                        ),
                      ),
                    ),

                  if (widget.gameState == GameState.idle)
                    const Center(
                      child: Text(
                        'PRESIONA INICIAR',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20),
                      ),
                    ),
                  if (widget.gameState == GameState.gameOver)
                    const Center(
                      child: Text(
                        '¡GAME OVER!',
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 26),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
