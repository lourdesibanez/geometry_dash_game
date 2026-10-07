import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/player_state.dart';

//Guarda y lee el jugador en el celular (shared_preferences). Por esto funciona offline.
class StorageService {
  static const String _clave = '@game_player_state';

  static Future<void> guardarEstadoJugador(PlayerState estado) async {
    final preferencias = await SharedPreferences.getInstance();
    final textoJson = jsonEncode(estado.aJson());
    await preferencias.setString(_clave, textoJson);
  }

  static Future<PlayerState> cargarEstadoJugador() async {
    final preferencias = await SharedPreferences.getInstance();
    final textoJson = preferencias.getString(_clave);
    if (textoJson != null) {
      return PlayerState.desdeJson(jsonDecode(textoJson));
    }
    return PlayerState.inicial();
  }
}
