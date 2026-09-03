import 'package:flutter/material.dart';
import 'package:yildiz_kadro/app/theme/app_theme.dart';
import 'package:yildiz_kadro/app/navigation/game_navigation_observer.dart';
import 'package:yildiz_kadro/app/localization/locale_controller.dart';
import 'package:yildiz_kadro/app/localization/locale_scope.dart';
import 'package:yildiz_kadro/features/game/application/game_scope.dart';
import 'package:yildiz_kadro/features/game/application/game_state.dart';
import 'package:yildiz_kadro/features/home/presentation/home_screen.dart';
import 'package:yildiz_kadro/shared/widgets/global_gameplay_shell.dart';
import 'package:yildiz_kadro/l10n/app_localizations.dart';

class YildizKadroApp extends StatefulWidget {
  const YildizKadroApp({super.key, this.localeController});

  final LocaleController? localeController;

  @override
  State<YildizKadroApp> createState() => _YildizKadroAppState();
}

class _YildizKadroAppState extends State<YildizKadroApp> {
  final GameState _gameState = GameState();
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  final GameNavigationObserver _navigationObserver = GameNavigationObserver();
  late final LocaleController _localeController;

  @override
  void initState() {
    super.initState();
    _localeController = widget.localeController ?? LocaleController();
    if (widget.localeController == null) {
      _localeController.restore();
    }
  }

  @override
  void dispose() {
    _gameState.dispose();
    _navigationObserver.dispose();
    if (widget.localeController == null) _localeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LocaleScope(
      controller: _localeController,
      child: ListenableBuilder(
        listenable: _localeController,
        builder: (context, _) => GameScope(
          gameState: _gameState,
          child: MaterialApp(
            navigatorKey: _navigatorKey,
            navigatorObservers: [_navigationObserver],
            onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.dark,
            locale: _localeController.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            localeResolutionCallback: (locale, supportedLocales) {
              if (locale?.languageCode == 'tr') return const Locale('tr');
              return const Locale('en');
            },
            home: const HomeScreen(),
            builder: (context, child) => GlobalGameplayShell(
              navigatorKey: _navigatorKey,
              observer: _navigationObserver,
              child: child ?? const SizedBox.shrink(),
            ),
          ),
        ),
      ),
    );
  }
}
