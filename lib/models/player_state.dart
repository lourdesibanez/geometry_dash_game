import '../core/game_rules.dart';

enum AccountType { basic, pro }

class PlayerState {
  final String username;
  final int score;
  final int highScore;
  final AccountType accountType;
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

  bool get isPro => accountType == AccountType.pro;

  // Estado inicial por defecto (simulación de usuario logueado)
  factory PlayerState.initial() {
    return PlayerState(
      username: 'SuperJugador',
      score: 0,
      highScore: 0,
      accountType: AccountType.basic,
      diamonds: GameRules.initialDiamonds,
      isDarkMode: false,
    );
  }

  // Convertir objeto a Map para guardar como JSON
  Map<String, dynamic> toJson() => {
        'username': username,
        'score': score,
        'highScore': highScore,
        'accountType': accountType.name, // Se guarda como 'basic' | 'pro'
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
      accountType: AccountType.values.asNameMap()[json['accountType']] ?? AccountType.basic,
      diamonds: json['diamonds'] ?? GameRules.initialDiamonds,
      isDarkMode: json['isDarkMode'] ?? false,
      lastProGiftAt: json['lastProGiftAt'],
    );
  }

  // Copia con cambios de estado (patrón inmutable)
  PlayerState copyWith({
    String? username,
    int? score,
    int? highScore,
    AccountType? accountType,
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
