import 'dart:async';
import 'package:flutter/foundation.dart';
import '../core/game_rules.dart';
import '../models/game_state.dart';
import '../models/player_state.dart';
import '../services/storage_service.dart';

// Lógica del juego separada de la UI (patrón ViewModel).
// La física del salto (60 cuadros por segundo) NO está acá: es estado efímero del juego en Flame.
class GameController extends ChangeNotifier {
  PlayerState _jugador = PlayerState.inicial();
  GameState _estadoJuego = GameState.idle;
  int _ronda = 0; // Se incrementa en cada partida nueva para resetear el juego
  int _vecesRevivido = 0; // Se incrementa al revivir para sacar el obstáculo que nos golpeó
  bool _yaRevivio = false; // Un solo revivir por partida
  int _diamantesPartida = 0; // Diamantes agarrados en esta partida 
  bool _nuevoRecord = false; // Se superó el récord en esta partida
  int? _cuentaRegresiva; // 3, 2, 1 al revivir o en NUEVA PARTIDA; null = no hay cuenta en curso
  Timer? _temporizador;

  // Getters de solo lectura: la UI puede leer el estado, pero solo lo cambia con los métodos
  PlayerState get jugador => _jugador;
  GameState get estadoJuego => _estadoJuego;
  int get ronda => _ronda;
  int get vecesRevivido => _vecesRevivido;
  bool get esPro => _jugador.esPro;
  bool get modoOscuro => _jugador.modoOscuro;
  bool get sonidoActivado => _jugador.sonidoActivado;
  int get costoRevivir => esPro ? GameRules.costoRevivirPro : GameRules.costoRevivirBasic;
  int get diamantesPartida => _diamantesPartida;
  bool get nuevoRecord => _nuevoRecord;
  int? get cuentaRegresiva => _cuentaRegresiva;

