import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geometry_dash_game/controllers/game_controller.dart';
import 'package:geometry_dash_game/core/game_rules.dart';
import 'package:geometry_dash_game/models/game_state.dart';
import 'package:geometry_dash_game/models/player_state.dart';

// Simula lo que hay guardado en el dispositivo (vacío = jugador nuevo)
Future<GameController> loadController([Map<String, dynamic>? saved]) async {
  SharedPreferences.setMockInitialValues(
    saved == null ? {} : {'@game_player_state': jsonEncode(saved)},
  );
  final controller = GameController();
  await controller.load();
  return controller;
}

void main() {
  test('Un jugador nuevo arranca en BASIC, modo claro y con los diamantes iniciales', () async {
    final game = await loadController();

    expect(game.isPro, isFalse);
    expect(game.isDarkMode, isFalse);
    expect(game.player.diamonds, GameRules.initialDiamonds);
    expect(game.gameState, GameState.idle);
  });

  test('Sumar puntos actualiza el récord, y una partida nueva lo conserva', () async {
    final game = await loadController();

    game.startGame();
    game.addScore();
    game.addScore();
    expect(game.player.score, 2 * GameRules.pointsPerObstacle);
    expect(game.player.highScore, 2 * GameRules.pointsPerObstacle);

    game.startGame();
    game.addScore();
    expect(game.player.score, GameRules.pointsPerObstacle);
    expect(game.player.highScore, 2 * GameRules.pointsPerObstacle); // No baja
  });

  test('Se revive una sola vez por partida y cuesta diamantes', () async {
    final game = await loadController();
    game.startGame();

    expect(game.hit(), isTrue); // Primer choque: se ofrece revivir
    expect(game.gameState, GameState.paused);

    game.revive();
    expect(game.player.diamonds, GameRules.initialDiamonds - GameRules.reviveCostBasic);

    game.resume();
    expect(game.hit(), isFalse); // Segundo choque: se termina
    expect(game.gameState, GameState.gameOver);
  });

  test('Sin diamantes suficientes no se puede revivir', () async {
    final game = await loadController(PlayerState.initial().copyWith(diamonds: 3).toJson());
    game.startGame();
    game.hit();

    game.revive();
    expect(game.player.diamonds, 3);
    expect(game.reviveCount, 0);
  });

  test('Comprar PRO regala diamantes y abarata el revivir', () async {
    final game = await loadController();

    game.buyPro();
    expect(game.isPro, isTrue);
    expect(game.player.diamonds, GameRules.initialDiamonds + GameRules.proMonthlyDiamonds);
    expect(game.reviveCost, GameRules.reviveCostPro);
  });

  test('Un PRO que vuelve después de dos meses recibe los dos regalos', () async {
    final twoMonthsAgo = DateTime.now().subtract(GameRules.proGiftPeriod * 2).millisecondsSinceEpoch;
    SharedPreferences.setMockInitialValues({
      '@game_player_state': jsonEncode(PlayerState.initial()
          .copyWith(accountType: AccountType.pro, lastProGiftAt: twoMonthsAgo)
          .toJson()),
    });

    final game = GameController();
    final gift = await game.load();
    expect(gift, 2 * GameRules.proMonthlyDiamonds);
    expect(game.player.diamonds, GameRules.initialDiamonds + gift);
  });

  test('El modo oscuro se guarda y se recuerda al volver a abrir la app', () async {
    final game = await loadController();
    game.toggleTheme();
    expect(game.isDarkMode, isTrue);

    // "Reabrir la app": un controller nuevo leyendo el mismo almacenamiento
    final reopened = GameController();
    await reopened.load();
    expect(reopened.isDarkMode, isTrue);
  });

  test('Lee partidas guardadas por versiones anteriores (accountType como texto)', () async {
    final game = await loadController({'username': 'Viejo', 'accountType': 'pro', 'diamonds': 7});

    expect(game.isPro, isTrue);
    expect(game.player.username, 'Viejo');
  });
}
