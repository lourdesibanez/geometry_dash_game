import 'package:flame_audio/flame_audio.dart';

// El juego solo pide "salto", "diamante", "choque": acá se decide si suena o está silenciado.
class AudioService {
  static const String _musica = 'background.mp3';
  static const String _salto = 'jump.mp3';
  static const String _diamante = 'diamond.mp3';
  static const String _choque = 'game_over.mp3';

  // La música va más baja que los efectos para no taparlos
  static const double _volumenMusica = 0.35;
  static const double _volumenEfectos = 1.0;

  static bool silenciado = false;
  static bool _musicaEmpezada = false; // false = la próxima vez arranca desde el principio

  // Reproductores ya armados y reutilizables (null hasta que terminan de cargar).
  // Crear uno nuevo en cada salto trababa el celular y el sonido salía tarde.
  static AudioPool? _poolSalto;
  static AudioPool? _poolDiamante;
  static AudioPool? _poolChoque;

  // Se carga todo al abrir la app: así ningún efecto se arma en medio de la partida
  static Future<void> precargar() async {
    FlameAudio.bgm.initialize(); // Pausa la música si la app pasa a segundo plano
    await FlameAudio.audioCache.load(_musica);
    // maxPlayers: cuántas veces puede sonar a la vez (saltos seguidos se pisan)
    _poolSalto = await FlameAudio.createPool(_salto, minPlayers: 2, maxPlayers: 3);
    _poolDiamante = await FlameAudio.createPool(_diamante, minPlayers: 1, maxPlayers: 2);
    _poolChoque = await FlameAudio.createPool(_choque, minPlayers: 1, maxPlayers: 1);
  }

  static void salto() => _efecto(_poolSalto);
  static void diamante() => _efecto(_poolDiamante);
  static void choque() => _efecto(_poolChoque);

  static void _efecto(AudioPool? pool) {
    if (!silenciado) pool?.start(volume: _volumenEfectos);
  }

  // Música según la partida: suena jugando, se pausa en pausa y vuelve a empezar en una partida nueva.
  // Se llama en cada cambio del controlador, por eso solo actúa si algo cambió.
  static void sincronizarMusica({required bool jugando, required bool enPausa}) {
    final debeSonar = jugando && !silenciado;
    if (debeSonar && !FlameAudio.bgm.isPlaying) {
      if (_musicaEmpezada) {
        FlameAudio.bgm.resume();
      } else {
        FlameAudio.bgm.play(_musica, volume: _volumenMusica);
        _musicaEmpezada = true;
      }
    } else if (!debeSonar && FlameAudio.bgm.isPlaying) {
      FlameAudio.bgm.pause();
    }
    // Fuera de una partida (inicio o game over): la próxima arranca desde el principio
    if (!jugando && !enPausa && _musicaEmpezada) {
      FlameAudio.bgm.stop();
      _musicaEmpezada = false;
    }
  }
}
