import 'package:flutter/material.dart';
import 'package:yildiz_kadro/app/theme/app_theme.dart';
import 'package:yildiz_kadro/features/game/application/game_scope.dart';
import 'package:yildiz_kadro/features/game/application/game_state.dart';
import 'package:yildiz_kadro/features/home/presentation/home_screen.dart';

class YildizKadroApp extends StatefulWidget {
  const YildizKadroApp({super.key});

  @override
  State<YildizKadroApp> createState() => _YildizKadroAppState();
}

class _YildizKadroAppState extends State<YildizKadroApp> {
  final GameState _gameState = GameState();

  @override
  void dispose() {
    _gameState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GameScope(
      gameState: _gameState,
      child: MaterialApp(
        title: 'Yıldız Kadro',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const HomeScreen(),
      ),
    );
  }
}
