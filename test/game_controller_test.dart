import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geometry_dash_game/controllers/game_controller.dart';
import 'package:geometry_dash_game/core/game_rules.dart';
import 'package:geometry_dash_game/models/game_state.dart';
import 'package:geometry_dash_game/models/player_state.dart';

// Simula lo que hay guardado en el dispositivo (vacío = jugador nuevo)
Future<GameController> cargarControlador([Map<String, dynamic>? guardado]) async {
  SharedPreferences.setMockInitialValues(
    guardado == null ? {} : {'@game_player_state': jsonEncode(guardado)},
  );
  final controlador = GameController();
  await controlador.cargar();
  return controlador;
}

void main() {
  test('Un jugador nuevo arranca en BASIC, modo claro y con los diamantes iniciales', () async {
    final juego = await cargarControlador();

    expect(juego.esPro, isFalse);
    expect(juego.modoOscuro, isFalse);
    expect(juego.jugador.diamantes, GameRules.diamantesIniciales);
    expect(juego.estadoJuego, GameState.idle);
  });

  test('Sumar puntos actualiza el récord, y una partida nueva lo conserva', () async {
    final juego = await cargarControlador();

    juego.iniciarPartida();
    juego.sumarPuntos();
    juego.sumarPuntos();
    expect(juego.jugador.puntaje, 2 * GameRules.puntosPorObstaculo);
    expect(juego.jugador.record, 2 * GameRules.puntosPorObstaculo);

    juego.iniciarPartida();
    juego.sumarPuntos();
    expect(juego.jugador.puntaje, GameRules.puntosPorObstaculo);
    expect(juego.jugador.record, 2 * GameRules.puntosPorObstaculo); // No baja
  });

  test('Se revive una sola vez por partida y cuesta diamantes', () async {
    final juego = await cargarControlador();
    juego.iniciarPartida();

    expect(juego.chocar(), isTrue); // Primer choque: se ofrece revivir
    expect(juego.estadoJuego, GameState.paused);

    juego.revivir();
    expect(juego.jugador.diamantes, GameRules.diamantesIniciales - GameRules.costoRevivirBasic);

    juego.reanudar();
    expect(juego.chocar(), isFalse); // Segundo choque: se termina
    expect(juego.estadoJuego, GameState.gameOver);
  });

  test('Sin diamantes suficientes no se puede revivir', () async {
    final juego = await cargarControlador(PlayerState.inicial().copiarCon(diamantes: 3).aJson());
    juego.iniciarPartida();
    juego.chocar();

    juego.revivir();
    expect(juego.jugador.diamantes, 3);
    expect(juego.vecesRevivido, 0);
  });

  test('Comprar PRO regala diamantes y abarata el revivir', () async {
    final juego = await cargarControlador();

    juego.comprarPro();
    expect(juego.esPro, isTrue);
    expect(juego.jugador.diamantes, GameRules.diamantesIniciales + GameRules.diamantesMensualesPro);
    expect(juego.costoRevivir, GameRules.costoRevivirPro);
  });

  test('Un PRO que vuelve después de dos meses recibe los dos regalos', () async {
    final haceDosMeses = DateTime.now().subtract(GameRules.periodoRegaloPro * 2).millisecondsSinceEpoch;
    SharedPreferences.setMockInitialValues({
      '@game_player_state': jsonEncode(PlayerState.inicial()
          .copiarCon(tipoCuenta: AccountType.pro, ultimoRegaloPro: haceDosMeses)
          .aJson()),
    });

    final juego = GameController();
    final regalo = await juego.cargar();
    expect(regalo, 2 * GameRules.diamantesMensualesPro);
    expect(juego.jugador.diamantes, GameRules.diamantesIniciales + regalo);
  });

  test('El modo oscuro se guarda y se recuerda al volver a abrir la app', () async {
    final juego = await cargarControlador();
    juego.alternarTema();
    expect(juego.modoOscuro, isTrue);

    // "Reabrir la app": un controlador nuevo leyendo el mismo almacenamiento
    final reabierto = GameController();
    await reabierto.cargar();
    expect(reabierto.modoOscuro, isTrue);
  });

  test('Lee partidas guardadas por versiones anteriores (accountType como texto)', () async {
    final juego = await cargarControlador({'username': 'Viejo', 'accountType': 'pro', 'diamonds': 7});

    expect(juego.esPro, isTrue);
    expect(juego.jugador.nombreUsuario, 'Viejo');
  });
}
