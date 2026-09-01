import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yildiz_kadro/app/app.dart';
import 'package:yildiz_kadro/app/navigation/game_navigation_observer.dart';
import 'package:yildiz_kadro/features/contestants/data/contestant_seed_data.dart';
import 'package:yildiz_kadro/features/contestants/presentation/contestant_detail_screen.dart';
import 'package:yildiz_kadro/features/contestants/presentation/widgets/contestant_detail_back_button.dart';
import 'package:yildiz_kadro/features/evaluation/data/evaluation1_data.dart';
import 'package:yildiz_kadro/features/evaluation/presentation/first_evaluation_screen.dart';
import 'package:yildiz_kadro/features/game/application/game_state.dart';
import 'package:yildiz_kadro/features/game/application/game_scope.dart';
import 'package:yildiz_kadro/features/day2/presentation/day2_briefing_screen.dart';
import 'package:yildiz_kadro/features/day2/data/day2_team_compatibility.dart';
import 'package:yildiz_kadro/features/last_chance/data/last_chance_data.dart';
import 'package:yildiz_kadro/features/last_chance/presentation/last_chance_performance_screen.dart';
import 'package:yildiz_kadro/features/jury/presentation/jury_decision_screen.dart';
import 'package:yildiz_kadro/features/group_task/data/day2_team_draft.dart';
import 'package:yildiz_kadro/features/group_task/data/day2_rehearsal_engine.dart';
import 'package:yildiz_kadro/features/group_task/data/day2_group_performance_engine.dart';
import 'package:yildiz_kadro/features/group_task/data/day2_jury_engine.dart';
import 'package:yildiz_kadro/features/group_task/data/day2_duel_engine.dart';
import 'package:yildiz_kadro/features/group_task/domain/day2_duel_result.dart';
import 'package:yildiz_kadro/features/group_task/domain/day2_rehearsal.dart';
import 'package:yildiz_kadro/features/group_task/presentation/day2_duel_screen.dart';
import 'package:yildiz_kadro/features/group_task/data/day3_identity_engine.dart';
import 'package:yildiz_kadro/features/group_task/domain/day3_identity_setup.dart';
import 'package:yildiz_kadro/features/postgame/data/final_group_customization_engine.dart';
import 'package:yildiz_kadro/features/postgame/data/group_tag_normalizer.dart';
import 'package:yildiz_kadro/features/postgame/presentation/season_complete_hub_screen.dart';
import 'package:yildiz_kadro/features/producer/data/story_event_engine.dart';
import 'package:yildiz_kadro/features/producer/domain/story_event.dart';
import 'package:yildiz_kadro/features/producer/presentation/producer_dashboard_screen.dart';
import 'package:yildiz_kadro/features/producer/presentation/story_event_dialog.dart';
import 'package:yildiz_kadro/features/roster/presentation/post_elimination_roster_screen.dart';
import 'package:yildiz_kadro/shared/widgets/game_home_button.dart';
import 'package:yildiz_kadro/shared/widgets/global_gameplay_shell.dart';
import 'package:yildiz_kadro/shared/widgets/app_button.dart';