  // Fecha de la próxima entrega de diamantes PRO (null si nunca recibió)
  DateTime? get proximoRegaloPro {
    final ultimo = _jugador.ultimoRegaloPro;
    if (ultimo == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(ultimo).add(GameRules.periodoRegaloPro);
  }

  // Carga lo guardado. Devuelve cuántos diamantes PRO se regalaron (0 si no correspondía)
  Future<int> cargar() async {
    _jugador = await StorageService.cargarEstadoJugador();
    notifyListeners();
    return _entregarDiamantesMensualesPro();
  }

  // Entrega los diamantes mensuales de PRO que se hayan acumulado desde la última vez
  int _entregarDiamantesMensualesPro() {
    if (!esPro) return 0;
    final ahora = DateTime.now().millisecondsSinceEpoch;
    final ultimo = _jugador.ultimoRegaloPro;

    // Cuentas PRO anteriores a esta función: empiezan a contar desde hoy
    if (ultimo == null) {
      _actualizar(_jugador.copiarCon(ultimoRegaloPro: ahora));
      return 0;
    }

    final periodos = (ahora - ultimo) ~/ GameRules.periodoRegaloPro.inMilliseconds;
    if (periodos <= 0) return 0;

    final regalo = periodos * GameRules.diamantesMensualesPro;
    _actualizar(_jugador.copiarCon(
      diamantes: _jugador.diamantes + regalo,
      ultimoRegaloPro: ultimo + periodos * GameRules.periodoRegaloPro.inMilliseconds,
    ));
    return regalo;
  }


  // INICIAR: arranca de cero y jugando
  void iniciarPartida() => _reiniciarRonda(GameState.playing);

  // después del game over arranca de cero con la cuenta 3, 2, 1
  void nuevaPartida() {
    _reiniciarRonda(GameState.paused);
    _iniciarCuentaRegresiva();
    notifyListeners();
  }

  // después de reiniciar arranca de cero en la pantalla de iniciar partida
  void volverAlInicio() => _reiniciarRonda(GameState.idle);

  void _reiniciarRonda(GameState estadoInicial) {
    _cancelarCuentaRegresiva();
    _ronda++;
    _yaRevivio = false;
    _diamantesPartida = 0;
    _nuevoRecord = false;
    _estadoJuego = estadoInicial;
    _actualizar(_jugador.copiarCon(puntaje: 0));
  }

  void pausar() => _cambiarEstadoJuego(GameState.paused);

  void reanudar() => _cambiarEstadoJuego(GameState.playing);

  // Antes de abrir un modal: que el juego no siga corriendo detrás
  void pausarSiEstaJugando() {
    if (_estadoJuego == GameState.playing || _cuentaRegresiva != null) pausar();
  }

  void terminarPartida() => _cambiarEstadoJuego(GameState.gameOver);

  // Suma puntos y, si se supera, actualiza el récord
  void sumarPuntos() {
    final puntaje = _jugador.puntaje + GameRules.puntosPorObstaculo;
    if (puntaje > _jugador.record) _nuevoRecord = true;
    _actualizar(_jugador.copiarCon(
      puntaje: puntaje,
      record: puntaje > _jugador.record ? puntaje : null,
    ));
  }

  // El jugador agarró un diamante en pantalla
  void agarrarDiamante() {
    _diamantesPartida += GameRules.diamantesPorAgarrar;
    _actualizar(_jugador.copiarCon(diamantes: _jugador.diamantes + GameRules.diamantesPorAgarrar));
  }

  // Choque con un obstáculo. Devuelve true si hay que ofrecer revivir
  bool chocar() {
    if (_yaRevivio) {
      terminarPartida();
      return false;
    }
    pausar(); // Congelado mientras el jugador decide
    return true;
  }

  // Gasta diamantes para seguir. Queda en pausa y arranca la cuenta regresiva:
  // al llegar a cero el juego sigue solo 
  void revivir() {
    if (_jugador.diamantes < costoRevivir) return;
    _yaRevivio = true;
    _vecesRevivido++;
    _estadoJuego = GameState.paused;
    _iniciarCuentaRegresiva();
    _actualizar(_jugador.copiarCon(diamantes: _jugador.diamantes - costoRevivir));
  }

  // ---------- Tienda y cuenta ----------

  void comprarDiamantes(int cantidad) {
    _actualizar(_jugador.copiarCon(diamantes: _jugador.diamantes + cantidad));
  }

  // PRO: sin publicidad + revivir más barato + diamantes mensuales (el primer mes se entrega ya)
  void comprarPro() {
    _actualizar(_jugador.copiarCon(
      tipoCuenta: AccountType.pro,
      diamantes: _jugador.diamantes + GameRules.diamantesMensualesPro,
      ultimoRegaloPro: DateTime.now().millisecondsSinceEpoch,
    ));
  }

  // Vuelve a BASIC; los diamantes que ya tiene se quedan
  void cancelarPro() {
    _actualizar(_jugador.copiarCon(tipoCuenta: AccountType.basic));
  }

  void alternarTema() {
    _actualizar(_jugador.copiarCon(modoOscuro: !_jugador.modoOscuro));
  }

  void alternarSonido() {
    _actualizar(_jugador.copiarCon(sonidoActivado: !_jugador.sonidoActivado));
  }

  // ---------- Internos ----------

  // Cambios que no se guardan (estado de la partida en curso).
  // Cualquier cambio de estado (reanudar, pausar, terminar) corta la cuenta regresiva
  void _cambiarEstadoJuego(GameState estado) {
    _cancelarCuentaRegresiva();
    _estadoJuego = estado;
    notifyListeners();
  }

  void _iniciarCuentaRegresiva() {
    _cancelarCuentaRegresiva();
    _cuentaRegresiva = GameRules.segundosCuentaRegresiva;
    _temporizador = Timer.periodic(const Duration(seconds: 1), (_) {
      final restante = _cuentaRegresiva! - 1;
      if (restante <= 0) {
        reanudar();
      } else {
        _cuentaRegresiva = restante;
        notifyListeners();
      }
    });
  }

  void _cancelarCuentaRegresiva() {
    _temporizador?.cancel();
    _temporizador = null;
    _cuentaRegresiva = null;
  }

  @override
  void dispose() {
    _cancelarCuentaRegresiva();
    super.dispose();
  }

  // Cambios del jugador: se guardan en el dispositivo y se avisa a la UI
  void _actualizar(PlayerState nuevoEstado) {
    _jugador = nuevoEstado;
    StorageService.guardarEstadoJugador(nuevoEstado);
    notifyListeners();
  }
}
