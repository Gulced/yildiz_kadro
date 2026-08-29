import 'package:flutter/material.dart';
import 'package:yildiz_kadro/app/navigation/game_navigation_observer.dart';
import 'package:yildiz_kadro/features/game/application/game_scope.dart';
import 'package:yildiz_kadro/features/producer/presentation/producer_dashboard_screen.dart';
import 'package:yildiz_kadro/shared/widgets/game_home_button.dart';

class GlobalGameplayShell extends StatelessWidget {
  const GlobalGameplayShell({
    required this.child,
    required this.navigatorKey,
    required this.observer,
    super.key,
  });

  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey;
  final GameNavigationObserver observer;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: Listenable.merge([GameScope.of(context), observer]),
        builder: (context, _) {
          final state = GameScope.of(context);
          final show = state.playerRadarContestantIds.isNotEmpty &&
              observer.canReturn &&
              !observer.isDashboard &&
              !observer.isPopup;
          return Stack(
            children: [
              child,
              if (show)
                PositionedDirectional(
                  top: MediaQuery.paddingOf(context).top + 6,
                  end: 10,
                  child: SafeArea(
                    top: false,
                    child: GameHomeButton(onPressed: _openDashboard),
                  ),
                ),
            ],
          );
        },
      );

  void _openDashboard() {
    final navigator = navigatorKey.currentState;
    if (navigator == null) return;
    navigator.push(
      MaterialPageRoute<void>(
        settings: const RouteSettings(
          name: GameNavigationObserver.dashboardRoute,
        ),
        builder: (_) => const ProducerDashboardScreen(),
      ),
    );
  }
}
