import 'package:yildiz_kadro/l10n/l10n.dart';
import 'package:flutter/widgets.dart';
import 'package:yildiz_kadro/features/evaluation/domain/evaluation_result.dart';
import 'package:yildiz_kadro/features/group_task/data/group_task_profiles.dart';
import 'package:yildiz_kadro/features/group_task/domain/day2_duel_result.dart';
import 'package:yildiz_kadro/features/group_task/domain/day2_group_performance.dart';
import 'package:yildiz_kadro/features/group_task/domain/day2_jury_result.dart';
import 'package:yildiz_kadro/features/group_task/domain/group_task_profile.dart';

Day2DuelResultSnapshot calculateDay2DuelResult({
  required List<int> contestantIds,
  required Day2DuelConcept concept,
  required Day2DuelApproach approach,
  required Day2DuelCoaching coaching,
  required Map<int, EvaluationResult> firstResults,
  required Day2GroupPerformanceSnapshot groupPerformance,
  required Day2JuryResultSnapshot jury,
  Map<int, int> moraleByContestant = const {},
  Map<int, int> professionalismByContestant = const {},
}) {
  if (contestantIds.length != 2 || contestantIds.toSet().length != 2) {
    throw ArgumentError('Düelloda 2 benzersiz yarışmacı olmalı.');
  }
  final results = <int, DuelContestantResult>{};
  for (final id in contestantIds) {
    final first = firstResults[id]!;
    final day2 = groupPerformance.individualResults[id]!;
    final juryResult = jury.evaluations[id]!;
    final profile = groupTaskProfiles[id]!;
    final vocal = (first.vocal * .45 +
            day2.vocal * .40 +
            juryResult.performanceScore * .15)
        .round()
        .clamp(0, 100);
    final dance = (first.dance * .45 +
            day2.dance * .40 +
            juryResult.performanceScore * .15)
        .round()
        .clamp(0, 100);
    final stage =
        (first.stage * .40 + day2.stage * .45 + juryResult.potentialScore * .15)
            .round()
            .clamp(0, 100);
    final base = switch (concept) {
      Day2DuelConcept.vocal =>
        vocal * .50 + dance * .15 + stage * .25 + juryResult.juryScore * .10,
      Day2DuelConcept.dance =>
        dance * .50 + vocal * .15 + stage * .25 + juryResult.juryScore * .10,
      Day2DuelConcept.stage =>
        stage * .50 + vocal * .20 + dance * .20 + juryResult.juryScore * .10,
    };
    final conceptFit = _conceptFit(concept, profile);
    final approachFit = _approachFit(approach, profile);
    final coachingFit = _coachingFit(
      coaching,
      first,
      profile,
      juryResult.developmentScore,
    );
    final formModifier = _formModifier(
      moraleByContestant[id],
      professionalismByContestant[id],
    );
    results[id] = DuelContestantResult(
      contestantId: id,
      vocal: vocal,
      dance: dance,
      stage: stage,
      conceptFitModifier: conceptFit,
      approachModifier: approachFit,
      coachingModifier: coachingFit,
      formModifier: formModifier,
      rawScore: (base + conceptFit + approachFit + coachingFit + formModifier)
          .clamp(0, 100),
      scoreWithoutPlayerModifiers: base.clamp(0, 100),
    );
  }
  int compare(int a, int b, {required bool baseline}) {
    final x = results[a]!;
    final y = results[b]!;
    var result = (baseline ? y.scoreWithoutPlayerModifiers : y.rawScore)
        .compareTo(baseline ? x.scoreWithoutPlayerModifiers : x.rawScore);
    if (result != 0) return result;
    final mainX = concept == Day2DuelConcept.vocal
        ? x.vocal
        : concept == Day2DuelConcept.dance
            ? x.dance
            : x.stage;
    final mainY = concept == Day2DuelConcept.vocal
        ? y.vocal
        : concept == Day2DuelConcept.dance
            ? y.dance
            : y.stage;
    result = mainY.compareTo(mainX);
    if (result != 0) return result;
    result = y.stage.compareTo(x.stage);
    if (result != 0) return result;
    result = jury.evaluations[b]!.juryScore.compareTo(
      jury.evaluations[a]!.juryScore,
    );
    if (result != 0) return result;
    result = jury.evaluations[b]!.developmentScore.compareTo(
      jury.evaluations[a]!.developmentScore,
    );
    if (result != 0) return result;
    result = firstResults[b]!.overall.compareTo(firstResults[a]!.overall);
    return result != 0 ? result : a.compareTo(b);
  }

  final ranking = contestantIds.toList()
    ..sort((a, b) => compare(a, b, baseline: false));
  final baseline = contestantIds.toList()
    ..sort((a, b) => compare(a, b, baseline: true));
  final order = contestantIds.toList()
    ..sort((a, b) {
      final score = jury.evaluations[a]!.juryScore.compareTo(
        jury.evaluations[b]!.juryScore,
      );
      return score != 0 ? score : a.compareTo(b);
    });
  return Day2DuelResultSnapshot(
    concept: concept,
    approach: approach,
    coaching: coaching,
    results: Map.unmodifiable(results),
    performanceOrderIds: List.unmodifiable(order),
    winnerContestantId: ranking.first,
    eliminatedContestantId: ranking.last,
    playerChangedOutcome: ranking.first != baseline.first,
  );
}

