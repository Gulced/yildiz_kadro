import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yildiz_kadro/app/localization/locale_controller.dart';
import 'package:yildiz_kadro/app/localization/locale_scope.dart';
import 'package:yildiz_kadro/features/contestants/data/contestant_seed_data.dart';
import 'package:yildiz_kadro/features/contestants/presentation/contestant_detail_screen.dart';
import 'package:yildiz_kadro/features/game/application/game_scope.dart';
import 'package:yildiz_kadro/features/game/application/game_state.dart';
import 'package:yildiz_kadro/features/producer/data/story_event_engine.dart';
import 'package:yildiz_kadro/l10n/app_localizations.dart';

Widget _app({
  required LocaleController localeController,
  required GameState gameState,
  required Widget home,
}) {
  return LocaleScope(
    controller: localeController,
    child: ListenableBuilder(
      listenable: localeController,
      builder: (context, _) => GameScope(
        gameState: gameState,
        child: MaterialApp(
          locale: localeController.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: home,
        ),
      ),
    ),
  );
}

void main() {
  testWidgets(
    'the same mounted Gülce profile changes every dossier field TR to EN',
    (tester) async {
      final controller = LocaleController.withPersistence(
        read: () async => 'tr',
        write: (_) async {},
      );
      await controller.restore();
      final state = GameState(seasonSeed: 91);
      addTearDown(controller.dispose);
      addTearDown(state.dispose);
      final gulce = contestantSeedData.singleWhere((value) => value.id == 1);

      await tester.pumpWidget(
        _app(
          localeController: controller,
          gameState: state,
          home: ContestantDetailScreen(contestant: gulce),
        ),
      );

      expect(find.text('Bilgisayar Mühendisliği öğrencisi'), findsOneWidget);
      expect(find.text('Gizli Cevher'.toUpperCase()), findsOneWidget);
      expect(find.text('Hızlı Öğrenen'.toUpperCase()), findsOneWidget);
      expect(
        find.textContaining('Gülce teknolojiyle iç içe büyüdü'),
        findsOneWidget,
      );

      await controller.select(const Locale('en'));
      await tester.pumpAndSettle();

      expect(find.text('Computer Engineering student'), findsOneWidget);
      expect(find.text('HIDDEN GEM'), findsOneWidget);
      expect(find.text('FAST LEARNER'), findsOneWidget);
      expect(
        find.textContaining('Gülce grew up around technology'),
        findsOneWidget,
      );
      expect(find.text('Bilgisayar Mühendisliği öğrencisi'), findsNothing);
      expect(
        find.textContaining('Gülce teknolojiyle iç içe büyüdü'),
        findsNothing,
      );
      expect(state.seasonSeed, 91);
    },
  );

  testWidgets('story title body choice and result follow live locale', (
    tester,
  ) async {
    final controller = LocaleController.withPersistence(
      read: () async => 'tr',
      write: (_) async {},
    );
    await controller.restore();
    final state = GameState(seasonSeed: 101);
    addTearDown(controller.dispose);
    addTearDown(state.dispose);
    final event = createStoryEvent(
      seasonSeed: 101,
      day: 1,
      eligibleIds: const [1, 2, 3, 4, 5],
      seenEventIds: const {},
    );

    await tester.pumpWidget(
      _app(
        localeController: controller,
        gameState: state,
        home: Builder(
          builder: (context) => SingleChildScrollView(
            child: Column(
              children: [
                Text(event.localizedTitle(context)),
                Text(event.localizedBody(context)),
                Text(event.localizedWhy(context)),
                Text(event.choices.first.localizedLabel(context)),
                Text(event.choices.first.localizedFeedback(context)),
                Text(event.localizedConfessional(context) ?? ''),
              ],
            ),
          ),
        ),
      ),
    );
    expect(find.text(event.title), findsOneWidget);
    expect(find.text(event.body), findsOneWidget);

    await controller.select(const Locale('en'));
    await tester.pump();
    expect(find.text(event.titleEn!), findsOneWidget);
    expect(find.text(event.bodyEn!), findsOneWidget);
    expect(find.text(event.choices.first.labelEn!), findsOneWidget);
    expect(find.text(event.choices.first.feedbackEn!), findsOneWidget);
    expect(find.text(event.title), findsNothing);
    expect(state.seasonSeed, 101);
  });

  testWidgets('persistence plugin failure does not block live locale changes', (
    tester,
  ) async {
    final errors = <FlutterErrorDetails>[];
    final previousHandler = FlutterError.onError;
    FlutterError.onError = errors.add;
    addTearDown(() => FlutterError.onError = previousHandler);
    final controller = LocaleController.withPersistence(
      read: () async => throw MissingPluginException('shared_preferences'),
      write: (_) async => throw MissingPluginException('shared_preferences'),
    );
    addTearDown(controller.dispose);

    await controller.restore();
    await controller.select(const Locale('en'));

    expect(controller.locale, const Locale('en'));
    expect(controller.lastPersistenceError, isA<MissingPluginException>());
    expect(errors, hasLength(2));
  });
}
