import 'package:yildiz_kadro/l10n/l10n.dart';
import 'package:flutter/widgets.dart';
import 'package:yildiz_kadro/features/evaluation/domain/evaluation_result.dart';
import 'package:yildiz_kadro/features/group_task/data/group_task_profiles.dart';
import 'package:yildiz_kadro/features/group_task/domain/day3_identity_setup.dart';
import 'package:yildiz_kadro/features/group_task/domain/group_task_profile.dart';

Day3IdentityAllocation allocateDay3Concepts({
  required List<int> activeContestantIds,
  required Map<int, EvaluationResult> evaluationResults,
  required Map<int, double> day2Scores,
}) {
  if (activeContestantIds.length != 13 ||
      activeContestantIds.toSet().length != 13) {
    throw ArgumentError('Day 3 için 13 aktif yarışmacı gerekli.');
  }
  final order = activeContestantIds.toList()
    ..sort((a, b) {
      final score = (day2Scores[b] ?? 0).compareTo(day2Scores[a] ?? 0);
      return score != 0 ? score : a.compareTo(b);
    });
  final counts = {for (final concept in Day3Concept.values) concept: 0};
  final concepts = <int, Day3Concept>{};
  final fits = <int, int>{};
  final self = <int, Day3SelfDirectionModifiers>{};
  for (final id in order) {
    final profile = groupTaskProfiles[id]!;
    final evaluation = evaluationResults[id]!;
    final ranked = Day3Concept.values.toList()
      ..sort((a, b) {
        final result = _fit(
          b,
          profile,
          evaluation,
        ).compareTo(_fit(a, profile, evaluation));
        return result != 0 ? result : a.index.compareTo(b.index);
      });
    final selected = ranked.firstWhere((concept) => counts[concept]! < 4);
    concepts[id] = selected;
    fits[id] = _fit(selected, profile, evaluation);
    counts[selected] = counts[selected]! + 1;
    self[id] = _selfDirection(profile.workStyle);
  }
  return Day3IdentityAllocation(
    conceptByContestantId: Map.unmodifiable(concepts),
    conceptFitByContestantId: Map.unmodifiable(fits),
    selfDirectionByContestantId: Map.unmodifiable(self),
  );
}

Day3IdentitySetupSnapshot createDay3IdentitySetup({
  required Day3IdentityAllocation allocation,
  required Map<int, Day3CreativeDirection> directions,
  required Map<int, EvaluationResult> evaluationResults,
}) {
  if (directions.length != 3 ||
      directions.keys.toSet().length != 3 ||
      !allocation.conceptByContestantId.keys.toSet().containsAll(
            directions.keys,
          )) {
    throw ArgumentError('Tam olarak 3 aktif yarışmacı yönlendirilmeli.');
  }
  final modifiers = <int, int>{};
  for (final entry in directions.entries) {
    modifiers[entry.key] = creativeDirectionModifier(
      contestantId: entry.key,
      direction: entry.value,
      allocation: allocation,
      evaluation: evaluationResults[entry.key]!,
    );
  }
  return Day3IdentitySetupSnapshot(
    allocation: allocation,
    creativeDirectionByContestantId: Map.unmodifiable(directions),
    creativeModifierByContestantId: Map.unmodifiable(modifiers),
    stylingSupportContestantIds: List.unmodifiable(directions.keys),
  );
}

int creativeDirectionModifier({
  required int contestantId,
  required Day3CreativeDirection direction,
  required Day3IdentityAllocation allocation,
  required EvaluationResult evaluation,
}) {
  final profile = groupTaskProfiles[contestantId]!;
  final fit = allocation.conceptFitByContestantId[contestantId]!;
  if (direction == Day3CreativeDirection.sharpenIdentity) {
    var value = fit >= 82
        ? 4
        : fit >= 77
            ? 3
            : 2;
    if (profile.workStyle == WorkStyle.controlled ||
        profile.workStyle == WorkStyle.experienced ||
        profile.workStyle == WorkStyle.direct) {
      value++;
    }
    return value.clamp(0, 5);
  }
  if (direction == Day3CreativeDirection.surprise) {
    return switch (profile.workStyle) {
      WorkStyle.bold || WorkStyle.spontaneous => 5,
      WorkStyle.chaotic || WorkStyle.playful => 4,
      WorkStyle.competitive || WorkStyle.instinctive => 3,
      WorkStyle.cameraSavvy => 2,
      WorkStyle.controlled || WorkStyle.calm => -1,
      WorkStyle.experienced => 1,
      _ => 0,
    };
  }
  var value = evaluation.stage >= 95
      ? 5
      : evaluation.stage >= 90
          ? 4
          : evaluation.stage >= 85
              ? 3
              : 2;
  if (profile.workStyle == WorkStyle.cameraSavvy) value++;
  if (profile.primaryRole == GroupRole.stage) value = value.clamp(3, 5);
  return value.clamp(0, 5);
}

