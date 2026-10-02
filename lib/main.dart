// lib/main.dart
import 'package:flutter/material.dart';
import 'controllers/game_controller.dart';
import 'core/theme.dart';
import 'screens/game_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Un único controller para toda la app: lo crea y lo libera este widget
  final GameController _controller = GameController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Se redibuja cuando el controller avisa: así el tema siempre sigue a lo guardado
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) => MaterialApp(
        title: 'Geometry Dash Game',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: _controller.isDarkMode ? ThemeMode.dark : ThemeMode.light,
        home: GameScreen(controller: _controller),
      ),
    );
  }
}
