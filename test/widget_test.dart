import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yildiz_kadro/app/app.dart';
import 'package:yildiz_kadro/features/contestants/data/contestant_seed_data.dart';
import 'package:yildiz_kadro/features/evaluation/data/evaluation1_data.dart';
import 'package:yildiz_kadro/features/game/application/game_state.dart';
import 'package:yildiz_kadro/features/game/application/game_scope.dart';
import 'package:yildiz_kadro/features/day2/presentation/day2_briefing_screen.dart';
import 'package:yildiz_kadro/features/last_chance/data/last_chance_data.dart';
import 'package:yildiz_kadro/features/last_chance/presentation/last_chance_performance_screen.dart';
import 'package:yildiz_kadro/features/group_task/data/day2_team_draft.dart';
import 'package:yildiz_kadro/features/group_task/data/day2_rehearsal_engine.dart';
import 'package:yildiz_kadro/features/group_task/data/day2_group_performance_engine.dart';
import 'package:yildiz_kadro/features/group_task/data/day2_jury_engine.dart';
import 'package:yildiz_kadro/features/group_task/data/day2_duel_engine.dart';
import 'package:yildiz_kadro/features/group_task/domain/day2_duel_result.dart';
import 'package:yildiz_kadro/features/group_task/data/day3_identity_engine.dart';
import 'package:yildiz_kadro/features/group_task/domain/day3_identity_setup.dart';

void main() {
  testWidgets('landing screen shows the season introduction', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const YildizKadroApp());

    expect(find.text('YILDIZ\nKADRO'), findsOneWidget);
    expect(find.text('15 yarışmacı.\n5 kişilik\nbir grup.'), findsOneWidget);
    expect(
        find.text(
            'Takımları kur, kararlarını ver ve final kadrosunu sen oluştur.'),
        findsOneWidget);
    expect(find.text('SEZONA BAŞLA'), findsOneWidget);
    expect(find.text('NASIL OYNANIR?'), findsOneWidget);
    expect(find.text('GÜLCE'), findsOneWidget);
    expect(find.text('Final sahnesi  ★'), findsOneWidget);
    expect(find.text('YAPIMCI MODU'), findsOneWidget);
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
        'Eylül',
        'Nehir',
        'Lalin',
        'Arya',
        'Mina',
        'Naz',
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
      contestantSeedData.every(
        (contestant) => contestant.riskTitle.isNotEmpty,
      ),
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
    expect(find.text('74'), findsOneWidget);
    expect(find.text('SAHNE'), findsOneWidget);
    expect(find.text('86'), findsOneWidget);
    expect(find.text('HIZLI ÖĞRENEN'), findsOneWidget);
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
    await tester.scrollUntilVisible(
      find.text('YAPIMCI MODU'),
      200,
    );

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
    expect(
      () => gameState.savePlayerRadar([1, 2, 3]),
      throwsArgumentError,
    );
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

  test('coaching bonus changes deterministic last chance ranking', () {
    final ranked = rankLastChanceResults(
      contestantIds: [6, 1, 9],
      coachContestantId: 1,
    );

    expect(ranked.map((result) => result.contestantId), [1, 6, 9]);
    expect(ranked.first.finalScore(coached: true), 87);
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

  testWidgets('first farewell CTA advances from final two to farewell',
      (tester) async {
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

  testWidgets('captain confirmation fits a short screen with scaled text',
      (tester) async {
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
        draft.lastPickedContestantId, draft.events.last.selectedContestantId);
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
    expect(
      {...performance.top3SafeIds, ...performance.initialRiskIds},
      hasLength(7),
    );
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

  test('day 2 duel decisions create deterministic differentiated modifiers',
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
      isNot(equals(star.results.values.map((result) => result.totalModifier))),
    );
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
}
