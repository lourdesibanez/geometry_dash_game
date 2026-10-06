import '../core/game_rules.dart';

enum AccountType { basic, pro }

class PlayerState {
  final String nombreUsuario;
  final int puntaje;
  final int record;
  final AccountType tipoCuenta;
  final int diamantes;
  final bool modoOscuro;
  final int? ultimoRegaloPro; // Última entrega de diamantes mensuales PRO (ms desde epoch)

  PlayerState({
    required this.nombreUsuario,
    required this.puntaje,
    required this.record,
    required this.tipoCuenta,
    required this.diamantes,
    required this.modoOscuro,
    this.ultimoRegaloPro,
  });

  bool get esPro => tipoCuenta == AccountType.pro;

  // Estado inicial por defecto (simulación de usuario logueado)
  factory PlayerState.inicial() {
    return PlayerState(
      nombreUsuario: 'SuperJugador',
      puntaje: 0,
      record: 0,
      tipoCuenta: AccountType.basic,
      diamantes: GameRules.diamantesIniciales,
      modoOscuro: false,
    );
  }

  // Convertir objeto a Map para guardar como JSON.
  // Las claves quedan en inglés para seguir leyendo las partidas ya guardadas
  Map<String, dynamic> aJson() => {
        'username': nombreUsuario,
        'score': puntaje,
        'highScore': record,
        'accountType': tipoCuenta.name, // Se guarda como 'basic' | 'pro'
        'diamonds': diamantes,
        'isDarkMode': modoOscuro,
        'lastProGiftAt': ultimoRegaloPro,
      };

  // Crear objeto desde un Map traído de JSON
  factory PlayerState.desdeJson(Map<String, dynamic> json) {
    return PlayerState(
      nombreUsuario: json['username'] ?? 'SuperJugador',
      puntaje: json['score'] ?? 0,
      record: json['highScore'] ?? 0,
      tipoCuenta: AccountType.values.asNameMap()[json['accountType']] ?? AccountType.basic,
      diamantes: json['diamonds'] ?? GameRules.diamantesIniciales,
      modoOscuro: json['isDarkMode'] ?? false,
      ultimoRegaloPro: json['lastProGiftAt'],
    );
  }

  // Copia con cambios de estado (patrón inmutable)
  PlayerState copiarCon({
    String? nombreUsuario,
    int? puntaje,
    int? record,
    AccountType? tipoCuenta,
    int? diamantes,
    bool? modoOscuro,
    int? ultimoRegaloPro,
  }) {
    return PlayerState(
      nombreUsuario: nombreUsuario ?? this.nombreUsuario,
      puntaje: puntaje ?? this.puntaje,
      record: record ?? this.record,
      tipoCuenta: tipoCuenta ?? this.tipoCuenta,
      diamantes: diamantes ?? this.diamantes,
      modoOscuro: modoOscuro ?? this.modoOscuro,
      ultimoRegaloPro: ultimoRegaloPro ?? this.ultimoRegaloPro,
    );
  }
}
