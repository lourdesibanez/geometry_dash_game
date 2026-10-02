import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../../core/game_rules.dart';
import '../../core/theme.dart';
import '../../models/game_state.dart';
import '../atoms/game_label.dart';
import '../atoms/obstacle.dart';
import '../atoms/player.dart';

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

class _GameCanvasState extends State<GameCanvas> with SingleTickerProviderStateMixin {
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
  bool _hasJumped = false; // Para ocultar el cartel de ayuda tras el primer salto
  double _scroll = 0.0; // Distancia recorrida: mueve las baldosas del piso
  Size? _canvasSize;

  // Bucle del juego: el Ticker llama a _tick una vez por cuadro, sincronizado con
  // el refresco de la pantalla (vsync), y se pausa solo si la app queda en segundo plano
  late final Ticker _gameLoop = createTicker(_tick);
  Duration _lastTick = Duration.zero;

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
      if (!_gameLoop.isActive) _startGameLoop();
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
      _hasJumped = false;
    });
  }

  void _startGameLoop() {
    _lastTick = Duration.zero; // Al arrancar, el Ticker vuelve a contar desde cero
    _gameLoop.start();
  }

  // elapsed: tiempo desde que arrancó el Ticker. dt = segundos desde el cuadro anterior
  void _tick(Duration elapsed) {
    final size = _canvasSize;
    if (size == null) return;

    final dt = ((elapsed - _lastTick).inMicroseconds / 1e6).clamp(0.0, 0.05);
    _lastTick = elapsed;
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
      _scroll += _obstacleSpeed * dt;

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
    if (_gameLoop.isActive) _gameLoop.stop();
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
      setState(() {
        _hasJumped = true;
        _startJump();
      });
    }
  }

  @override
  void dispose() {
    _gameLoop.dispose();
    super.dispose();
  }

  String? get _hintText {
    switch (widget.gameState) {
      case GameState.idle:
        return null; // El botón INICIAR PARTIDA ya indica qué hacer
      case GameState.playing:
        return _hasJumped ? null : 'TOCÁ LA PANTALLA PARA SALTAR';
      case GameState.paused:
        return 'PAUSA';
      case GameState.gameOver:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hint = _hintText;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      label: 'Área de juego',
      hint: 'Tocá para saltar',
      child: GestureDetector(
        onTapDown: (_) => _jump(), // onTapDown responde al instante, sin esperar a soltar
        // Marco turquesa con contorno azul marino
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: AppColors.teal,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.ink, width: 3),
            boxShadow: const [
              BoxShadow(color: AppColors.ink, offset: Offset(0, 5), blurRadius: 0),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.ink, width: 3),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final size = constraints.biggest;
                  _canvasSize = size;
                  final groundTop = _groundTop(size);
                  final cubeTop = groundTop - _cubeY - _cubeSize;

                  return Stack(
                    children: [
                      // Cielo con degradé (día o noche) y grilla suave
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: isDark
                                  ? const [AppColors.skyTopNight, AppColors.skyBottomNight]
                                  : const [AppColors.skyTop, AppColors.skyBottom],
                            ),
                          ),
                          child: CustomPaint(painter: _GridPainter(isDark)),
                        ),
                      ),

                      // Piso con baldosas que se mueven
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        height: _groundHeight,
                        child: CustomPaint(
                          painter: _GroundPainter(_scroll, isDark ? AppColors.groundNight : AppColors.ground),
                        ),
                      ),

                      // Estela del cubo mientras vuela
                      if (_isAirborne)
                        for (var i = 1; i <= 3; i++)
                          Positioned(
                            left: _cubeLeft(size) - i * 14.0,
                            top: cubeTop + _cubeSize / 2 + i * 4.0,
                            child: Opacity(
                              opacity: 0.6 - i * 0.15,
                              child: Container(
                                width: 12.0 - i * 2,
                                height: 12.0 - i * 2,
                                color: AppColors.cream,
                              ),
                            ),
                          ),

                      // Personaje: Cubo con carita y rotación
                      Positioned(
                        left: _cubeLeft(size),
                        top: cubeTop,
                        child: Player(size: _cubeSize, angle: _rotationAngle),
                      ),

                      // Obstáculo: dos pinchos
                      if (_obstacleX != null)
                        Positioned(
                          left: _obstacleX,
                          top: groundTop - _obstacleSize,
                          child: const Obstacle(size: _obstacleSize),
                        ),

                      // Cartel de ayuda / pausa
                      if (hint != null)
                        Positioned(
                          top: 16,
                          left: 0,
                          right: 0,
                          child: Center(child: GameLabel(hint)),
                        ),

                      // Pop-up flotante de puntos "+10 PTS" para Niños
                      if (_showScorePop)
                        const Positioned(
                          top: 16,
                          right: 16,
                          child: GameLabel('+${GameRules.pointsPerObstacle} PTS!', color: AppColors.yellow, fontSize: 15),
                        ),

                      // Game over: oscurece el escenario y muestra el cartel
                      if (widget.gameState == GameState.gameOver)
                        Positioned.fill(
                          child: Container(
                            color: AppColors.ink.withValues(alpha: 0.45),
                            alignment: Alignment.center,
                            child: const GameLabel(
                              '¡GAME OVER!',
                              color: AppColors.pink,
                              textColor: Colors.white,
                              fontSize: 26,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Grilla suave del cielo; de noche además dibuja estrellitas
class _GridPainter extends CustomPainter {
  final bool isNight;

  _GridPainter(this.isNight);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: isNight ? 0.06 : 0.35)
      ..strokeWidth = 1;
    const step = 32.0;
    for (var x = 0.0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    if (isNight) {
      // Posiciones fijas (semilla constante) para que las estrellas no titilen al redibujar
      final random = math.Random(7);
      final star = Paint()..color = Colors.white.withValues(alpha: 0.8);
      for (var i = 0; i < 30; i++) {
        final pos = Offset(random.nextDouble() * size.width, random.nextDouble() * size.height * 0.7);
        canvas.drawCircle(pos, random.nextDouble() * 1.5 + 0.5, star);
      }
    }
  }

  @override
  bool shouldRepaint(_GridPainter oldDelegate) => oldDelegate.isNight != isNight;
}

// Piso con línea brillante y baldosas que avanzan
class _GroundPainter extends CustomPainter {
  final double scroll;
  final Color color;

  _GroundPainter(this.scroll, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = color);

    const tile = 40.0;
    final tilePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..strokeWidth = 2;
    for (var x = -(scroll % tile); x < size.width; x += tile) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), tilePaint);
    }

    canvas.drawLine(
      Offset.zero,
      Offset(size.width, 0),
      Paint()
        ..color = AppColors.groundLine
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(_GroundPainter oldDelegate) =>
      oldDelegate.scroll != scroll || oldDelegate.color != color;
}
