import 'package:yildiz_kadro/features/evaluation/domain/evaluation_result.dart';
import 'package:yildiz_kadro/features/group_task/domain/day2_group_performance.dart';
import 'package:yildiz_kadro/features/group_task/domain/day2_rehearsal.dart';

Day2GroupPerformanceSnapshot calculateDay2GroupPerformance({
  required List<int> teamAIds,
  required List<int> teamBIds,
  required int captainAId,
  required int captainBId,
  required Map<int, EvaluationResult> evaluationResults,
  required Day2RehearsalSetup rehearsalSetup,
  required Day2RehearsalOutcome rehearsalOutcome,
}) {
  final individuals = <int, IndividualGroupPerformanceResult>{};
  final teamA = _calculateTeam(
    teamId: 'A',
    teamIds: teamAIds,
    roles: rehearsalSetup.teamARoles,
    crisis: rehearsalSetup.teamACrisis,
    choice: rehearsalOutcome.playerInterventionTeamId == 'A'
        ? rehearsalOutcome.playerChoice
        : rehearsalOutcome.captainChoice,
    playerChoice: rehearsalOutcome.playerInterventionTeamId == 'A',
    metrics: rehearsalOutcome.teamAFinalMetrics,
    evaluationResults: evaluationResults,
    individuals: individuals,
  );
  final teamB = _calculateTeam(
    teamId: 'B',
    teamIds: teamBIds,
    roles: rehearsalSetup.teamBRoles,
    crisis: rehearsalSetup.teamBCrisis,
    choice: rehearsalOutcome.playerInterventionTeamId == 'B'
        ? rehearsalOutcome.playerChoice
        : rehearsalOutcome.captainChoice,
    playerChoice: rehearsalOutcome.playerInterventionTeamId == 'B',
    metrics: rehearsalOutcome.teamBFinalMetrics,
    evaluationResults: evaluationResults,
    individuals: individuals,
  );
  final winner = _teamAIsWinner(
    teamA,
    teamB,
    rehearsalOutcome.teamAFinalMetrics.score,
    rehearsalOutcome.teamBFinalMetrics.score,
    captainAId,
    captainBId,
  )
      ? 'A'
      : 'B';
  final losingTeamId = winner == 'A' ? 'B' : 'A';
  final losingIds = losingTeamId == 'A' ? teamAIds : teamBIds;
  final ranking = losingIds.toList()
    ..sort((a, b) => _compareIndividuals(
          individuals[a]!,
          individuals[b]!,
          evaluationResults,
        ));
  final top3 = ranking.take(3).toList(growable: false);
  final risk = ranking.skip(3).toList(growable: false);
  if ({...teamAIds, ...teamBIds}.length != 14 ||
      top3.length != 3 ||
      risk.length != 4 ||
      {...top3, ...risk}.length != 7) {
    throw StateError('Day 2 grup performansı doğrulaması başarısız.');
  }
  return Day2GroupPerformanceSnapshot(
    teamAResult: teamA,
    teamBResult: teamB,
    individualResults: Map.unmodifiable(individuals),
    winningTeamId: winner,
    losingTeamId: losingTeamId,
    losingTeamRankingIds: List.unmodifiable(ranking),
    top3SafeIds: top3,
    initialRiskIds: risk,
  );
}

