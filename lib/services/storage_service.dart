import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/player_state.dart';

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