int _formModifier(int? morale, int? professionalism) {
  if (morale == null && professionalism == null) return 0;
  final moraleEffect = morale == null
      ? 0
      : morale >= 82
          ? 2
          : morale < 52
              ? -2
              : 0;
  final professionalEffect = professionalism == null
      ? 0
      : professionalism >= 88
          ? 1
          : professionalism < 55
              ? -1
              : 0;
  return (moraleEffect + professionalEffect).clamp(-3, 3);
}

int _conceptFit(Day2DuelConcept concept, GroupTaskProfile profile) {
  final role = switch (concept) {
    Day2DuelConcept.vocal => GroupRole.vocal,
    Day2DuelConcept.dance => GroupRole.dance,
    Day2DuelConcept.stage => GroupRole.stage,
  };
  var value = profile.primaryRole == role
      ? 3
      : profile.secondaryRole == role
          ? 1
          : 0;
  if (concept == Day2DuelConcept.stage &&
      profile.workStyle == WorkStyle.cameraSavvy) {
    value++;
  }
  return value;
}

int _approachFit(Day2DuelApproach approach, GroupTaskProfile profile) {
  if (approach == Day2DuelApproach.clean) {
    var value = switch (profile.workStyle) {
      WorkStyle.controlled => 4,
      WorkStyle.calm || WorkStyle.experienced => 3,
      WorkStyle.observant || WorkStyle.direct => 2,
      WorkStyle.sensitive || WorkStyle.protective => 1,
      WorkStyle.chaotic => -2,
      WorkStyle.spontaneous => -1,
      _ => 0,
    };
    if (profile.primaryRole == GroupRole.allRounder ||
        profile.secondaryRole == GroupRole.allRounder) {
      value++;
    }
    return value.clamp(-2, 4);
  }
  var value = switch (profile.workStyle) {
    WorkStyle.bold || WorkStyle.cameraSavvy => 4,
    WorkStyle.competitive || WorkStyle.spontaneous => 3,
    WorkStyle.playful || WorkStyle.instinctive => 2,
    WorkStyle.chaotic || WorkStyle.experienced || WorkStyle.direct => 1,
    WorkStyle.controlled || WorkStyle.calm => -1,
    _ => 0,
  };
  if (profile.primaryRole == GroupRole.stage) {
    value++;
  }
  return value.clamp(-1, 4);
}

int _coachingFit(
  Day2DuelCoaching coaching,
  EvaluationResult first,
  GroupTaskProfile profile,
  int development,
) {
  if (coaching == Day2DuelCoaching.technique) {
    var value = (first.vocal >= 90 || first.dance >= 90) ? 3 : 1;
    if (profile.primaryRole == GroupRole.vocal ||
        profile.primaryRole == GroupRole.dance) {
      value++;
    }
    if (profile.workStyle == WorkStyle.controlled ||
        profile.workStyle == WorkStyle.experienced) {
      value++;
    }
    return value.clamp(0, 4);
  }
  if (coaching == Day2DuelCoaching.showYourself) {
    var value = first.stage >= 95
        ? 4
        : first.stage >= 90
            ? 3
            : first.stage >= 85
                ? 2
                : 1;
    if (profile.primaryRole == GroupRole.stage) {
      value = value.clamp(3, 4);
    }
    if (profile.workStyle == WorkStyle.cameraSavvy) {
      value++;
    }
    return value.clamp(0, 4);
  }
  var value = development >= 90
      ? 4
      : development >= 85
          ? 3
          : development >= 80
              ? 2
              : 1;
  if (profile.workStyle == WorkStyle.sensitive ||
      profile.workStyle == WorkStyle.instinctive ||
      profile.workStyle == WorkStyle.spontaneous) {
    value++;
  }
  return value.clamp(0, 4);
}

String duelConceptLabel(Day2DuelConcept value, [BuildContext? context]) {
  final isEn = isAppEnglish(context);
  return switch (value) {
    Day2DuelConcept.vocal => isEn ? 'VOCAL-FOCUSED' : 'VOKAL ODAKLI',
    Day2DuelConcept.dance => isEn ? 'DANCE-FOCUSED' : 'DANS ODAKLI',
    Day2DuelConcept.stage => isEn ? 'STAGE-FOCUSED' : 'SAHNE ODAKLI',
  };
}

String duelApproachLabel(Day2DuelApproach value, [BuildContext? context]) {
  final isEn = isAppEnglish(context);
  return value == Day2DuelApproach.clean
      ? (isEn ? 'CLEAN EXECUTION' : 'TEMİZ PERFORMANS')
      : (isEn ? 'STAR MOMENT' : 'YILDIZ ANI');
}

String duelCoachingLabel(Day2DuelCoaching value, [BuildContext? context]) {
  final isEn = isAppEnglish(context);
  return switch (value) {
    Day2DuelCoaching.technique =>
      isEn ? 'TRUST YOUR TECHNIQUE' : 'TEKNİĞİNE GÜVEN',
    Day2DuelCoaching.showYourself =>
      isEn ? 'SHOW YOUR IDENTITY' : 'KENDİNİ GÖSTER',
    Day2DuelCoaching.tellStory => isEn ? 'TELL A STORY' : 'HİKÂYE ANLAT',
  };
}