TeamGroupPerformanceResult _calculateTeam({
  required String teamId,
  required List<int> teamIds,
  required TeamRoleAssignments roles,
  required RehearsalCrisis crisis,
  required RehearsalChoice choice,
  required bool playerChoice,
  required RehearsalMetrics metrics,
  required Map<int, EvaluationResult> evaluationResults,
  required Map<int, IndividualGroupPerformanceResult> individuals,
}) {
  double average(int Function(EvaluationResult) select) =>
      teamIds
          .map((id) => select(evaluationResults[id]!))
          .reduce((a, b) => a + b) /
      teamIds.length;
  final vocal = (average((r) => r.vocal) * .85 +
          metrics.readiness * .15 +
          _executionBonus(evaluationResults[roles.mainVocalId]!.vocal))
      .round()
      .clamp(0, 100);
  final dance = (average((r) => r.dance) * .85 +
          metrics.readiness * .15 +
          _executionBonus(evaluationResults[roles.danceLeadId]!.dance))
      .round()
      .clamp(0, 100);
  final stage = (average((r) => r.stage) * .80 +
          metrics.energy * .20 +
          _executionBonus(evaluationResults[roles.centerId]!.stage))
      .round()
      .clamp(0, 100);
  for (final id in teamIds) {
    individuals[id] = _calculateIndividual(
      id: id,
      teamId: teamId,
      roles: roles,
      crisis: crisis,
      choice: choice,
      playerChoice: playerChoice,
      metrics: metrics,
      evaluationResult: evaluationResults[id]!,
    );
  }
  final ranked = teamIds.toList()
    ..sort((a, b) => _compareIndividuals(
          individuals[a]!,
          individuals[b]!,
          evaluationResults,
        ));
  final raw = vocal * .25 + dance * .25 + stage * .30 + metrics.harmony * .20;
  return TeamGroupPerformanceResult(
    teamId: teamId,
    vocal: vocal,
    dance: dance,
    stage: stage,
    harmony: metrics.harmony,
    rawGroupScore: raw.clamp(0, 100),
    starContestantId: ranked.first,
  );
}

IndividualGroupPerformanceResult _calculateIndividual({
  required int id,
  required String teamId,
  required TeamRoleAssignments roles,
  required RehearsalCrisis crisis,
  required RehearsalChoice choice,
  required bool playerChoice,
  required RehearsalMetrics metrics,
  required EvaluationResult evaluationResult,
}) {
  var vocal = evaluationResult.vocal * .85 + metrics.readiness * .15;
  var dance = evaluationResult.dance * .85 + metrics.readiness * .15;
  var stage = evaluationResult.stage * .75 +
      metrics.energy * .15 +
      metrics.harmony * .10;
  var role = 'GRUP ÜYESİ';
  if (id == roles.centerId) {
    stage += 2;
    role = 'CENTER';
  } else if (id == roles.mainVocalId) {
    vocal += 2;
    role = 'ANA VOKAL';
  } else if (id == roles.danceLeadId) {
    dance += 2;
    role = 'DANS LİDERİ';
  }
  final bonus = _decisionBonus(
    contestantId: id,
    crisis: crisis,
    choiceId: choice.id,
    fullStrength: playerChoice,
  );
  vocal += bonus.$1;
  dance += bonus.$2;
  stage += bonus.$3;
  final finalVocal = vocal.round().clamp(0, 100);
  final finalDance = dance.round().clamp(0, 100);
  final finalStage = stage.round().clamp(0, 100);
  final overall = finalVocal * .25 +
      finalDance * .25 +
      finalStage * .40 +
      metrics.harmony * .10;
  return IndividualGroupPerformanceResult(
    contestantId: id,
    teamId: teamId,
    assignedRole: role,
    vocal: finalVocal,
    dance: finalDance,
    stage: finalStage,
    rawOverall: overall.clamp(0, 100),
    receivedDecisionBonus: bonus != (0, 0, 0),
  );
}