int _fit(Day3Concept concept, GroupTaskProfile p, EvaluationResult e) {
  var score = 70;
  switch (concept) {
    case Day3Concept.popIcon:
      if (p.primaryRole == GroupRole.allRounder) score += 5;
      if (p.primaryRole == GroupRole.stage) score += 3;
      if (p.secondaryRole == GroupRole.allRounder) score += 2;
      score += switch (p.workStyle) {
        WorkStyle.playful => 4,
        WorkStyle.bold || WorkStyle.cameraSavvy => 3,
        WorkStyle.social => 2,
        WorkStyle.instinctive => 1,
        _ => 0,
      };
      if (e.stage >= 90) score += 2;
      break;
    case Day3Concept.highFashion:
      if (p.primaryRole == GroupRole.stage) score += 4;
      if (p.primaryRole == GroupRole.dance) score += 3;
      score += switch (p.workStyle) {
        WorkStyle.cameraSavvy => 5,
        WorkStyle.controlled || WorkStyle.direct => 3,
        WorkStyle.experienced || WorkStyle.observant => 2,
        _ => 0,
      };
      if (e.stage >= 94) score += 2;
      break;
    case Day3Concept.romanticStar:
      if (p.primaryRole == GroupRole.vocal) score += 5;
      if (p.secondaryRole == GroupRole.vocal) score += 2;
      score += switch (p.workStyle) {
        WorkStyle.sensitive => 4,
        WorkStyle.calm => 3,
        WorkStyle.protective || WorkStyle.instinctive => 2,
        _ => 0,
      };
      if (e.vocal >= 88) score += 2;
      break;
    case Day3Concept.rebelEdge:
      if (p.primaryRole == GroupRole.stage ||
          p.primaryRole == GroupRole.dance) {
        score += 3;
      }
      score += switch (p.workStyle) {
        WorkStyle.bold => 5,
        WorkStyle.competitive || WorkStyle.spontaneous => 4,
        WorkStyle.chaotic => 3,
        _ => 0,
      };
      if (e.stage >= 92) score += 2;
      break;
    case Day3Concept.dreamyCinema:
      if (p.primaryRole == GroupRole.stage ||
          p.primaryRole == GroupRole.vocal) {
        score += 2;
      }
      score += switch (p.workStyle) {
        WorkStyle.observant || WorkStyle.instinctive => 4,
        WorkStyle.sensitive || WorkStyle.cameraSavvy => 3,
        WorkStyle.calm => 2,
        _ => 0,
      };
      if (e.stage >= 90) score += 2;
      break;
  }
  return score;
}

Day3SelfDirectionModifiers _selfDirection(WorkStyle style) => switch (style) {
      WorkStyle.controlled => const Day3SelfDirectionModifiers(consistency: 2),
      WorkStyle.experienced => const Day3SelfDirectionModifiers(styling: 2),
      WorkStyle.bold ||
      WorkStyle.spontaneous =>
        const Day3SelfDirectionModifiers(originality: 2),
      WorkStyle.cameraSavvy => const Day3SelfDirectionModifiers(camera: 2),
      WorkStyle.playful => const Day3SelfDirectionModifiers(
          originality: 1,
          camera: 1,
        ),
      WorkStyle.calm ||
      WorkStyle.protective =>
        const Day3SelfDirectionModifiers(consistency: 1),
      WorkStyle.sensitive => const Day3SelfDirectionModifiers(identity: 1),
      WorkStyle.observant => const Day3SelfDirectionModifiers(styling: 1),
      WorkStyle.direct => const Day3SelfDirectionModifiers(consistency: 2),
      WorkStyle.chaotic => const Day3SelfDirectionModifiers(
          originality: 2,
          consistency: -1,
        ),
      WorkStyle.instinctive => const Day3SelfDirectionModifiers(
          camera: 1,
          identity: 1,
        ),
      WorkStyle.competitive => const Day3SelfDirectionModifiers(
          camera: 1,
          performance: 1,
        ),
      WorkStyle.social => const Day3SelfDirectionModifiers(camera: 1),
    };

String day3ConceptLabel(Day3Concept value) => switch (value) {
      Day3Concept.popIcon => 'POP ICON',
      Day3Concept.highFashion => 'HIGH FASHION',
      Day3Concept.romanticStar => 'ROMANTIC STAR',
      Day3Concept.rebelEdge => 'REBEL EDGE',
      Day3Concept.dreamyCinema => 'DREAMY CINEMA',
    };
String day3FitLabel(int fit, [BuildContext? context]) {
  final isEn = isAppEnglish(context);
  return fit >= 82
      ? (isEn ? 'NATURAL MATCH' : 'DOĞAL EŞLEŞME')
      : fit >= 77
          ? (isEn ? 'STRONG CHOICE' : 'GÜÇLÜ SEÇİM')
          : (isEn ? 'RISKY CHOICE' : 'RİSKLİ SEÇİM');
}

String day3DirectionLabel(
  Day3CreativeDirection value, [
  BuildContext? context,
]) {
  final isEn = isAppEnglish(context);
  return switch (value) {
    Day3CreativeDirection.sharpenIdentity =>
      isEn ? 'SHARPEN IDENTITY' : 'KİMLİĞİNİ KESKİNLEŞTİR',
    Day3CreativeDirection.surprise => isEn ? 'SURPRISE TWIST' : 'TERS KÖŞE YAP',
    Day3CreativeDirection.ownCamera =>
      isEn ? 'OWN THE CAMERA' : 'KAMERAYI SAHİPLEN',
  };
}
