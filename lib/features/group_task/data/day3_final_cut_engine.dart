import 'package:yildiz_kadro/features/evaluation/domain/evaluation_result.dart';
import 'package:yildiz_kadro/features/group_task/data/group_task_profiles.dart';
import 'package:yildiz_kadro/features/group_task/domain/day3_final_cut_result.dart';
import 'package:yildiz_kadro/features/group_task/domain/day3_icon_result.dart';
import 'package:yildiz_kadro/features/group_task/domain/day3_identity_setup.dart';
import 'package:yildiz_kadro/features/group_task/domain/group_task_profile.dart';

Day3FinalCutResultSnapshot calculateDay3FinalCut(
    {required List<int> contestantIds,
    required Day3FinalCutFormat format,
    required Day3FinalCutApproach approach,
    required Map<int, EvaluationResult> firstResults,
    required Day3IconResultSnapshot icon,
    required Day3IdentitySetupSnapshot setup}) {
  if (contestantIds.length != 2 || contestantIds.toSet().length != 2) {
    throw ArgumentError('Final Cut için 2 yarışmacı gerekli.');
  }
  final results = <int, Day3FinalCutContestantResult>{};
  for (final id in contestantIds) {
    final r = icon.results[id]!;
    final first = firstResults[id]!;
    final p = groupTaskProfiles[id]!;
    final concept = setup.allocation.conceptByContestantId[id]!;
    final base = switch (format) {
      Day3FinalCutFormat.coverShot =>
        r.camera * .50 + r.identity * .30 + r.styling * .20,
      Day3FinalCutFormat.motionShot => r.performance * .35 +
          first.dance * .30 +
          r.camera * .20 +
          r.identity * .15,
      Day3FinalCutFormat.liveCloseUp => r.camera * .35 +
          r.identity * .25 +
          first.vocal * .25 +
          r.performance * .15
    };
    final fit = _testFit(format, p, concept);
    final approachFit = _approach(approach, p);
    final direction = setup.creativeDirectionByContestantId[id];
    final history = direction == Day3CreativeDirection.sharpenIdentity &&
                format == Day3FinalCutFormat.coverShot ||
            direction == Day3CreativeDirection.surprise &&
                approach == Day3FinalCutApproach.boldFrame ||
            direction == Day3CreativeDirection.ownCamera &&
                format != Day3FinalCutFormat.motionShot
        ? 1
        : 0;
    results[id] = Day3FinalCutContestantResult(
        contestantId: id,
        baseScore: base,
        testFitModifier: fit,
        approachModifier: approachFit,
        historyModifier: history,
        rawScore: (base + fit + approachFit + history).clamp(0, 100));
  }
  int compare(int a, int b, {required bool baseline}) {
    final x = results[a]!;
    final y = results[b]!;
    var c = (baseline ? y.baseScore : y.rawScore)
        .compareTo(baseline ? x.baseScore : x.rawScore);
    if (c != 0) return c;
    final ix = icon.results[a]!;
    final iy = icon.results[b]!;
    final firstA = firstResults[a]!;
    final firstB = firstResults[b]!;
    final ties = switch (format) {
      Day3FinalCutFormat.coverShot => [
          (iy.camera, ix.camera),
          (iy.identity, ix.identity),
          (iy.iconScore, ix.iconScore),
          (firstB.stage, firstA.stage)
        ],
      Day3FinalCutFormat.motionShot => [
          (firstB.dance, firstA.dance),
          (iy.performance, ix.performance),
          (iy.camera, ix.camera),
          (iy.iconScore, ix.iconScore)
        ],
      Day3FinalCutFormat.liveCloseUp => [
          (firstB.vocal, firstA.vocal),
          (iy.camera, ix.camera),
          (iy.identity, ix.identity),
          (iy.iconScore, ix.iconScore)
        ]
    };
    for (final pair in ties) {
      c = pair.$1.compareTo(pair.$2);
      if (c != 0) return c;
    }
    return a.compareTo(b);
  }

  final rank = contestantIds.toList()
    ..sort((a, b) => compare(a, b, baseline: false));
  final baseline = contestantIds.toList()
    ..sort((a, b) => compare(a, b, baseline: true));
  return Day3FinalCutResultSnapshot(
      format: format,
      approach: approach,
      results: Map.unmodifiable(results),
      winnerContestantId: rank.first,
      eliminatedContestantId: rank.last,
      playerChangedOutcome: rank.first != baseline.first);
}