void main() {
  testWidgets('landing screen shows the season introduction', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const YildizKadroApp());

    expect(find.text('YILDIZ\nKADRO'), findsOneWidget);
    expect(find.text('15 yarışmacı.\n5 kişilik\nbir grup.'), findsOneWidget);
    expect(
      find.text(
        'Takımları kur, kararlarını ver ve final kadrosunu sen oluştur.',
      ),
      findsOneWidget,
    );
    expect(find.text('SEZONA BAŞLA'), findsOneWidget);
    expect(find.text('NASIL OYNANIR?'), findsOneWidget);
    expect(find.text('GÜLCE'), findsOneWidget);
    expect(find.text('Final sahnesi  ★'), findsOneWidget);
    expect(find.text('YAPIMCI MODU'), findsOneWidget);
  });

  testWidgets('global home opens dashboard and resumes first evaluation', (
    WidgetTester tester,
  ) async {
    final state = GameState(seasonSeed: 7)
      ..savePlayerRadar(const [1, 2, 3, 4, 5]);
    final navigatorKey = GlobalKey<NavigatorState>();
    final observer = GameNavigationObserver();
    addTearDown(() {
      observer.dispose();
      state.dispose();
    });

    await tester.pumpWidget(
      GameScope(
        gameState: state,
        child: MaterialApp(
          navigatorKey: navigatorKey,
          navigatorObservers: [observer],
          home: const Scaffold(body: Text('TEST HOME')),
          builder: (context, child) => GlobalGameplayShell(
            navigatorKey: navigatorKey,
            observer: observer,
            child: child!,
          ),
        ),
      ),
    );
    navigatorKey.currentState!.push(
      MaterialPageRoute<void>(builder: (_) => const FirstEvaluationScreen()),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('GÖREV ÖZETİ'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
    expect(find.byType(GameHomeButton), findsOneWidget);
    final semantics = tester.getSemantics(find.byType(GameHomeButton));
    expect(semantics.label, contains('Ana Merkez'));
    final iconButton = tester.widget<IconButton>(
      find.descendant(
        of: find.byType(GameHomeButton),
        matching: find.byType(IconButton),
      ),
    );
    expect(iconButton.onPressed, isNotNull);

    await tester.tap(find.byType(GameHomeButton));
    await tester.pumpAndSettle();
    expect(find.text('YAPIMCI MASASI'), findsOneWidget);
    expect(find.text('KALDIĞIN YERDEN DEVAM ET'), findsOneWidget);

    await tester.tap(find.text('KALDIĞIN YERDEN DEVAM ET'));
    await tester.pumpAndSettle();
    expect(find.text('İLK DEĞERLENDİRME'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('backstage prepares one event outside the build phase', (
    WidgetTester tester,
  ) async {
    final state = GameState(seasonSeed: 19)
      ..savePlayerRadar(const [1, 2, 3, 4, 5]);
    addTearDown(state.dispose);
    await tester.pumpWidget(
      GameScope(
        gameState: state,
        child: const MaterialApp(home: ProducerDashboardScreen(day: 2)),
      ),
    );

    expect(state.eventHistory, isEmpty);
    await tester.tap(find.text('KULİS'));
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(state.eventHistory, hasLength(1));

    await tester.tap(find.text('YARIŞMACILAR'));
    await tester.pump();
    await tester.tap(find.text('KULİS'));
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(state.eventHistory, hasLength(1));
  });

  test('seed data contains all 15 contestant names', () {
    expect(contestantSeedData, hasLength(15));
    expect(
      contestantSeedData.map((contestant) => contestant.name),
      containsAll([
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
      ]),
    );
    expect(
      contestantSeedData.map((contestant) => contestant.id).toSet(),
      hasLength(15),
    );
    expect(
      contestantSeedData.map((contestant) => contestant.number).toSet(),
      hasLength(15),
    );
    expect(
      contestantSeedData.every(
        (contestant) => contestant.fullBackground.isNotEmpty,
      ),
      isTrue,
    );
    expect(
      contestantSeedData.every(
        (contestant) => contestant.specialTraitTitle.isNotEmpty,
      ),
      isTrue,
    );
    expect(
      contestantSeedData.every((contestant) => contestant.riskTitle.isNotEmpty),
      isTrue,
    );
    expect(
      contestantSeedData.every(
        (contestant) => contestant.producerNote.isNotEmpty,
      ),
      isTrue,
    );
    expect(
      contestantSeedData.every(
        (contestant) => contestant.personalityTraits.isNotEmpty,
      ),
      isTrue,
    );
    expect(
      contestantSeedData.every((contestant) {
        final stats = [
          contestant.vocal,
          contestant.dance,
          contestant.stage,
          contestant.popularity,
          contestant.potential,
        ];
        return stats.every((stat) => stat >= 0 && stat <= 100);
      }),
      isTrue,
    );
  });

  test('renamed contestants keep stable ids and Gülce leads base talent', () {
    final zeynepEla = contestantSeedData.singleWhere((value) => value.id == 13);
    final gulce = contestantSeedData.singleWhere((value) => value.id == 1);
    final lara = contestantSeedData.singleWhere((value) => value.id == 8);
    final gulceTalent = gulce.vocal + gulce.dance + gulce.stage;
    final otherTalent = contestantSeedData
        .where((value) => value.id != gulce.id)
        .map((value) => value.vocal + value.dance + value.stage);

    expect(zeynepEla.name, 'Zeynep Ela');
    expect(zeynepEla.city, 'Sakarya');
    expect(zeynepEla.occupationOrEducation, 'Profesyonel voleybolcu');
    expect(
      zeynepEla.portraitAsset,
      'assets/contestants/zeynep_ela/neutral.png',
    );
    expect(zeynepEla.initialMotivation, 92);
    expect(gulce.initialMotivation, 86);
    expect(gulce.city, 'Ankara');
    expect(lara.name, 'Lara');
    expect(lara.city, 'İstanbul');
    expect(lara.occupationOrEducation, 'Mimarlık öğrencisi');
    expect(
      [lara.vocal, lara.dance, lara.stage, lara.popularity, lara.potential],
      [76, 74, 71, 63, 76],
    );
    expect(lara.personalityTraits, [
      'Koruyucu',
      'Sabırlı',
      'Sıcakkanlı',
      'Gerçekçi',
    ]);
    expect(lara.specialTraitTitle, 'Kriz Yöneticisi');
    expect(lara.riskTitle, 'Kendini Geri Plana Atıyor');
    expect(
      gulceTalent,
      greaterThan(otherTalent.reduce((a, b) => a > b ? a : b)),
    );
  });

  testWidgets('season action opens the casting dashboard', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const YildizKadroApp());

    await tester.ensureVisible(find.text('SEZONA BAŞLA'));
    await tester.tap(find.text('SEZONA BAŞLA'));
    await tester.pumpAndSettle();

    expect(find.text('YARIŞMACILAR'), findsOneWidget);
    expect(find.text('GÜLCE'), findsOneWidget);
  });

  testWidgets('contestant card opens detail with correct stats', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const YildizKadroApp());
    await tester.ensureVisible(find.text('SEZONA BAŞLA'));
    await tester.tap(find.text('SEZONA BAŞLA'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('GÜLCE').first);
    await tester.pumpAndSettle();

    expect(find.text('GÜLCE'), findsOneWidget);
    expect(find.text('Bilgisayar Mühendisliği öğrencisi'), findsOneWidget);
    expect(find.text('VOKAL'), findsOneWidget);
    expect(find.text('92'), findsOneWidget);
    expect(find.text('SAHNE'), findsOneWidget);
    expect(find.text('95'), findsOneWidget);
    expect(find.text('HIZLI ÖĞRENEN'), findsOneWidget);

    expect(find.byType(ContestantDetailBackButton), findsOneWidget);
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -700),
    );
    await tester.pump();
    expect(find.byType(ContestantDetailBackButton), findsOneWidget);
    await tester.tap(find.byType(ContestantDetailBackButton));
    await tester.pumpAndSettle();
    expect(find.text('YARIŞMACILAR'), findsOneWidget);
  });

  testWidgets('root contestant detail back safely opens contestant dashboard', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ContestantDetailScreen(contestant: contestantSeedData.first),
      ),
    );

    expect(find.byType(ContestantDetailBackButton), findsOneWidget);
    await tester.tap(find.byType(ContestantDetailBackButton));
    await tester.pumpAndSettle();
    expect(find.text('YARIŞMACILAR'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('landing screen supports large accessible text', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: const YildizKadroApp(),
      ),
    );

    expect(tester.takeException(), isNull);
    await tester.scrollUntilVisible(find.text('YAPIMCI MODU'), 200);

    expect(tester.takeException(), isNull);
    expect(find.text('YAPIMCI MODU'), findsOneWidget);
  });

  testWidgets('casting dashboard supports large accessible text', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: const YildizKadroApp(),
      ),
    );
    await tester.ensureVisible(find.text('SEZONA BAŞLA'));
    await tester.tap(find.text('SEZONA BAŞLA'));
    await tester.pumpAndSettle();

    expect(find.text('YARIŞMACILAR'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('casting dossier supports large accessible text', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: const YildizKadroApp(),
      ),
    );
    await tester.ensureVisible(find.text('SEZONA BAŞLA'));
    await tester.tap(find.text('SEZONA BAŞLA'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('GÜLCE'), 200);
    await tester.tap(find.text('GÜLCE').first);
    await tester.pumpAndSettle();

    expect(find.text('Bilgisayar Mühendisliği öğrencisi'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('all contestants have a portrait asset', () {
    expect(
      contestantSeedData.map((contestant) => contestant.portraitAsset),
      everyElement(isNotNull),
    );
  });

  test('game state saves exactly five radar contestant ids', () {
    final gameState = GameState();

    gameState.savePlayerRadar([1, 2, 3, 4, 5]);

    expect(gameState.playerRadarContestantIds, [1, 2, 3, 4, 5]);
    expect(() => gameState.savePlayerRadar([1, 2, 3]), throwsArgumentError);
  });

  testWidgets('casting action opens the first impression screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const YildizKadroApp());
    await tester.ensureVisible(find.text('SEZONA BAŞLA'));
    await tester.tap(find.text('SEZONA BAŞLA'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('15 YARIŞMACIYI GÖRDÜM'), 400);
    await tester.tap(find.text('15 YARIŞMACIYI GÖRDÜM'));
    await tester.pumpAndSettle();

    expect(find.text('İlk izlenimin kimden yana?'), findsOneWidget);
    expect(find.text('0 / 5 RADARDA'), findsOneWidget);
    expect(find.text('5 KİŞİ SEÇ'), findsOneWidget);
  });

  test('first evaluation data is deterministic and complete', () {
    expect(evaluation1Results, hasLength(15));
    expect(evaluation1RevealOrder, hasLength(15));
    expect(evaluation1RevealOrder.toSet(), hasLength(15));
    expect(evaluation1Results[4]!.overall, 91);
    expect(evaluation1Results[7]!.tag, 'SÜRPRİZ ÇIKIŞ');
    expect(evaluation1RevealOrder.first, 13);
    expect(evaluation1RevealOrder.last, 4);
  });

  test('game state records first evaluation completion', () {
    final gameState = GameState();

    gameState.completeEvaluation1(evaluation1Results);

    expect(gameState.evaluation1Completed, isTrue);
    expect(gameState.evaluation1Results, hasLength(15));
  });

  test(
    'performance aftermath records follower popularity motivation and xp',
    () {
      final state = GameState(seasonSeed: 30);
      final before = state.socialStateFor(1);
      state.completeEvaluation1(evaluation1Results);
      final aftermath = state.performanceAftermath('evaluation_1')!;
      final change = aftermath.changes.firstWhere(
        (value) => value.contestantId == 1,
      );

      expect(aftermath.changes, hasLength(15));
      expect(change.before.followers, before.followers);
      expect(change.followerDelta, greaterThan(0));
      expect(change.xpDelta, greaterThan(0));
      expect(change.after.popularity, inInclusiveRange(0, 100));
      expect(change.after.motivation, inInclusiveRange(0, 100));
    },
  );

  test('jury decision stores producer, jury and last chance ids once', () {
    final gameState = GameState();

    gameState.completeJuryDecision1(
      producerSaveContestantId: 1,
      jurySaveContestantId: 3,
      lastChanceContestantIds: [6, 13, 9],
    );
    gameState.completeJuryDecision1(
      producerSaveContestantId: 9,
      jurySaveContestantId: 3,
      lastChanceContestantIds: [6, 13, 1],
    );

    expect(gameState.juryDecision1Completed, isTrue);
    expect(gameState.producerSaveContestantId, 1);
    expect(gameState.jurySaveContestantId, 3);
    expect(gameState.lastChanceContestantIds, [6, 13, 9]);
  });

  testWidgets('producer right opens before risk reveal animation finishes', (
    tester,
  ) async {
    final gameState = GameState(seasonSeed: 21);
    addTearDown(gameState.dispose);

    await tester.pumpWidget(
      GameScope(
        gameState: gameState,
        child: const MaterialApp(home: JuryDecisionScreen()),
      ),
    );

    await tester.tap(find.text('RİSK BÖLGESİNİ GÖR'));
    await tester.pump();
    await tester.ensureVisible(find.text('JÜRİNİN KARŞISINA ÇIK'));
    await tester.tap(find.text('JÜRİNİN KARŞISINA ÇIK'));
    await tester.pump();

    await tester.ensureVisible(find.text('YAPIMCI HAKKINI KULLAN'));
    final button = tester.widget<AppButton>(
      find.widgetWithText(AppButton, 'YAPIMCI HAKKINI KULLAN'),
    );
    expect(button.onPressed, isNotNull);

    await tester.tap(find.text('YAPIMCI HAKKINI KULLAN'));
    await tester.pump();
    expect(find.text('YAPIMCI HAKKI'), findsOneWidget);
    expect(gameState.juryDecision1Completed, isFalse);
  });

  test('coaching bonus changes deterministic last chance ranking', () {
    final ranked = rankLastChanceResults(
      contestantIds: [6, 1, 9],
      coachContestantId: 1,
    );

    expect(ranked.map((result) => result.contestantId), [1, 6, 9]);
    expect(ranked.first.finalScore(coached: true), 96);
    expect(ranked.last.contestantId, 9);
  });

  test('last chance state locks coaching and records one elimination', () {
    final gameState = GameState();
    gameState.completeJuryDecision1(
      producerSaveContestantId: 3,
      jurySaveContestantId: 13,
      lastChanceContestantIds: [6, 1, 9],
    );
    gameState.lockLastChanceCoach(1);
    gameState.lockLastChanceCoach(6);
    gameState.completeLastChance1(
      results: {
        6: lastChanceResults[6]!,
        1: lastChanceResults[1]!,
        9: lastChanceResults[9]!,
      },
      eliminatedContestantId: 9,
    );

    expect(gameState.lastChanceCoachContestantId, 1);
    expect(gameState.eliminatedContestantIds, [9]);
    expect(gameState.activeContestantCount, 14);
    expect(gameState.lastChance1Completed, isTrue);
  });

  testWidgets('first farewell CTA advances from final two to farewell', (
    tester,
  ) async {
    final gameState = GameState();
    gameState.savePlayerRadar([1, 2, 3, 4, 5]);
    gameState.completeJuryDecision1(
      producerSaveContestantId: 3,
      jurySaveContestantId: 13,
      lastChanceContestantIds: [6, 1, 9],
    );
    gameState.lockLastChanceCoach(1);

    await tester.pumpWidget(
      GameScope(
        gameState: gameState,
        child: const MaterialApp(home: LastChancePerformanceScreen()),
      ),
    );

    for (var performance = 0; performance < 3; performance++) {
      await tester.pump(const Duration(seconds: 2));
      final label = performance == 2 ? 'KARARI GÖR' : 'SONRAKİ PERFORMANS';
      await tester.ensureVisible(find.text(label));
      await tester.tap(find.text(label));
      await tester.pump();
    }

    await tester.ensureVisible(find.text('SONUÇLARI AÇ'));
    await tester.tap(find.text('SONUÇLARI AÇ'));
    await tester.pump();
    await tester.ensureVisible(find.text('SON İKİYİ GÖR'));
    await tester.tap(find.text('SON İKİYİ GÖR'));
    await tester.pump();

    expect(find.text('İLK VEDAYI AÇ'), findsOneWidget);
    await tester.ensureVisible(find.text('İLK VEDAYI AÇ'));
    await tester.tap(find.text('İLK VEDAYI AÇ'));
    await tester.pump();

    expect(find.text('İLK VEDA'), findsOneWidget);
    expect(gameState.lastChance1Completed, isTrue);
    expect(gameState.eliminatedContestantIds, hasLength(1));
  });

  testWidgets('captain confirmation fits a short screen with scaled text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          size: Size(320, 480),
          padding: EdgeInsets.only(bottom: 24),
          textScaler: TextScaler.linear(1.3),
        ),
        child: MaterialApp(
          home: Scaffold(
            body: Align(
              alignment: Alignment.bottomCenter,
              child: CaptainConfirmationSheet(
                captainA: contestantSeedData[0],
                captainB: contestantSeedData[1],
                onChange: () {},
                onConfirm: () {},
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('KAPTANLARIN HAZIR'), findsOneWidget);
    expect(find.text('DEĞİŞTİR'), findsOneWidget);
    expect(find.text('TAKIM SEÇİMİNİ BAŞLAT'), findsOneWidget);
    final confirmButton = find.widgetWithText(
      FilledButton,
      'TAKIM SEÇİMİNİ BAŞLAT',
    );
    expect(confirmButton.hitTestable(), findsOneWidget);
    expect(tester.getRect(confirmButton).bottom, lessThanOrEqualTo(456));
    expect(tester.takeException(), isNull);
  });

  test('day 2 draft creates two deterministic valid teams', () {
    final draft = generateDay2Teams(
      activeContestantIds: List.generate(14, (index) => index + 1),
      captainAId: 4,
      captainBId: 7,
      evaluationResults: evaluation1Results,
    );
    final repeated = generateDay2Teams(
      activeContestantIds: List.generate(14, (index) => index + 1),
      captainAId: 4,
      captainBId: 7,
      evaluationResults: evaluation1Results,
    );

    expect(draft.teamAIds, hasLength(7));
    expect(draft.teamBIds, hasLength(7));
    expect({...draft.teamAIds, ...draft.teamBIds}, hasLength(14));
    expect(draft.events, hasLength(12));
    expect(draft.teamAIds, repeated.teamAIds);
    expect(draft.teamBIds, repeated.teamBIds);
    expect(
      draft.lastPickedContestantId,
      draft.events.last.selectedContestantId,
    );
  });

  test('game state locks the generated day 2 formation', () {
    final gameState = GameState();
    final draft = generateDay2Teams(
      activeContestantIds: List.generate(14, (index) => index + 1),
      captainAId: 4,
      captainBId: 7,
      evaluationResults: evaluation1Results,
    );

    gameState.completeDay2TeamFormation(draft);

    expect(gameState.day2TeamFormationCompleted, isTrue);
    expect(gameState.day2CaptainAId, 4);
    expect(gameState.day2CaptainBId, 7);
    expect(gameState.day2TeamAIds, hasLength(7));
    expect(gameState.day2TeamBIds, hasLength(7));
    expect(gameState.day2TeamDraftEvents, hasLength(12));
  });

  test('day 2 rehearsal assigns unique roles and deterministic crises', () {
    final draft = generateDay2Teams(
      activeContestantIds: List.generate(14, (index) => index + 1),
      captainAId: 4,
      captainBId: 7,
      evaluationResults: evaluation1Results,
    );
    final setup = initializeDay2Rehearsal(
      teamAIds: draft.teamAIds,
      teamBIds: draft.teamBIds,
      captainAId: draft.captainAId,
      captainBId: draft.captainBId,
      lastPickedContestantId: draft.lastPickedContestantId,
      evaluationResults: evaluation1Results,
    );

    expect({
      setup.teamARoles.centerId,
      setup.teamARoles.mainVocalId,
      setup.teamARoles.danceLeadId,
    }, hasLength(3));
    expect(setup.teamARoles.groupMemberIds, hasLength(4));
    expect(setup.teamBRoles.groupMemberIds, hasLength(4));
    expect(setup.teamAInitialMetrics.harmony, inInclusiveRange(65, 90));
    expect(setup.teamBInitialMetrics.energy, inInclusiveRange(70, 95));
    expect(setup.teamACrisis.type, isNot(setup.teamBCrisis.type));
  });

  test('team-size role config creates seven distinct assignment slots', () {
    final slots = getRolesForTeamSize(7);

    expect(slots, hasLength(7));
    expect(slots.map((slot) => slot.id).toSet(), hasLength(7));
    expect(
      slots.where((slot) => slot.type == Day2TeamRoleType.center),
      hasLength(1),
    );
    expect(
      slots.where((slot) => slot.type == Day2TeamRoleType.leadVocal),
      hasLength(1),
    );
    expect(
      slots.where((slot) => slot.type == Day2TeamRoleType.subVocal),
      hasLength(2),
    );
    expect(
      slots.where((slot) => slot.type == Day2TeamRoleType.leadDancer),
      hasLength(1),
    );
    expect(
      slots.where((slot) => slot.type == Day2TeamRoleType.subDancer),
      hasLength(2),
    );
  });

  test('candidate evaluation considers every current team member', () {
    final captainOnly = evaluateCandidateForTeam(
      candidateId: 5,
      currentTeamIds: const [1],
      results: evaluation1Results,
    );
    final fullComposition = evaluateCandidateForTeam(
      candidateId: 5,
      currentTeamIds: const [1, 2, 3, 4],
      results: evaluation1Results,
    );

    expect(captainOnly.relationshipNotes, hasLength(1));
    expect(fullComposition.relationshipNotes, hasLength(4));
    expect(fullComposition.relationshipNotes.keys, containsAll([1, 2, 3, 4]));
    expect(
      (
        fullComposition.compatibility,
        fullComposition.risk,
        fullComposition.strengths,
        fullComposition.concerns,
      ),
      isNot((
        captainOnly.compatibility,
        captainOnly.risk,
        captainOnly.strengths,
        captainOnly.concerns,
      )),
    );
  });

  test('player and captain rehearsal choices produce locked final metrics', () {
    final gameState = GameState();
    final draft = generateDay2Teams(
      activeContestantIds: List.generate(14, (index) => index + 1),
      captainAId: 4,
      captainBId: 7,
      evaluationResults: evaluation1Results,
    );
    gameState.completeDay2TeamFormation(draft);
    final setup = initializeDay2Rehearsal(
      teamAIds: draft.teamAIds,
      teamBIds: draft.teamBIds,
      captainAId: draft.captainAId,
      captainBId: draft.captainBId,
      lastPickedContestantId: draft.lastPickedContestantId,
      evaluationResults: evaluation1Results,
    );
    gameState.initializeDay2Rehearsal(setup);
    final choice = choicesForCrisis(setup.teamACrisis.type).first;
    final outcome = resolveDay2Rehearsal(
      setup: setup,
      playerTeamId: 'A',
      playerChoiceId: choice.id,
      captainAId: draft.captainAId,
      captainBId: draft.captainBId,
    );

    gameState.lockDay2PlayerInterventionTeam('A');
    gameState.completeDay2Rehearsal(outcome);

    expect(gameState.day2RehearsalCompleted, isTrue);
    expect(gameState.day2RehearsalOutcome!.playerInterventionTeamId, 'A');
    expect(gameState.day2PlayerInterventionTeamId, 'A');
    expect(outcome.teamAFinalMetrics.harmony, inInclusiveRange(60, 100));
    expect(outcome.teamBFinalMetrics.score, inInclusiveRange(60, 100));
  });

  test('day 2 group stage deterministically creates safe and risk groups', () {
    final draft = generateDay2Teams(
      activeContestantIds: List.generate(14, (index) => index + 1),
      captainAId: 4,
      captainBId: 7,
      evaluationResults: evaluation1Results,
    );
    final setup = initializeDay2Rehearsal(
      teamAIds: draft.teamAIds,
      teamBIds: draft.teamBIds,
      captainAId: draft.captainAId,
      captainBId: draft.captainBId,
      lastPickedContestantId: draft.lastPickedContestantId,
      evaluationResults: evaluation1Results,
    );
    final choice = choicesForCrisis(setup.teamACrisis.type).first;
    final rehearsal = resolveDay2Rehearsal(
      setup: setup,
      playerTeamId: 'A',
      playerChoiceId: choice.id,
      captainAId: draft.captainAId,
      captainBId: draft.captainBId,
    );
    final performance = calculateDay2GroupPerformance(
      teamAIds: draft.teamAIds,
      teamBIds: draft.teamBIds,
      captainAId: draft.captainAId,
      captainBId: draft.captainBId,
      evaluationResults: evaluation1Results,
      rehearsalSetup: setup,
      rehearsalOutcome: rehearsal,
    );

    expect(performance.individualResults, hasLength(14));
    expect(performance.top3SafeIds, hasLength(3));
    expect(performance.initialRiskIds, hasLength(4));
    expect({
      ...performance.top3SafeIds,
      ...performance.initialRiskIds,
    }, hasLength(7));
    expect(
      performance.top3SafeIds.toSet().intersection(
            performance.initialRiskIds.toSet(),
          ),
      isEmpty,
    );
  });

  test('group stage stores immunity once and keeps three jury risks', () {
    final state = GameState();
    final draft = generateDay2Teams(
      activeContestantIds: List.generate(14, (index) => index + 1),
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
    final choice = choicesForCrisis(setup.teamACrisis.type).last;
    final rehearsal = resolveDay2Rehearsal(
      setup: setup,
      playerTeamId: 'A',
      playerChoiceId: choice.id,
      captainAId: draft.captainAId,
      captainBId: draft.captainBId,
    );
    state.lockDay2PlayerInterventionTeam('A');
    state.completeDay2Rehearsal(rehearsal);
    final performance = calculateDay2GroupPerformance(
      teamAIds: draft.teamAIds,
      teamBIds: draft.teamBIds,
      captainAId: draft.captainAId,
      captainBId: draft.captainBId,
      evaluationResults: evaluation1Results,
      rehearsalSetup: setup,
      rehearsalOutcome: rehearsal,
    );
    state.initializeDay2GroupPerformance(performance);
    final protectedId = performance.initialRiskIds.first;
    state.completeDay2GroupPerformance(immunityContestantId: protectedId);
    state.completeDay2GroupPerformance(
      immunityContestantId: performance.initialRiskIds.last,
    );

    expect(state.day2GroupPerformanceCompleted, isTrue);
    expect(state.day2StarImmunityContestantId, protectedId);
    expect(state.day2JuryRiskContestantIds, hasLength(3));
    expect(state.day2JuryRiskContestantIds, isNot(contains(protectedId)));
  });

  test('day 2 jury deterministically saves one and sends two to duel', () {
    final draft = generateDay2Teams(
      activeContestantIds: List.generate(14, (index) => index + 1),
      captainAId: 4,
      captainBId: 7,
      evaluationResults: evaluation1Results,
    );
    final setup = initializeDay2Rehearsal(
      teamAIds: draft.teamAIds,
      teamBIds: draft.teamBIds,
      captainAId: draft.captainAId,
      captainBId: draft.captainBId,
      lastPickedContestantId: draft.lastPickedContestantId,
      evaluationResults: evaluation1Results,
    );
    final choice = choicesForCrisis(setup.teamACrisis.type).first;
    final rehearsal = resolveDay2Rehearsal(
      setup: setup,
      playerTeamId: 'A',
      playerChoiceId: choice.id,
      captainAId: draft.captainAId,
      captainBId: draft.captainBId,
    );
    final performance = calculateDay2GroupPerformance(
      teamAIds: draft.teamAIds,
      teamBIds: draft.teamBIds,
      captainAId: draft.captainAId,
      captainBId: draft.captainBId,
      evaluationResults: evaluation1Results,
      rehearsalSetup: setup,
      rehearsalOutcome: rehearsal,
    );
    final jury = calculateDay2JuryResult(
      juryRiskIds: performance.initialRiskIds.take(3).toList(),
      firstEvaluationResults: evaluation1Results,
      lastChanceResults: const {},
      coachedContestantId: null,
      groupPerformance: performance,
    );
    final repeated = calculateDay2JuryResult(
      juryRiskIds: performance.initialRiskIds.take(3).toList(),
      firstEvaluationResults: evaluation1Results,
      lastChanceResults: const {},
      coachedContestantId: null,
      groupPerformance: performance,
    );

    expect(jury.evaluations, hasLength(3));
    expect(jury.duelContestantIds, hasLength(2));
    expect(jury.duelContestantIds, isNot(contains(jury.savedContestantId)));
    expect(jury.rankingIds, repeated.rankingIds);
  });

  test(
    'day 2 duel decisions create deterministic differentiated modifiers',
    () {
      final draft = generateDay2Teams(
        activeContestantIds: List.generate(14, (index) => index + 1),
        captainAId: 4,
        captainBId: 7,
        evaluationResults: evaluation1Results,
      );
      final setup = initializeDay2Rehearsal(
        teamAIds: draft.teamAIds,
        teamBIds: draft.teamBIds,
        captainAId: draft.captainAId,
        captainBId: draft.captainBId,
        lastPickedContestantId: draft.lastPickedContestantId,
        evaluationResults: evaluation1Results,
      );
      final rehearsal = resolveDay2Rehearsal(
        setup: setup,
        playerTeamId: 'A',
        playerChoiceId: choicesForCrisis(setup.teamACrisis.type).first.id,
        captainAId: draft.captainAId,
        captainBId: draft.captainBId,
      );
      final group = calculateDay2GroupPerformance(
        teamAIds: draft.teamAIds,
        teamBIds: draft.teamBIds,
        captainAId: draft.captainAId,
        captainBId: draft.captainBId,
        evaluationResults: evaluation1Results,
        rehearsalSetup: setup,
        rehearsalOutcome: rehearsal,
      );
      final jury = calculateDay2JuryResult(
        juryRiskIds: group.initialRiskIds.take(3).toList(),
        firstEvaluationResults: evaluation1Results,
        lastChanceResults: const {},
        coachedContestantId: null,
        groupPerformance: group,
      );
      final clean = calculateDay2DuelResult(
        contestantIds: jury.duelContestantIds,
        concept: Day2DuelConcept.vocal,
        approach: Day2DuelApproach.clean,
        coaching: Day2DuelCoaching.technique,
        firstResults: evaluation1Results,
        groupPerformance: group,
        jury: jury,
      );
      final star = calculateDay2DuelResult(
        contestantIds: jury.duelContestantIds,
        concept: Day2DuelConcept.stage,
        approach: Day2DuelApproach.starMoment,
        coaching: Day2DuelCoaching.showYourself,
        firstResults: evaluation1Results,
        groupPerformance: group,
        jury: jury,
      );

      expect(clean.results, hasLength(2));
      expect(clean.winnerContestantId, isNot(clean.eliminatedContestantId));
      expect(clean.performanceOrderIds, hasLength(2));
      expect(
        clean.results.values.map((result) => result.totalModifier),
        isNot(
          equals(star.results.values.map((result) => result.totalModifier)),
        ),
      );
    },
  );

  testWidgets('duel result CTA opens the stored winner screen', (tester) async {
    final state = GameState();
    state.savePlayerRadar([1, 2, 3, 4, 5]);
    state.completeEvaluation1(evaluation1Results);
    state.completeJuryDecision1(
      producerSaveContestantId: 3,
      jurySaveContestantId: 13,
      lastChanceContestantIds: [6, 1, 9],
    );
    state.lockLastChanceCoach(1);
    state.completeLastChance1(
      results: {
        6: lastChanceResults[6]!,
        1: lastChanceResults[1]!,
        9: lastChanceResults[9]!,
      },
      eliminatedContestantId: 9,
    );
    final active = List.generate(
      15,
      (index) => index + 1,
    ).where((id) => id != 9).toList();
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
    final rehearsal = resolveDay2Rehearsal(
      setup: setup,
      playerTeamId: 'A',
      playerChoiceId: choicesForCrisis(setup.teamACrisis.type).first.id,
      captainAId: draft.captainAId,
      captainBId: draft.captainBId,
    );
    state.lockDay2PlayerInterventionTeam('A');
    state.completeDay2Rehearsal(rehearsal);
    final performance = calculateDay2GroupPerformance(
      teamAIds: draft.teamAIds,
      teamBIds: draft.teamBIds,
      captainAId: draft.captainAId,
      captainBId: draft.captainBId,
      evaluationResults: evaluation1Results,
      rehearsalSetup: setup,
      rehearsalOutcome: rehearsal,
    );
    state.initializeDay2GroupPerformance(performance);
    state.completeDay2GroupPerformance(
      immunityContestantId: performance.initialRiskIds.first,
    );
    final jury = calculateDay2JuryResult(
      juryRiskIds: state.day2JuryRiskContestantIds,
      firstEvaluationResults: evaluation1Results,
      lastChanceResults: lastChanceResults,
      coachedContestantId: state.lastChanceCoachContestantId,
      groupPerformance: performance,
    );
    state.completeDay2JuryTable(jury);

    await tester.pumpWidget(
      GameScope(
        gameState: state,
        child: const MaterialApp(home: Day2DuelScreen()),
      ),
    );

    Future<void> tapText(String text) async {
      final finder = find.text(text);
      await tester.ensureVisible(finder);
      await tester.tap(finder);
      await tester.pump(const Duration(milliseconds: 250));
    }

    await tapText('DÜELLOYU KUR  ★ →');
    await tapText('İLK KARARI VER');
    await tapText('VOKAL ODAKLI');
    await tapText('DEVAM ET  →');
    await tapText('TEMİZ PERFORMANS');
    await tapText('DEVAM ET  →');
    await tapText('TEKNİĞİNE GÜVEN');
    await tapText('DEVAM ET  →');
    await tapText('SAHNEYİ BAŞLAT  ★ →');
    for (var index = 0; index < 3; index++) {
      await tapText('KATEGORİYİ AÇ');
    }
    await tapText('İKİNCİ PERFORMANS');
    for (var index = 0; index < 3; index++) {
      await tapText('KATEGORİYİ AÇ');
    }
    await tapText('SONUCA GEÇ');
    await tapText('SONUCU AÇ  →');
    await tester.pumpAndSettle();

    expect(state.day2DuelCompleted, isTrue);
    expect(state.eliminatedContestantIds, hasLength(2));
    expect(find.text('DÜELLOYU KAZANDI'), findsOneWidget);
    expect(find.text('VEDAYI GÖR'), findsOneWidget);
  });

  test('day 3 allocates 13 contestants within concept capacity', () {
    final ids = List.generate(13, (index) => index + 1);
    final day2Scores = {
      for (final id in ids) id: evaluation1Results[id]!.overall.toDouble(),
    };
    final allocation = allocateDay3Concepts(
      activeContestantIds: ids,
      evaluationResults: evaluation1Results,
      day2Scores: day2Scores,
    );
    final repeated = allocateDay3Concepts(
      activeContestantIds: ids,
      evaluationResults: evaluation1Results,
      day2Scores: day2Scores,
    );
    final setup = createDay3IdentitySetup(
      allocation: allocation,
      directions: const {
        1: Day3CreativeDirection.sharpenIdentity,
        2: Day3CreativeDirection.surprise,
        3: Day3CreativeDirection.ownCamera,
      },
      evaluationResults: evaluation1Results,
    );

    expect(allocation.conceptByContestantId, hasLength(13));
    expect(allocation.conceptByContestantId, repeated.conceptByContestantId);
    for (final concept in Day3Concept.values) {
      expect(
        allocation.conceptByContestantId.values
            .where((value) => value == concept)
            .length,
        lessThanOrEqualTo(4),
      );
    }
    expect(setup.creativeDirectionByContestantId, hasLength(3));
    expect(setup.stylingSupportContestantIds.toSet(), {1, 2, 3});
  });

  test('story events are seeded, persisted and resolved only once', () {
    final first = GameState(seasonSeed: 4242);
    final second = GameState(seasonSeed: 4242);
    final event = first.ensureStoryEvent(2);
    final repeated = first.ensureStoryEvent(2);
    final matching = second.ensureStoryEvent(2);

    expect(repeated.event.id, event.event.id);
    expect(matching.event.id, event.event.id);
    expect(matching.event.contestantIds, event.event.contestantIds);

    final choice = event.event.choices.first;
    final contestantId = event.event.contestantIds.first;
    final before = first.socialStateFor(contestantId);
    first.resolveStoryEvent(day: 2, choiceId: choice.id);
    final after = first.socialStateFor(contestantId);
    first.resolveStoryEvent(day: 2, choiceId: choice.id);

    expect(first.eventHistory.single.choiceId, choice.id);
    expect(first.socialStateFor(contestantId).followers, after.followers);
    expect(
      after.popularity != before.popularity ||
          after.buzz != before.buzz ||
          after.morale != before.morale ||
          after.confidence != before.confidence ||
          after.professionalism != before.professionalism ||
          after.followers != before.followers,
      isTrue,
    );
  });

  test('new season resets social memory and relationships', () {
    final state = GameState(seasonSeed: 10);
    final event = state.ensureStoryEvent(2);
    state.resolveStoryEvent(day: 2, choiceId: event.event.choices.first.id);
    state.resetSeason();

    expect(state.eventHistory, isEmpty);
    expect(state.relationshipBetween(1, 2), 50);
    expect(state.socialStateFor(1).followerHistory, hasLength(1));
  });

  test('reality events vary across seasons and avoid recent templates', () {
    final first = GameState(seasonSeed: 101);
    final second = GameState(seasonSeed: 202);
    final firstEvent = first.ensureStoryEvent(2).event;
    final secondEvent = second.ensureStoryEvent(2).event;

    expect(firstEvent.category, StoryEventCategory.positive);
    expect(secondEvent.category, StoryEventCategory.positive);
    expect(firstEvent.id, isNot(secondEvent.id));

    first.resolveStoryEvent(day: 2, choiceId: firstEvent.choices.first.id);
    final next = first.ensureStoryEvent(3).event;
    expect(next.id.split('_d').first, isNot(firstEvent.id.split('_d').first));
  });

  test('story choice effects respond to contestant character', () {
    const choice = StoryChoice(
      id: 'pressure',
      label: 'BASKIYI ARTIR',
      feedback: 'Test',
      effects: {'morale': -4, 'preparation': 4, 'buzz': 4},
    );
    final variants = {
      for (final contestant in contestantSeedData)
        contestant.id: adjustedStoryEffects(
          choice: choice,
          contestantId: contestant.id,
        ),
    };

    expect(
      variants.values.map((value) => value.toString()).toSet().length,
      greaterThan(1),
    );
  });

  test('story event pool is broad and season frequency stays controlled', () {
    expect(storyEventTemplateCount, greaterThanOrEqualTo(20));

    for (final seed in [1, 7, 42, 101, 202]) {
      final state = GameState(seasonSeed: seed);
      final records = [
        for (var day = 1; day <= 6; day++) state.prepareStoryEvent(day),
      ].whereType<StoryEventRecord>().toList();
      final templateIds =
          records.map((record) => record.event.id.split('_d').first).toSet();

      expect(records.length, inInclusiveRange(4, 6));
      expect(templateIds.length, records.length);
      expect(
        records.every((record) => record.event.choices.length <= 3),
        isTrue,
      );
      expect(records.every((record) => record.event.cooldownDays >= 2), isTrue);
      state.dispose();
    }
  });

  testWidgets('story modal hides effects until the producer decides', (
    tester,
  ) async {
    final state = GameState(seasonSeed: 7);
    state.ensureStoryEvent(2);
    addTearDown(state.dispose);

    await tester.pumpWidget(
      GameScope(
        gameState: state,
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              return TextButton(
                onPressed: () => showStoryEventDialog(context, day: 2),
                child: const Text('OLAYI AÇ'),
              );
            },
          ),
        ),
      ),
    );
    await tester.tap(find.text('OLAYI AÇ'));
    await tester.pumpAndSettle();

    expect(find.text('BEKLENEN ETKİ'), findsNothing);
    final record = state.storyEventForDay(2)!;
    await tester.tap(find.text(record.event.choices.first.label));
    await tester.pump();
    await tester.ensureVisible(find.text('KARARI UYGULA'));
    await tester.tap(find.text('KARARI UYGULA'));
    await tester.pumpAndSettle();

    expect(find.text('KARAR UYGULANDI'), findsOneWidget);
    expect(find.text('DEVAM ET'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Icon &&
            (widget.icon == Icons.arrow_upward_rounded ||
                widget.icon == Icons.arrow_downward_rounded),
      ),
      findsWidgets,
    );
  });

  test('automatic group tags preserve List<String> at runtime', () {
    final tags = freezeAutomaticGroupTags({
      1: ['ACE', 'VOCAL LINE'],
      2: ['LEADER'],
    });

    expect(tags, isA<Map<int, List<String>>>());
    expect(tags[1], isA<List<String>>());
    expect(tags[1], ['ACE', 'VOCAL LINE']);
    expect(() => tags[1]!.add('NEW'), throwsUnsupportedError);
  });

  test('legacy automatic group tags normalize to typed immutable values', () {
    final tags = normalizeAutomaticGroupTags(<String, dynamic>{
      '1': <dynamic>['ACE', 7],
      'invalid': 'not a list',
    });

    expect(tags, isA<Map<int, List<String>>>());
    expect(tags[1], isA<List<String>>());
    expect(tags[1], ['ACE', '7']);
    expect(tags.keys, [1]);
    expect(() => tags[1]!.add('NEW'), throwsUnsupportedError);
  });

  testWidgets('incomplete last chance routes show a safe recovery state', (
    tester,
  ) async {
    final state = GameState(seasonSeed: 11);
    addTearDown(state.dispose);

    await tester.pumpWidget(
      GameScope(
        gameState: state,
        child: const MaterialApp(home: LastChancePerformanceScreen()),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.text('SON ŞANS HENÜZ HAZIR DEĞİL'), findsOneWidget);

    await tester.pumpWidget(
      GameScope(
        gameState: state,
        child: const MaterialApp(home: PostEliminationRosterScreen()),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.text('KADRO SONUCU HAZIR DEĞİL'), findsOneWidget);
  });

  testWidgets('incomplete season hub does not throw during build', (
    tester,
  ) async {
    final state = GameState(seasonSeed: 12);
    addTearDown(state.dispose);

    await tester.pumpWidget(
      GameScope(
        gameState: state,
        child: const MaterialApp(home: SeasonCompleteHubScreen()),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('SEZON HENÜZ TAMAMLANMADI'), findsOneWidget);
    expect(find.text('OYUNA DÖN'), findsOneWidget);
  });
}