(int, int, int) _decisionBonus({
  required int contestantId,
  required RehearsalCrisis crisis,
  required String choiceId,
  required bool fullStrength,
}) {
  final primary = crisis.primaryContestantId;
  final challenger = crisis.secondaryContestantId;
  (int, int, int) bonus = (0, 0, 0);
  switch (crisis.type) {
    case RehearsalCrisisType.centerConflict:
      if (choiceId == 'keep_center' && contestantId == primary) {
        bonus = (0, 0, 2);
      }
      if (choiceId == 'share_center' && contestantId == primary) {
        bonus = (0, 0, 1);
      }
      if (choiceId == 'share_center' && contestantId == challenger) {
        bonus = (0, 0, 3);
      }
      break;
    case RehearsalCrisisType.vocalConflict:
      if (choiceId == 'keep_vocal' && contestantId == primary) {
        bonus = (2, 0, 0);
      }
      if (choiceId == 'share_high_note' && contestantId == primary) {
        bonus = (1, 0, 0);
      }
      if (choiceId == 'share_high_note' && contestantId == challenger) {
        bonus = (3, 0, 0);
      }
      break;
    case RehearsalCrisisType.danceConflict:
      if (choiceId == 'clean_choreo' && contestantId == primary) {
        bonus = (0, 2, 0);
      }
      if (choiceId == 'freestyle' && contestantId == challenger) {
        bonus = (0, 2, 2);
      }
      break;
    case RehearsalCrisisType.lastPickPressure:
      if (contestantId == primary && choiceId == 'reduce_pressure') {
        bonus = (1, 1, 1);
      }
      if (contestantId == primary && choiceId == 'star_moment') {
        bonus = (0, 0, 4);
      }
      break;
    case RehearsalCrisisType.generic:
      break;
  }
  if (fullStrength) return bonus;
  int reduced(int value) => value == 0 ? 0 : (value * .6).round().clamp(1, 2);
  return (reduced(bonus.$1), reduced(bonus.$2), reduced(bonus.$3));
}

int _executionBonus(int mainStat) {
  if (mainStat >= 95) return 3;
  if (mainStat >= 90) return 2;
  if (mainStat >= 85) return 1;
  return 0;
}

int _compareIndividuals(
  IndividualGroupPerformanceResult a,
  IndividualGroupPerformanceResult b,
  Map<int, EvaluationResult> evaluationResults,
) {
  final overall = b.rawOverall.compareTo(a.rawOverall);
  if (overall != 0) return overall;
  final stage = b.stage.compareTo(a.stage);
  if (stage != 0) return stage;
  final vocal = b.vocal.compareTo(a.vocal);
  if (vocal != 0) return vocal;
  final dance = b.dance.compareTo(a.dance);
  if (dance != 0) return dance;
  final firstOverall = evaluationResults[b.contestantId]!
      .overall
      .compareTo(evaluationResults[a.contestantId]!.overall);
  return firstOverall != 0
      ? firstOverall
      : a.contestantId.compareTo(b.contestantId);
}

bool _teamAIsWinner(
  TeamGroupPerformanceResult a,
  TeamGroupPerformanceResult b,
  int rehearsalA,
  int rehearsalB,
  int captainAId,
  int captainBId,
) {
  if ((a.rawGroupScore - b.rawGroupScore).abs() > .0001) {
    return a.rawGroupScore > b.rawGroupScore;
  }
  if (a.stage != b.stage) return a.stage > b.stage;
  if (a.harmony != b.harmony) return a.harmony > b.harmony;
  if (rehearsalA != rehearsalB) return rehearsalA > rehearsalB;
  if (a.vocal != b.vocal) return a.vocal > b.vocal;
  return captainAId < captainBId;
}

String arrangementLabel(TeamGroupPerformanceResult result) {
  final values = [result.vocal, result.dance, result.stage];
  values.sort();
  if (values.last - values.first <= 2) return 'DENGELİ DÜZENLEME';
  if (result.vocal >= result.dance && result.vocal >= result.stage) {
    return 'VOKAL ODAKLI DÜZENLEME';
  }
  if (result.dance >= result.stage) return 'PERFORMANS ODAKLI DÜZENLEME';
  return 'SAHNE ODAKLI DÜZENLEME';
}

String teamPerformanceNarrative(TeamGroupPerformanceResult result) {
  final scores = <String, int>{
    'vocal': result.vocal,
    'dance': result.dance,
    'stage': result.stage,
    'harmony': result.harmony,
  };
  final strongest =
      scores.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  return switch (strongest) {
    'vocal' => 'Ses tarafında gecenin çıtasını yükselttiler.',
    'dance' => 'Koreografi takımın en güçlü silahı oldu.',
    'stage' => 'Kamerayı bırakmadılar.',
    _ => 'Yedi kişi tek bir performans gibi göründü.',
  };
}
