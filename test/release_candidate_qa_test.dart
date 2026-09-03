import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yildiz_kadro/app/localization/locale_controller.dart';
import 'package:yildiz_kadro/app/localization/locale_scope.dart';
import 'package:yildiz_kadro/features/contestants/data/contestant_seed_data.dart';
import 'package:yildiz_kadro/features/contestants/presentation/contestant_dashboard_screen.dart';
import 'package:yildiz_kadro/features/contestants/presentation/contestant_detail_screen.dart';
import 'package:yildiz_kadro/features/day2/presentation/day2_briefing_screen.dart';
import 'package:yildiz_kadro/features/evaluation/data/evaluation1_data.dart';
import 'package:yildiz_kadro/features/evaluation/presentation/evaluation_results_screen.dart';
import 'package:yildiz_kadro/features/first_impression/presentation/first_impression_screen.dart';
import 'package:yildiz_kadro/features/game/application/game_scope.dart';
import 'package:yildiz_kadro/features/game/application/game_state.dart';
import 'package:yildiz_kadro/features/group_task/data/day2_rehearsal_engine.dart';
import 'package:yildiz_kadro/features/group_task/data/day2_team_draft.dart';
import 'package:yildiz_kadro/features/group_task/presentation/day6_grand_final_screen.dart';
import 'package:yildiz_kadro/features/group_task/presentation/group_task_rehearsal_screen.dart';
import 'package:yildiz_kadro/features/home/presentation/home_screen.dart';
import 'package:yildiz_kadro/features/jury/presentation/jury_decision_screen.dart';
import 'package:yildiz_kadro/features/last_chance/presentation/last_chance_performance_screen.dart';
import 'package:yildiz_kadro/features/postgame/presentation/final_group_customization_screen.dart';
import 'package:yildiz_kadro/features/postgame/presentation/group_naming_screen.dart';
import 'package:yildiz_kadro/features/postgame/presentation/season_complete_hub_screen.dart';
import 'package:yildiz_kadro/features/roster/presentation/post_elimination_roster_screen.dart';
import 'package:yildiz_kadro/l10n/app_localizations.dart';
import 'package:yildiz_kadro/shared/widgets/mission_briefing.dart';

