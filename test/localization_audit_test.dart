import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yildiz_kadro/app/localization/locale_controller.dart';
import 'package:yildiz_kadro/features/contestants/data/contestant_identity_profiles.dart';
import 'package:yildiz_kadro/features/contestants/data/contestant_seed_data.dart';
import 'package:yildiz_kadro/features/contestants/domain/contestant_localization.dart';
import 'package:yildiz_kadro/features/evaluation/data/evaluation1_data.dart';
import 'package:yildiz_kadro/features/game/application/game_state.dart';
import 'package:yildiz_kadro/features/game/application/game_scope.dart';
import 'package:yildiz_kadro/features/group_task/data/day2_duel_engine.dart';
import 'package:yildiz_kadro/features/group_task/data/day3_final_cut_engine.dart';
import 'package:yildiz_kadro/features/group_task/data/day3_identity_engine.dart';
import 'package:yildiz_kadro/features/group_task/domain/day2_duel_result.dart';
import 'package:yildiz_kadro/features/group_task/domain/day3_final_cut_result.dart';
import 'package:yildiz_kadro/features/group_task/domain/day3_identity_setup.dart';
import 'package:yildiz_kadro/features/group_task/domain/day4_position_result.dart';
import 'package:yildiz_kadro/features/group_task/domain/day5_live_result.dart';
import 'package:yildiz_kadro/features/postgame/domain/final_group_customization.dart';
import 'package:yildiz_kadro/features/postgame/presentation/season_complete_hub_screen.dart';
import 'package:yildiz_kadro/features/producer/data/story_event_engine.dart';
import 'package:yildiz_kadro/l10n/app_localizations.dart';
import 'package:yildiz_kadro/l10n/app_localizations_en.dart';
import 'package:yildiz_kadro/l10n/app_localizations_tr.dart';

