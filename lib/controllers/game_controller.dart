import 'package:flutter/foundation.dart';
import '../core/game_rules.dart';
import '../models/game_state.dart';
import '../models/player_state.dart';
import '../services/storage_service.dart';

// Lógica del juego separada de la UI (patrón ViewModel).
// Guarda el estado de la app, aplica las reglas y avisa a la UI con notifyListeners().
// La física del salto (60 cuadros por segundo) NO está acá: es estado efímero del juego en Flame.
class GameController extends ChangeNotifier {
  PlayerState _jugador = PlayerState.inicial();
  GameState _estadoJuego = GameState.idle;
  int _ronda = 0; // Se incrementa en cada partida nueva para resetear el juego
  int _vecesRevivido = 0; // Se incrementa al revivir para sacar el obstáculo que nos golpeó
  bool _yaRevivio = false; // Un solo revivir por partida

  // Getters de solo lectura: la UI puede leer el estado, pero solo lo cambia con los métodos
  PlayerState get jugador => _jugador;
  GameState get estadoJuego => _estadoJuego;
  int get ronda => _ronda;
  int get vecesRevivido => _vecesRevivido;
  bool get esPro => _jugador.esPro;
  bool get modoOscuro => _jugador.modoOscuro;
  int get costoRevivir => esPro ? GameRules.costoRevivirPro : GameRules.costoRevivirBasic;

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

  // ---------- Partida ----------

  // INICIAR, NUEVA PARTIDA: arranca de cero y jugando
  void iniciarPartida() => _reiniciarRonda(GameState.playing);

  // Después de REINICIAR: arranca de cero en la pantalla de INICIAR PARTIDA
  void volverAlInicio() => _reiniciarRonda(GameState.idle);

  void _reiniciarRonda(GameState estadoInicial) {
    _ronda++;
    _yaRevivio = false;
    _estadoJuego = estadoInicial;
    _actualizar(_jugador.copiarCon(puntaje: 0));
  }

  void pausar() => _cambiarEstadoJuego(GameState.paused);

  void reanudar() => _cambiarEstadoJuego(GameState.playing);

  // Antes de abrir un modal: que el juego no siga corriendo detrás
  void pausarSiEstaJugando() {
    if (_estadoJuego == GameState.playing) pausar();
  }

  void terminarPartida() => _cambiarEstadoJuego(GameState.gameOver);

  // Suma puntos y, si se supera, actualiza el récord
  void sumarPuntos() {
    final puntaje = _jugador.puntaje + GameRules.puntosPorObstaculo;
    _actualizar(_jugador.copiarCon(
      puntaje: puntaje,
      record: puntaje > _jugador.record ? puntaje : null,
    ));
  }

  // El jugador agarró un diamante en pantalla
  void agarrarDiamante() {
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

  // Gasta diamantes para seguir. Queda en pausa: sigue cuando toque REANUDAR
  void revivir() {
    if (_jugador.diamantes < costoRevivir) return;
    _yaRevivio = true;
    _vecesRevivido++;
    _estadoJuego = GameState.paused;
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

  // ---------- Internos ----------

  // Cambios que no se guardan (estado de la partida en curso)
  void _cambiarEstadoJuego(GameState estado) {
    _estadoJuego = estado;
    notifyListeners();
  }

  // Cambios del jugador: se guardan en el dispositivo y se avisa a la UI
  void _actualizar(PlayerState nuevoEstado) {
    _jugador = nuevoEstado;
    StorageService.guardarEstadoJugador(nuevoEstado);
    notifyListeners();
  }
}