int _testFit(Day3FinalCutFormat f, GroupTaskProfile p, Day3Concept c) {
  var v = 0;
  if (f == Day3FinalCutFormat.coverShot) {
    if (p.workStyle == WorkStyle.cameraSavvy) v += 4;
    if (p.primaryRole == GroupRole.stage) v += 2;
    if (p.workStyle == WorkStyle.controlled) v += 2;
    if (p.workStyle == WorkStyle.direct) v++;
    if (c == Day3Concept.highFashion) v += 2;
    if (c == Day3Concept.popIcon) v++;
  } else if (f == Day3FinalCutFormat.motionShot) {
    if (p.primaryRole == GroupRole.dance) v += 4;
    if (p.secondaryRole == GroupRole.dance) v += 2;
    if (p.primaryRole == GroupRole.stage) v += 2;
    v += switch (p.workStyle) {
      WorkStyle.bold || WorkStyle.competitive || WorkStyle.spontaneous => 2,
      WorkStyle.playful || WorkStyle.experienced => 1,
      _ => 0
    };
  } else {
    if (p.primaryRole == GroupRole.vocal) v += 4;
    if (p.secondaryRole == GroupRole.vocal) v += 2;
    v += switch (p.workStyle) {
      WorkStyle.sensitive || WorkStyle.calm || WorkStyle.instinctive => 2,
      _ => 0
    };
    if (c == Day3Concept.romanticStar) v += 2;
    if (c == Day3Concept.dreamyCinema) v++;
  }
  return v.clamp(0, 5);
}

int _approach(Day3FinalCutApproach a, GroupTaskProfile p) {
  if (a == Day3FinalCutApproach.perfectFrame) {
    var v = switch (p.workStyle) {
      WorkStyle.controlled => 4,
      WorkStyle.experienced || WorkStyle.calm => 3,
      WorkStyle.observant || WorkStyle.direct => 2,
      WorkStyle.sensitive || WorkStyle.protective || WorkStyle.cameraSavvy => 1,
      WorkStyle.chaotic => -2,
      WorkStyle.spontaneous => -1,
      _ => 0
    };
    if (p.primaryRole == GroupRole.allRounder ||
        p.secondaryRole == GroupRole.allRounder) {
      v++;
    }
    return v.clamp(-2, 4);
  }
  var v = switch (p.workStyle) {
    WorkStyle.bold || WorkStyle.spontaneous => 4,
    WorkStyle.cameraSavvy ||
    WorkStyle.competitive ||
    WorkStyle.instinctive =>
      3,
    WorkStyle.playful || WorkStyle.chaotic => 2,
    WorkStyle.direct || WorkStyle.experienced || WorkStyle.sensitive => 1,
    WorkStyle.controlled || WorkStyle.calm => -1,
    _ => 0
  };
  if (p.primaryRole == GroupRole.stage) v++;
  return v.clamp(-1, 4);
}

String finalCutFormatLabel(Day3FinalCutFormat f) => switch (f) {
      Day3FinalCutFormat.coverShot => 'COVER SHOT',
      Day3FinalCutFormat.motionShot => 'MOTION SHOT',
      Day3FinalCutFormat.liveCloseUp => 'LIVE CLOSE-UP'
    };
String finalCutApproachLabel(Day3FinalCutApproach a) =>
    a == Day3FinalCutApproach.perfectFrame ? 'KUSURSUZ KARE' : 'CESUR KARE';