Widget localizedTestWrapper({
  required Widget child,
  Locale locale = const Locale('en'),
  GameState? gameState,
}) {
  return MaterialApp(
    locale: locale,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: gameState != null
        ? GameScope(gameState: gameState, child: child)
        : child,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Localization Audit - ARB & Infrastructure', () {
    test(
      'Both Turkish and English localizations are complete and non-empty',
      () {
        final tr = AppLocalizationsTr();
        final en = AppLocalizationsEn();

        expect(tr.appTitle, isNotEmpty);
        expect(en.appTitle, isNotEmpty);
        expect(tr.startSeason, isNotEmpty);
        expect(en.startSeason, isNotEmpty);
        expect(tr.howToPlay, isNotEmpty);
        expect(en.howToPlay, isNotEmpty);
        expect(tr.understood, isNotEmpty);
        expect(en.understood, isNotEmpty);

        // Verify distinct translations
        expect(tr.startSeason, isNot(equals(en.startSeason)));
        expect(tr.howToPlay, isNot(equals(en.howToPlay)));
      },
    );

    test('LocaleController switches and persists locale cleanly', () async {
      SharedPreferences.setMockInitialValues({'selectedLanguage': 'tr'});
      final prefs = await SharedPreferences.getInstance();
      final controller = LocaleController.withPreferences(prefs);
      await controller.restore();

      expect(controller.locale?.languageCode, 'tr');

      await controller.select(const Locale('en'));
      expect(controller.locale?.languageCode, 'en');
      expect(prefs.getString('selectedLanguage'), 'en');

      await controller.select(const Locale('tr'));
      expect(controller.locale?.languageCode, 'tr');
      expect(prefs.getString('selectedLanguage'), 'tr');

      controller.dispose();
    });
  });

  group('Localization Audit - Story Event System', () {
    test('Story event catalog template count is complete', () {
      expect(storyEventTemplateCount, equals(42));
    });

    testWidgets('StoryEvent getter methods respect BuildContext locale', (
      tester,
    ) async {
      final sampleEvent = createStoryEvent(
        seasonSeed: 101,
        day: 1,
        eligibleIds: [1, 2, 3, 4, 5],
        seenEventIds: const {},
      );

      await tester.pumpWidget(
        localizedTestWrapper(
          locale: const Locale('en'),
          child: Builder(
            builder: (context) {
              expect(
                sampleEvent.localizedTitle(context),
                equals(sampleEvent.titleEn),
              );
              expect(
                sampleEvent.localizedBody(context),
                equals(sampleEvent.bodyEn),
              );
              expect(
                sampleEvent.localizedWhy(context),
                equals(sampleEvent.whyEn),
              );
              expect(
                sampleEvent.choices.first.localizedLabel(context),
                equals(sampleEvent.choices.first.labelEn),
              );
              expect(
                sampleEvent.choices.first.localizedFeedback(context),
                equals(sampleEvent.choices.first.feedbackEn),
              );
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      await tester.pumpWidget(
        localizedTestWrapper(
          locale: const Locale('tr'),
          child: Builder(
            builder: (context) {
              expect(
                sampleEvent.localizedTitle(context),
                equals(sampleEvent.title),
              );
              expect(
                sampleEvent.localizedBody(context),
                equals(sampleEvent.body),
              );
              expect(
                sampleEvent.localizedWhy(context),
                equals(sampleEvent.why),
              );
              expect(
                sampleEvent.choices.first.localizedLabel(context),
                equals(sampleEvent.choices.first.label),
              );
              expect(
                sampleEvent.choices.first.localizedFeedback(context),
                equals(sampleEvent.choices.first.feedback),
              );
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });
  });

  group('Localization Audit - Contestant Identity & Dossiers', () {
    test('All 15 contestant names remain invariant between TR and EN', () {
      expect(contestantSeedData.length, equals(15));
      const expectedNames = [
        'Gülce',
        'Duru',
        'İdil',
        'Alara',
        'Derin',
        'Ada',
        'İpek',
        'Lara',
        'Nehir',
        'Lalin',
        'Arya',
        'Mina',
        'Zeynep Ela',
        'Serra',
        'Nil',
      ];
      final actualNames = contestantSeedData.map((c) => c.name).toList();
      expect(actualNames, equals(expectedNames));
    });

    testWidgets(
      'Contestant localized getters return English in EN and Turkish in TR',
      (tester) async {
        await tester.pumpWidget(
          localizedTestWrapper(
            locale: const Locale('en'),
            child: Builder(
              builder: (context) {
                for (final c in contestantSeedData) {
                  expect(
                    c.localizedOccupation(context),
                    isNot(equals(c.occupationOrEducation)),
                  );
                  expect(
                    c.localizedShortBackground(context),
                    isNot(equals(c.shortBackground)),
                  );
                  expect(c.localizedPrimaryRole(context), isNotEmpty);
                  expect(c.localizedSpecialTraitTitle(context), isNotEmpty);
                  expect(c.localizedRiskTitle(context), isNotEmpty);
                  expect(c.localizedQuote(context), isNotEmpty);
                  expect(localizedGoal(c, context), isNotEmpty);
                  expect(leadershipCommentFor(c, context), isNotEmpty);
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        );

        await tester.pumpWidget(
          localizedTestWrapper(
            locale: const Locale('tr'),
            child: Builder(
              builder: (context) {
                for (final c in contestantSeedData) {
                  expect(
                    c.localizedOccupation(context),
                    equals(c.occupationOrEducation),
                  );
                  expect(
                    c.localizedShortBackground(context),
                    equals(c.shortBackground),
                  );
                  expect(
                    c.localizedPrimaryRole(context),
                    equals(c.primaryRole),
                  );
                  expect(
                    c.localizedSpecialTraitTitle(context),
                    equals(c.specialTraitTitle),
                  );
                  expect(c.localizedRiskTitle(context), equals(c.riskTitle));
                  expect(c.localizedQuote(context), equals(c.quote));
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        );
      },
    );
  });

  group('Localization Audit - Game Logic & Simulation Invariance', () {
    test(
        'Game evaluation data, seeds, and ranking logic are bit-identical regardless of language',
        () {
      final stateTr = GameState(seasonSeed: 42);
      final stateEn = GameState(seasonSeed: 42);

      stateTr.savePlayerRadar([1, 2, 3, 4, 5]);
      stateEn.savePlayerRadar([1, 2, 3, 4, 5]);

      stateTr.completeEvaluation1(evaluation1Results);
      stateEn.completeEvaluation1(evaluation1Results);

      expect(
        stateTr.evaluation1Results.keys,
        equals(stateEn.evaluation1Results.keys),
      );
      for (final id in stateTr.evaluation1Results.keys) {
        expect(
          stateTr.evaluation1Results[id]!.overall,
          equals(stateEn.evaluation1Results[id]!.overall),
        );
      }

      stateTr.dispose();
      stateEn.dispose();
    });
  });

  group('Localization Audit - Helpers and Formatters', () {
    testWidgets(
      'Domain formatters produce correct English when context is EN',
      (tester) async {
        await tester.pumpWidget(
          localizedTestWrapper(
            locale: const Locale('en'),
            child: Builder(
              builder: (context) {
                expect(balanceLabel(95, context), equals('EXCELLENT'));
                expect(balanceLabel(85, context), equals('STRONG'));
                expect(balanceLabel(80, context), equals('BALANCED'));
                expect(balanceLabel(74, context), equals('VULNERABLE'));
                expect(balanceLabel(65, context), equals('DEVELOPING'));

                expect(
                  duelApproachLabel(Day2DuelApproach.clean, context),
                  equals('CLEAN EXECUTION'),
                );
                expect(
                  duelApproachLabel(Day2DuelApproach.starMoment, context),
                  equals('STAR MOMENT'),
                );

                expect(day3FitLabel(85, context), equals('NATURAL MATCH'));
                expect(
                  day3DirectionLabel(Day3CreativeDirection.surprise, context),
                  equals('SURPRISE TWIST'),
                );

                expect(
                  finalCutApproachLabel(
                    Day3FinalCutApproach.perfectFrame,
                    context,
                  ),
                  equals('PERFECT FRAME'),
                );

                expect(
                  day4ChoiceLabel(
                    Day4Room.vocal,
                    Day4MentorChoice.optionA,
                    context,
                  ),
                  equals('SING WITH PURITY'),
                );

                expect(
                  day5DirectionLabel(Day5BroadcastDirection.bigStage, context),
                  equals('BIG ARENA STAGE'),
                );

                expect(
                  memberColorLabel(MemberColor.pink, context),
                  equals('PINK'),
                );
                expect(
                  memberColorLabel(MemberColor.blue, context),
                  equals('BLUE'),
                );

                return const SizedBox.shrink();
              },
            ),
          ),
        );
      },
    );

    testWidgets(
      'Domain formatters produce correct Turkish when context is TR',
      (tester) async {
        await tester.pumpWidget(
          localizedTestWrapper(
            locale: const Locale('tr'),
            child: Builder(
              builder: (context) {
                expect(balanceLabel(95, context), equals('ÇOK GÜÇLÜ'));
                expect(balanceLabel(85, context), equals('GÜÇLÜ'));
                expect(balanceLabel(80, context), equals('DENGELİ'));
                expect(balanceLabel(74, context), equals('RİSKLİ'));
                expect(balanceLabel(65, context), equals('GELİŞİYOR'));

                expect(
                  duelApproachLabel(Day2DuelApproach.clean, context),
                  equals('TEMİZ PERFORMANS'),
                );
                expect(
                  duelApproachLabel(Day2DuelApproach.starMoment, context),
                  equals('YILDIZ ANI'),
                );

                expect(day3FitLabel(85, context), equals('DOĞAL EŞLEŞME'));
                expect(
                  day3DirectionLabel(Day3CreativeDirection.surprise, context),
                  equals('TERS KÖŞE YAP'),
                );

                expect(
                  finalCutApproachLabel(
                    Day3FinalCutApproach.perfectFrame,
                    context,
                  ),
                  equals('KUSURSUZ KARE'),
                );

                expect(
                  day4ChoiceLabel(
                    Day4Room.vocal,
                    Day4MentorChoice.optionA,
                    context,
                  ),
                  equals('TEMİZ SÖYLEYİN'),
                );

                expect(
                  day5DirectionLabel(Day5BroadcastDirection.bigStage, context),
                  equals('BÜYÜK SAHNE'),
                );

                expect(
                  memberColorLabel(MemberColor.pink, context),
                  equals('PEMBE'),
                );
                expect(
                  memberColorLabel(MemberColor.blue, context),
                  equals('MAVİ'),
                );

                return const SizedBox.shrink();
              },
            ),
          ),
        );
      },
    );
  });

  group('Localization Audit - Incomplete Hub & Screen Rendering', () {
    testWidgets(
      'SeasonCompleteHubScreen incomplete state renders in English with EN locale',
      (tester) async {
        final state = GameState(seasonSeed: 10);
        addTearDown(state.dispose);

        await tester.pumpWidget(
          localizedTestWrapper(
            locale: const Locale('en'),
            gameState: state,
            child: const SeasonCompleteHubScreen(),
          ),
        );

        expect(find.text('SEASON NOT YET COMPLETED'), findsOneWidget);
        expect(find.text('RETURN TO GAME'), findsOneWidget);
      },
    );

    testWidgets(
      'SeasonCompleteHubScreen incomplete state renders in Turkish with TR locale',
      (tester) async {
        final state = GameState(seasonSeed: 10);
        addTearDown(state.dispose);

        await tester.pumpWidget(
          localizedTestWrapper(
            locale: const Locale('tr'),
            gameState: state,
            child: const SeasonCompleteHubScreen(),
          ),
        );

        expect(find.text('SEZON HENÜZ TAMAMLANMADI'), findsOneWidget);
        expect(find.text('OYUNA DÖN'), findsOneWidget);
      },
    );
  });
}
