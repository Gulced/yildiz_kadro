import 'package:flutter/material.dart';
import 'package:yildiz_kadro/app/theme/app_theme.dart';
import 'package:yildiz_kadro/app/navigation/game_navigation_observer.dart';
import 'package:yildiz_kadro/features/game/application/game_scope.dart';
import 'package:yildiz_kadro/features/game/application/game_state.dart';
import 'package:yildiz_kadro/features/home/presentation/home_screen.dart';
import 'package:yildiz_kadro/shared/widgets/global_gameplay_shell.dart';

class YildizKadroApp extends StatefulWidget {
  const YildizKadroApp({super.key});

  @override
  State<YildizKadroApp> createState() => _YildizKadroAppState();
}

class _YildizKadroAppState extends State<YildizKadroApp> {
  final GameState _gameState = GameState();
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  final GameNavigationObserver _navigationObserver = GameNavigationObserver();

  @override
  void dispose() {
    _gameState.dispose();
    _navigationObserver.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GameScope(
      gameState: _gameState,
      child: MaterialApp(
        navigatorKey: _navigatorKey,
        navigatorObservers: [_navigationObserver],
        title: 'Yıldız Kadro',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const HomeScreen(),
        builder: (context, child) => GlobalGameplayShell(
          navigatorKey: _navigatorKey,
          observer: _navigationObserver,
          child: child ?? const SizedBox.shrink(),
        ),
      ),
    );
  }
}
