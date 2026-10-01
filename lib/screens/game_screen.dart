// lib/screens/game_screen.dart
import 'package:flutter/material.dart';
import '../components/organisms/header.dart';
import '../components/organisms/control_panel.dart';
import '../services/storage_service.dart';

class GameScreen extends StatefulWidget {
  final Function(bool) onToggleTheme;

  const GameScreen({super.key, required this.onToggleTheme});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  PlayerState _playerState = PlayerState.initial();
  GameState _gameState = GameState.idle;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final state = await StorageService.getPlayerState();
    setState(() {
      _playerState = state;
    });
  }

  Future<void> _updateState(PlayerState newState) async {
    setState(() {
      _playerState = newState;
    });
    await StorageService.savePlayerState(newState);
  }

  void _handleStart() {
    setState(() => _gameState = GameState.playing);
  }

  void _handlePause() {
    setState(() => _gameState = GameState.paused);
  }

  void _handleResume() {
    setState(() => _gameState = GameState.playing);
  }

  void _handleRestart() {
    setState(() => _gameState = GameState.playing);
  }

  void _handleNewGame() {
    _updateState(_playerState.copyWith(score: 0));
    setState(() => _gameState = GameState.playing);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Organismo Header
          Header(
            playerState: _playerState,
            onToggleTheme: () {
              final newDarkMode = !_playerState.isDarkMode;
              _updateState(_playerState.copyWith(isDarkMode: newDarkMode));
              widget.onToggleTheme(newDarkMode);
            },
          ),

          // Área de Lienzo / Juego (Placeholder temporal)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'ESTADO DEL JUEGO: ${_gameState.name.toUpperCase()}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Simular ganar 10 pts'),
                    onPressed: _gameState == GameState.playing
                        ? () {
                            _updateState(_playerState.copyWith(
                              score: _playerState.score + 10,
                            ));
                          }
                        : null,
                  ),
                ],
              ),
            ),
          ),

          // Organismo Control Panel
          ControlPanel(
            gameState: _gameState,
            onStart: _handleStart,
            onPause: _handlePause,
            onResume: _handleResume,
            onRestart: _handleRestart,
            onNewGame: _handleNewGame,
          ),
        ],
      ),
    );
  }
}