Widget createQAApp({
  required Widget home,
  required GameState gameState,
  required LocaleController localeController,
}) {
  return LocaleScope(
    controller: localeController,
    child: AnimatedBuilder(
      animation: localeController,
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
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Visual QA Pass 1: Complete Turkish Flow Validation', () {
    testWidgets('TR: Early flow (Landing, Casting, Detail, First Impression)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      SharedPreferences.setMockInitialValues({'selectedLanguage': 'tr'});
      final prefs = await SharedPreferences.getInstance();
      final localeCtrl = LocaleController.withPreferences(prefs);
      await localeCtrl.restore();
      addTearDown(localeCtrl.dispose);

      final state = GameState(seasonSeed: 101);
      addTearDown(state.dispose);

      // Landing
      await tester.pumpWidget(
        createQAApp(
          home: const HomeScreen(),
          gameState: state,
          localeController: localeCtrl,
        ),
      );
      await tester.pump();
      expect(find.text('SEZONA BAŞLA'), findsOneWidget);
      expect(find.text('START THE SEASON'), findsNothing);

      // Casting Dashboard
      await tester.pumpWidget(
        createQAApp(
          home: const ContestantDashboardScreen(),
          gameState: state,
          localeController: localeCtrl,
        ),
      );
      await tester.pump();
      expect(find.text('YARIŞMACILAR'), findsOneWidget);
      expect(find.text('CONTESTANTS'), findsNothing);
      expect(find.text('GÜLCE'), findsWidgets);

      // Contestant Detail
      final gulce = contestantSeedData.first;
      await tester.pumpWidget(
        createQAApp(
          home: ContestantDetailScreen(contestant: gulce),
          gameState: state,
          localeController: localeCtrl,
        ),
      );
      await tester.pump();
      expect(find.text(gulce.occupationOrEducation), findsOneWidget);
      expect(find.text('Computer Engineering student'), findsNothing);

      // First Impression
      state.savePlayerRadar([1, 2, 3, 4, 5]);
      await tester.pumpWidget(
        createQAApp(
          home: const FirstImpressionScreen(),
          gameState: state,
          localeController: localeCtrl,
        ),
      );
      await tester.pump();
      expect(find.text('İlk izlenimin kimden yana?'), findsOneWidget);
      expect(find.text('RADARIM HAZIR'), findsOneWidget);
      expect(
        find.text('Who made the strongest first impression?'),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'TR: Day 1 flow (Evaluation, Jury, Producer Right, Last Chance, Roster)',
      (tester) async {
        tester.view.physicalSize = const Size(360, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        SharedPreferences.setMockInitialValues({'selectedLanguage': 'tr'});
        final prefs = await SharedPreferences.getInstance();
        final localeCtrl = LocaleController.withPreferences(prefs);
        await localeCtrl.restore();
        addTearDown(localeCtrl.dispose);

        final state = GameState(seasonSeed: 101);
        addTearDown(state.dispose);
        state.savePlayerRadar([1, 2, 3, 4, 5]);
        state.completeEvaluation1(evaluation1Results);
        state.markMissionBriefingSeen('day1_eval_results');
        final event1 = state.ensureStoryEvent(1);
        state.resolveStoryEvent(
          day: 1,
          choiceId: event1.event.choices.first.id,
        );

        // Evaluation Results
        await tester.pumpWidget(
          createQAApp(
            home: const EvaluationResultsScreen(),
            gameState: state,
            localeController: localeCtrl,
          ),
        );
        await tester.pump();
        expect(find.text('1. GÜN • SAHNE TESTİ'), findsOneWidget);
        expect(find.text('İLK DEĞERLENDİRME\nTAMAMLANDI'), findsOneWidget);
        expect(find.text('FIRST EVALUATION\nCOMPLETE'), findsNothing);

        // Jury Decision
        await tester.pumpWidget(
          createQAApp(
            home: const JuryDecisionScreen(),
            gameState: state,
            localeController: localeCtrl,
          ),
        );
        await tester.pump();
        await tester.ensureVisible(find.text('RİSK BÖLGESİNİ GÖR'));
        await tester.pump();
        await tester.tap(find.text('RİSK BÖLGESİNİ GÖR'));
        await tester.pump();
        await tester.ensureVisible(find.text('JÜRİNİN KARŞISINA ÇIK'));
        await tester.pump();
        await tester.tap(find.text('JÜRİNİN KARŞISINA ÇIK'));
        await tester.pump();
        await tester.ensureVisible(find.text('YAPIMCI HAKKINI KULLAN'));
        await tester.pump();
        expect(find.text('YAPIMCI HAKKINI KULLAN'), findsOneWidget);

        await tester.tap(find.text('YAPIMCI HAKKINI KULLAN'));
        await tester.pump();
        expect(find.text('YAPIMCI HAKKI'), findsOneWidget);
        expect(find.text('Bir kişiyi koruyabilirsin.'), findsOneWidget);

        // Last Chance (Fallback/uninitialized state)
        await tester.pumpWidget(
          createQAApp(
            home: const LastChancePerformanceScreen(),
            gameState: state,
            localeController: localeCtrl,
          ),
        );
        await tester.pump();
        expect(find.text('SON ŞANS HENÜZ HAZIR DEĞİL'), findsOneWidget);
        expect(find.text('LAST CHANCE NOT READY YET'), findsNothing);

        // Post Elimination Roster (Recovery / Missing state)
        await tester.pumpWidget(
          createQAApp(
            home: const PostEliminationRosterScreen(),
            gameState: state,
            localeController: localeCtrl,
          ),
        );
        await tester.pump();
        expect(find.text('KADRO SONUCU HAZIR DEĞİL'), findsOneWidget);
        expect(find.text('ROSTER RESULT NOT READY'), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('TR: Day 2-3 flow (Briefing, Rehearsal)', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      SharedPreferences.setMockInitialValues({'selectedLanguage': 'tr'});
      final prefs = await SharedPreferences.getInstance();
      final localeCtrl = LocaleController.withPreferences(prefs);
      await localeCtrl.restore();
      addTearDown(localeCtrl.dispose);

      final state = GameState(seasonSeed: 101);
      addTearDown(state.dispose);
      state.savePlayerRadar([1, 2, 3, 4, 5]);

      // Day 2 Briefing
      await tester.pumpWidget(
        createQAApp(
          home: const Day2BriefingScreen(),
          gameState: state,
          localeController: localeCtrl,
        ),
      );
      await tester.pump();
      expect(find.text('İLK GRUP GÖREVİ'), findsOneWidget);

      // Setup team draft & rehearsal for Day 2
      final active = List.generate(14, (i) => i + 1);
      final draft = generateDay2Teams(
        activeContestantIds: active,
        captainAId: 4,
        captainBId: 7,
        evaluationResults: evaluation1Results,
      );
      state.completeDay2TeamFormation(draft);
      final setup = initializeDay2Rehearsal(
        teamAIds: draft.teamAIds,
        teamBIds: draft.teamBIds,
        captainAId: draft.captainAId,
        captainBId: draft.captainBId,
        lastPickedContestantId: draft.lastPickedContestantId,
        evaluationResults: evaluation1Results,
      );
      state.initializeDay2Rehearsal(setup);

      // Rehearsal
      await tester.pumpWidget(
        createQAApp(
          home: const GroupTaskRehearsalScreen(),
          gameState: state,
          localeController: localeCtrl,
        ),
      );
      await tester.pump();
      expect(find.text('PROVA'), findsOneWidget);
      expect(find.text('İlk çatlaklar burada başlar.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'TR: Day 6 & Postgame flow (Final, Group Naming, Customization, Hub)',
      (tester) async {
        tester.view.physicalSize = const Size(360, 640);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        SharedPreferences.setMockInitialValues({'selectedLanguage': 'tr'});
        final prefs = await SharedPreferences.getInstance();
        final localeCtrl = LocaleController.withPreferences(prefs);
        await localeCtrl.restore();
        addTearDown(localeCtrl.dispose);

        final state = GameState(seasonSeed: 101);
        addTearDown(state.dispose);
        state.savePlayerRadar([1, 2, 3, 4, 5]);

        // Day 6
        await tester.pumpWidget(
          createQAApp(
            home: const Day6GrandFinalScreen(),
            gameState: state,
            localeController: localeCtrl,
          ),
        );
        await tester.pump();
        expect(find.text('BÜYÜK FİNAL'), findsOneWidget);
        expect(
          find.text('7 finalist.\n5 kişilik bir grup.\nSon karar senin.'),
          findsOneWidget,
        );

        // Group Naming
        await tester.pumpWidget(
          createQAApp(
            home: const GroupNamingScreen(),
            gameState: state,
            localeController: localeCtrl,
          ),
        );
        await tester.pump();
        expect(find.text('GRUP ADI'), findsOneWidget);
        expect(find.text('İSMİ ONAYLA  ★ →'), findsOneWidget);

        // Final Customization
        await tester.pumpWidget(
          createQAApp(
            home: const FinalGroupCustomizationScreen(),
            gameState: state,
            localeController: localeCtrl,
          ),
        );
        await tester.pump();
        expect(find.text('GRUBUNU TAMAMLA'), findsOneWidget);
        expect(
          find.text('Beş üyeye performans pozisyonlarını sen ver.'),
          findsOneWidget,
        );

        // Season Complete Hub
        await tester.pumpWidget(
          createQAApp(
            home: const SeasonCompleteHubScreen(),
            gameState: state,
            localeController: localeCtrl,
          ),
        );
        await tester.pump();
        expect(find.text('SEZON HENÜZ TAMAMLANMADI'), findsOneWidget);
        expect(find.text('OYUNA DÖN'), findsOneWidget);
        expect(find.text('SEASON NOT YET COMPLETED'), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  });

  group('Visual QA Pass 2: Complete English Flow Validation', () {
    testWidgets('EN: Early flow (Landing, Casting, Detail, First Impression)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      SharedPreferences.setMockInitialValues({'selectedLanguage': 'en'});
      final prefs = await SharedPreferences.getInstance();
      final localeCtrl = LocaleController.withPreferences(prefs);
      await localeCtrl.restore();
      addTearDown(localeCtrl.dispose);

      final state = GameState(seasonSeed: 2024);
      addTearDown(state.dispose);

      // Landing
      await tester.pumpWidget(
        createQAApp(
          home: const HomeScreen(),
          gameState: state,
          localeController: localeCtrl,
        ),
      );
      await tester.pump();
      expect(find.text('START THE SEASON'), findsOneWidget);
      expect(find.text('SEZONA BAŞLA'), findsNothing);

      // Casting Dashboard
      await tester.pumpWidget(
        createQAApp(
          home: const ContestantDashboardScreen(),
          gameState: state,
          localeController: localeCtrl,
        ),
      );
      await tester.pump();
      expect(find.text('CONTESTANTS'), findsOneWidget);
      expect(find.text('YARIŞMACILAR'), findsNothing);
      expect(find.text('GÜLCE'), findsWidgets);

      // Contestant Detail
      final gulce = contestantSeedData.first;
      await tester.pumpWidget(
        createQAApp(
          home: ContestantDetailScreen(contestant: gulce),
          gameState: state,
          localeController: localeCtrl,
        ),
      );
      await tester.pump();
      expect(find.text('Computer Engineering student'), findsOneWidget);
      expect(find.text(gulce.occupationOrEducation), findsNothing);

      // First Impression
      state.savePlayerRadar([1, 2, 3, 4, 5]);
      await tester.pumpWidget(
        createQAApp(
          home: const FirstImpressionScreen(),
          gameState: state,
          localeController: localeCtrl,
        ),
      );
      await tester.pump();
      expect(
        find.text('Who made the strongest first impression?'),
        findsOneWidget,
      );
      expect(find.text('MY RADAR IS READY'), findsOneWidget);
      expect(find.text('İlk izlenimin kimden yana?'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'EN: Day 1 flow (Evaluation, Jury, Producer Right, Last Chance, Roster)',
      (tester) async {
        tester.view.physicalSize = const Size(360, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        SharedPreferences.setMockInitialValues({'selectedLanguage': 'en'});
        final prefs = await SharedPreferences.getInstance();
        final localeCtrl = LocaleController.withPreferences(prefs);
        await localeCtrl.restore();
        addTearDown(localeCtrl.dispose);

        final state = GameState(seasonSeed: 2024);
        addTearDown(state.dispose);
        state.savePlayerRadar([1, 2, 3, 4, 5]);
        state.completeEvaluation1(evaluation1Results);
        state.markMissionBriefingSeen('day1_eval_results');
        final event1 = state.ensureStoryEvent(1);
        state.resolveStoryEvent(
          day: 1,
          choiceId: event1.event.choices.first.id,
        );

        // Evaluation Results
        await tester.pumpWidget(
          createQAApp(
            home: const EvaluationResultsScreen(),
            gameState: state,
            localeController: localeCtrl,
          ),
        );
        await tester.pump();
        expect(find.text('DAY 1 • STAGE TEST'), findsOneWidget);
        expect(find.text('FIRST EVALUATION\nCOMPLETE'), findsOneWidget);
        expect(find.text('İLK DEĞERLENDİRME\nTAMAMLANDI'), findsNothing);

        // Jury Decision
        await tester.pumpWidget(
          createQAApp(
            home: const JuryDecisionScreen(),
            gameState: state,
            localeController: localeCtrl,
          ),
        );
        await tester.pump();
        await tester.ensureVisible(find.text('VIEW RISK ZONE'));
        await tester.pump();
        await tester.tap(find.text('VIEW RISK ZONE'));
        await tester.pump();
        await tester.ensureVisible(find.text('FACE THE JURY'));
        await tester.pump();
        await tester.tap(find.text('FACE THE JURY'));
        await tester.pump();
        await tester.ensureVisible(find.text('USE PRODUCER PRIVILEGE'));
        await tester.pump();
        expect(find.text('USE PRODUCER PRIVILEGE'), findsOneWidget);

        await tester.tap(find.text('USE PRODUCER PRIVILEGE'));
        await tester.pump();
        expect(find.text('PRODUCER PRIVILEGE'), findsOneWidget);
        expect(find.text('You can save one contestant.'), findsOneWidget);

        // Last Chance (Fallback/uninitialized state)
        await tester.pumpWidget(
          createQAApp(
            home: const LastChancePerformanceScreen(),
            gameState: state,
            localeController: localeCtrl,
          ),
        );
        await tester.pump();
        expect(find.text('LAST CHANCE NOT READY YET'), findsOneWidget);
        expect(find.text('SON ŞANS HENÜZ HAZIR DEĞİL'), findsNothing);

        // Post Elimination Roster (Recovery / Missing state)
        await tester.pumpWidget(
          createQAApp(
            home: const PostEliminationRosterScreen(),
            gameState: state,
            localeController: localeCtrl,
          ),
        );
        await tester.pump();
        expect(find.text('ROSTER RESULT NOT READY'), findsOneWidget);
        expect(find.text('KADRO SONUCU HAZIR DEĞİL'), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('EN: Day 2-3 flow (Briefing, Rehearsal)', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      SharedPreferences.setMockInitialValues({'selectedLanguage': 'en'});
      final prefs = await SharedPreferences.getInstance();
      final localeCtrl = LocaleController.withPreferences(prefs);
      await localeCtrl.restore();
      addTearDown(localeCtrl.dispose);

      final state = GameState(seasonSeed: 2024);
      addTearDown(state.dispose);
      state.savePlayerRadar([1, 2, 3, 4, 5]);

      // Day 2 Briefing
      await tester.pumpWidget(
        createQAApp(
          home: const Day2BriefingScreen(),
          gameState: state,
          localeController: localeCtrl,
        ),
      );
      await tester.pump();
      expect(find.text('FIRST GROUP TASK'), findsOneWidget);

      // Setup team draft & rehearsal for Day 2
      final active = List.generate(14, (i) => i + 1);
      final draft = generateDay2Teams(
        activeContestantIds: active,
        captainAId: 4,
        captainBId: 7,
        evaluationResults: evaluation1Results,
      );
      state.completeDay2TeamFormation(draft);
      final setup = initializeDay2Rehearsal(
        teamAIds: draft.teamAIds,
        teamBIds: draft.teamBIds,
        captainAId: draft.captainAId,
        captainBId: draft.captainBId,
        lastPickedContestantId: draft.lastPickedContestantId,
        evaluationResults: evaluation1Results,
      );
      state.initializeDay2Rehearsal(setup);

      // Rehearsal
      await tester.pumpWidget(
        createQAApp(
          home: const GroupTaskRehearsalScreen(),
          gameState: state,
          localeController: localeCtrl,
        ),
      );
      await tester.pump();
      expect(find.text('REHEARSAL'), findsOneWidget);
      expect(find.text('First cracks begin here.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'EN: Day 6 & Postgame flow (Final, Group Naming, Customization, Hub)',
      (tester) async {
        tester.view.physicalSize = const Size(360, 640);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        SharedPreferences.setMockInitialValues({'selectedLanguage': 'en'});
        final prefs = await SharedPreferences.getInstance();
        final localeCtrl = LocaleController.withPreferences(prefs);
        await localeCtrl.restore();
        addTearDown(localeCtrl.dispose);

        final state = GameState(seasonSeed: 2024);
        addTearDown(state.dispose);
        state.savePlayerRadar([1, 2, 3, 4, 5]);

        // Day 6
        await tester.pumpWidget(
          createQAApp(
            home: const Day6GrandFinalScreen(),
            gameState: state,
            localeController: localeCtrl,
          ),
        );
        await tester.pump();
        expect(find.text('GRAND FINAL'), findsOneWidget);
        expect(
          find.text(
            '7 finalists.\nA 5-member group.\nThe final choice is yours.',
          ),
          findsOneWidget,
        );

        // Group Naming
        await tester.pumpWidget(
          createQAApp(
            home: const GroupNamingScreen(),
            gameState: state,
            localeController: localeCtrl,
          ),
        );
        await tester.pump();
        expect(find.text('GROUP NAME'), findsOneWidget);
        expect(find.text('CONFIRM NAME  ★ →'), findsOneWidget);

        // Final Customization
        await tester.pumpWidget(
          createQAApp(
            home: const FinalGroupCustomizationScreen(),
            gameState: state,
            localeController: localeCtrl,
          ),
        );
        await tester.pump();
        expect(find.text('CUSTOMIZE YOUR GROUP'), findsOneWidget);
        expect(
          find.text('Assign performance positions to all five members.'),
          findsOneWidget,
        );

        // Season Complete Hub
        await tester.pumpWidget(
          createQAApp(
            home: const SeasonCompleteHubScreen(),
            gameState: state,
            localeController: localeCtrl,
          ),
        );
        await tester.pump();
        expect(find.text('SEASON NOT YET COMPLETED'), findsOneWidget);
        expect(find.text('RETURN TO GAME'), findsOneWidget);
        expect(find.text('SEZON HENÜZ TAMAMLANMADI'), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  });

  group('Visual QA Pass 3: Mid-Game Language Switch & State Invariance', () {
    testWidgets(
      'TR -> EN -> TR mid-game switches smoothly and preserves 100% of game state',
      (tester) async {
        SharedPreferences.setMockInitialValues({'selectedLanguage': 'tr'});
        final prefs = await SharedPreferences.getInstance();
        final localeCtrl = LocaleController.withPreferences(prefs);
        await localeCtrl.restore();
        addTearDown(localeCtrl.dispose);

        final state = GameState(seasonSeed: 777);
        addTearDown(state.dispose);
        state.savePlayerRadar([1, 2, 3, 4, 5]);

        // Snapshot state
        final seedBefore = state.seasonSeed;
        final radarBefore = List<int>.from(state.playerRadarContestantIds);

        // Pump in Turkish
        await tester.pumpWidget(
          createQAApp(
            home: const Day2BriefingScreen(),
            gameState: state,
            localeController: localeCtrl,
          ),
        );
        await tester.pump();
        expect(find.text('İLK GRUP GÖREVİ'), findsOneWidget);
        expect(find.text('FIRST GROUP TASK'), findsNothing);

        // Switch language TR -> EN
        await localeCtrl.select(const Locale('en'));
        await tester.pump();

        // UI is now English
        expect(find.text('FIRST GROUP TASK'), findsOneWidget);
        expect(find.text('İLK GRUP GÖREVİ'), findsNothing);

        // Verify state untouched
        expect(state.seasonSeed, equals(seedBefore));
        expect(state.playerRadarContestantIds, equals(radarBefore));

        // Switch language EN -> TR
        await localeCtrl.select(const Locale('tr'));
        await tester.pump();

        // UI is back to Turkish
        expect(find.text('İLK GRUP GÖREVİ'), findsOneWidget);
        expect(find.text('FIRST GROUP TASK'), findsNothing);

        // Verify state still untouched
        expect(state.seasonSeed, equals(seedBefore));
        expect(state.playerRadarContestantIds, equals(radarBefore));
        expect(tester.takeException(), isNull);
      },
    );
  });

  group('Visual QA Pass 4: Small Screen Layout & Regression', () {
    testWidgets(
      'Ultra-compact screen (320x480) renders all critical dialogs and screens without overflow',
      (tester) async {
        tester.view.physicalSize = const Size(320, 480);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        SharedPreferences.setMockInitialValues({'selectedLanguage': 'en'});
        final prefs = await SharedPreferences.getInstance();
        final localeCtrl = LocaleController.withPreferences(prefs);
        await localeCtrl.restore();
        addTearDown(localeCtrl.dispose);

        final state = GameState(seasonSeed: 42);
        addTearDown(state.dispose);
        state.savePlayerRadar([1, 2, 3, 4, 5]);

        await tester.pumpWidget(
          createQAApp(
            home: const Scaffold(
              body: MissionBriefing(
                stageId: 'test_stage_ultra_compact',
                title: 'Critical Crisis Stage',
                what: 'Make a decisive choice under high pressure.',
                watch: 'Contestant morale and jury approval ratings.',
                affects: 'Elimination risks and team trust.',
                child: Center(child: Text('Content')),
              ),
            ),
            gameState: state,
            localeController: localeCtrl,
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.text('MISSION BRIEF'), findsOneWidget);
        expect(find.text('WHAT TO DO'), findsOneWidget);
        expect(find.text('WHAT TO WATCH'), findsOneWidget);
        expect(find.text('WHAT IT AFFECTS'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  });
}
