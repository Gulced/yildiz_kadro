import 'dart:math' as math;

import 'package:yildiz_kadro/features/evaluation/domain/evaluation_result.dart';
import 'package:yildiz_kadro/features/group_task/data/group_task_profiles.dart';
import 'package:yildiz_kadro/features/group_task/domain/day2_draft_result.dart';
import 'package:yildiz_kadro/features/group_task/domain/group_task_profile.dart';

Day2DraftResult generateDay2Teams({
  required Iterable<int> activeContestantIds,
  required int captainAId,
  required int captainBId,
  required Map<int, EvaluationResult> evaluationResults,
}) {
  final active = activeContestantIds.toSet();
  if (active.length != 14 ||
      captainAId == captainBId ||
      !active.contains(captainAId) ||
      !active.contains(captainBId)) {
    throw ArgumentError('Day 2 kaptan veya aktif kadro verisi geçersiz.');
  }
  final teams = <String, List<int>>{
    'A': [captainAId],
    'B': [captainBId],
  };
  final captains = {'A': captainAId, 'B': captainBId};
  final available = active.difference({captainAId, captainBId});
  final events = <Day2DraftEvent>[];

  for (var pick = 1; pick <= 12; pick++) {
    final teamId = pick.isOdd ? 'A' : 'B';
    final team = teams[teamId]!;
    final captainId = captains[teamId]!;
    final candidates = available.map((id) {
      return _scoreCandidate(
        candidateId: id,
        captainId: captainId,
        teamIds: team,
        evaluationResults: evaluationResults,
      );
    }).toList()
      ..sort((a, b) {
        final score = b.score.compareTo(a.score);
        if (score != 0) return score;
        return day2DraftTiePriority
            .indexOf(a.id)
            .compareTo(day2DraftTiePriority.indexOf(b.id));
      });
    final selected = candidates.first;
    team.add(selected.id);
    available.remove(selected.id);
    events.add(Day2DraftEvent(
      captainId: captainId,
      selectedContestantId: selected.id,
      pickNumber: pick,
      teamId: teamId,
      reason: selected.reason,
    ));
  }

  final teamA = List<int>.unmodifiable(teams['A']!);
  final teamB = List<int>.unmodifiable(teams['B']!);
  final allTeamIds = {...teamA, ...teamB};
  if (teamA.length != 7 ||
      teamB.length != 7 ||
      allTeamIds.length != 14 ||
      allTeamIds.difference(active).isNotEmpty ||
      teamA.contains(captainBId) ||
      teamB.contains(captainAId)) {
    throw StateError('Day 2 takım doğrulaması başarısız.');
  }
  return Day2DraftResult(
    captainAId: captainAId,
    captainBId: captainBId,
    teamAIds: teamA,
    teamBIds: teamB,
    events: List.unmodifiable(events),
    lastPickedContestantId: events.last.selectedContestantId,
    teamAAverages: calculateTeamAverages(teamA, evaluationResults),
    teamBAverages: calculateTeamAverages(teamB, evaluationResults),
  );
}

({int id, int score, String reason}) _scoreCandidate({
  required int candidateId,
  required int captainId,
  required List<int> teamIds,
  required Map<int, EvaluationResult> evaluationResults,
}) {
  final candidate = groupTaskProfiles[candidateId]!;
  final captain = groupTaskProfiles[captainId]!;
  final weakest = _weakestArea(teamIds, evaluationResults);
  var score = evaluationResults[candidateId]!.overall;
  final fillsWeakness = candidate.primaryRole == weakest;
  final primaryCount = teamIds
      .where(
          (id) => groupTaskProfiles[id]!.primaryRole == candidate.primaryRole)
      .length;
  final addsDiversity = primaryCount == 0;
  final isAllRounder = candidate.primaryRole == GroupRole.allRounder ||
      candidate.secondaryRole == GroupRole.allRounder;
  final compatibility = _compatibility(captain, candidate);
  if (fillsWeakness) score += 7;
  if (addsDiversity) score += 4;
  if (teamIds.length < 4 && isAllRounder) score += 2;
  if (primaryCount >= 3) score -= 5;
  score += compatibility;

  final reason = fillsWeakness
      ? 'Takımın eksik yönünü tamamlıyor.'
      : addsDiversity
          ? 'Takıma farklı bir güç getiriyor.'
          : isAllRounder && teamIds.length < 4
              ? 'Birden fazla rolde kullanılabilir.'
              : compatibility > 0
                  ? 'Çalışma tarzlarının uyuşacağını düşünüyor.'
                  : 'Bu performans gücünü görmezden gelemedi.';
  return (id: candidateId, score: score, reason: reason);
}

GroupRole _weakestArea(
  List<int> teamIds,
  Map<int, EvaluationResult> results,
) {
  final averages = calculateTeamAverages(teamIds, results);
  final values = <GroupRole, double>{
    GroupRole.vocal: averages.vocal,
    GroupRole.dance: averages.dance,
    GroupRole.stage: averages.stage,
  };
  return values.entries.reduce((a, b) => a.value <= b.value ? a : b).key;
}

int _compatibility(GroupTaskProfile captain, GroupTaskProfile candidate) {
  final pair = (captain.workStyle, candidate.workStyle);
  const bonuses = <(WorkStyle, WorkStyle), int>{
    (WorkStyle.direct, WorkStyle.controlled): 1,
    (WorkStyle.direct, WorkStyle.chaotic): -1,
    (WorkStyle.competitive, WorkStyle.bold): 2,
    (WorkStyle.social, WorkStyle.sensitive): 2,
    (WorkStyle.calm, WorkStyle.chaotic): -1,
    (WorkStyle.observant, WorkStyle.spontaneous): 1,
    (WorkStyle.playful, WorkStyle.social): 2,
    (WorkStyle.experienced, WorkStyle.controlled): 2,
  };
  var value = bonuses[pair] ?? bonuses[(pair.$2, pair.$1)] ?? 0;
  if ((captain.workStyle == WorkStyle.cameraSavvy &&
          candidate.primaryRole == GroupRole.stage) ||
      (candidate.workStyle == WorkStyle.cameraSavvy &&
          captain.primaryRole == GroupRole.stage)) {
    value += 1;
  }
  return value.clamp(-2, 2);
}

TeamAverages calculateTeamAverages(
  Iterable<int> ids,
  Map<int, EvaluationResult> results,
) {
  final list = ids.toList();
  if (list.isEmpty) {
    return const TeamAverages(vocal: 0, dance: 0, stage: 0, overall: 0);
  }
  double average(int Function(EvaluationResult) select) =>
      list.map((id) => select(results[id]!)).reduce((a, b) => a + b) /
      list.length;
  return TeamAverages(
    vocal: average((result) => result.vocal),
    dance: average((result) => result.dance),
    stage: average((result) => result.stage),
    overall: average((result) => result.overall),
  );
}

String teamProfileLabel(TeamAverages averages) {
  final values = [averages.vocal, averages.dance, averages.stage];
  if (values.reduce(math.max) - values.reduce(math.min) <= 2) {
    return 'DENGELİ TAKIM';
  }
  if (averages.vocal >= averages.dance && averages.vocal >= averages.stage) {
    return 'SES GÜCÜ';
  }
  if (averages.dance >= averages.stage) return 'HAREKET GÜCÜ';
  return 'SAHNE GÜCÜ';
}
