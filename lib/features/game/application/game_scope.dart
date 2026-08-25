import 'package:flutter/widgets.dart';
import 'package:yildiz_kadro/features/game/application/game_state.dart';

class GameScope extends InheritedNotifier<GameState> {
  const GameScope({
    required GameState gameState,
    required super.child,
    super.key,
  }) : super(notifier: gameState);

  static GameState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<GameScope>();
    assert(scope != null, 'GameScope bulunamadı.');
    return scope!.notifier!;
  }
}
