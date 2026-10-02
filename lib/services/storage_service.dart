import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PlayerState {
  final String username;
  final int score;
  final int highScore;
  final String accountType; // 'basic' | 'pro'
  final int diamonds;
  final bool isDarkMode;
  final int? lastProGiftAt; // Última entrega de diamantes mensuales PRO (ms desde epoch)

  PlayerState({
    required this.username,
    required this.score,
    required this.highScore,
    required this.accountType,
    required this.diamonds,
    required this.isDarkMode,
    this.lastProGiftAt,
  });

  // Estado inicial por defecto (simulación de usuario logueado)
  factory PlayerState.initial() {
    return PlayerState(
      username: 'SuperJugador',
      score: 0,
      highScore: 0,
      accountType: 'basic',
      diamonds: 50,
      isDarkMode: false,
    );
  }

  // Convertir objeto a Map para guardar como JSON
  Map<String, dynamic> toJson() => {
        'username': username,
        'score': score,
        'highScore': highScore,
        'accountType': accountType,
        'diamonds': diamonds,
        'isDarkMode': isDarkMode,
        'lastProGiftAt': lastProGiftAt,
      };

  // Crear objeto desde un Map traído de JSON
  factory PlayerState.fromJson(Map<String, dynamic> json) {
    return PlayerState(
      username: json['username'] ?? 'SuperJugador',
      score: json['score'] ?? 0,
      highScore: json['highScore'] ?? 0,
      accountType: json['accountType'] ?? 'basic',
      diamonds: json['diamonds'] ?? 50,
      isDarkMode: json['isDarkMode'] ?? false,
      lastProGiftAt: json['lastProGiftAt'],
    );
  }

  // Copia con cambios de estado (patrón inmutable)
  PlayerState copyWith({
    String? username,
    int? score,
    int? highScore,
    String? accountType,
    int? diamonds,
    bool? isDarkMode,
    int? lastProGiftAt,
  }) {
    return PlayerState(
      username: username ?? this.username,
      score: score ?? this.score,
      highScore: highScore ?? this.highScore,
      accountType: accountType ?? this.accountType,
      diamonds: diamonds ?? this.diamonds,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      lastProGiftAt: lastProGiftAt ?? this.lastProGiftAt,
    );
  }
}

class StorageService {
  static const String _key = '@game_player_state';

  static Future<void> savePlayerState(PlayerState state) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(state.toJson());
    await prefs.setString(_key, jsonString);
  }

  static Future<PlayerState> getPlayerState() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString != null) {
      return PlayerState.fromJson(jsonDecode(jsonString));
    }
    return PlayerState.initial();
  }
}