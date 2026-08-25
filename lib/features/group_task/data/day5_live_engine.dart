import 'dart:math';
import 'package:yildiz_kadro/features/evaluation/domain/evaluation_result.dart';
import 'package:yildiz_kadro/features/group_task/data/group_task_profiles.dart';
import 'package:yildiz_kadro/features/group_task/domain/day2_group_performance.dart';
import 'package:yildiz_kadro/features/group_task/domain/day3_icon_result.dart';
import 'package:yildiz_kadro/features/group_task/domain/day4_position_result.dart';
import 'package:yildiz_kadro/features/group_task/domain/day5_live_result.dart';
import 'package:yildiz_kadro/features/group_task/domain/group_task_profile.dart';

Day5ResultSnapshot calculateDay5Results(
    {required List<int> activeIds,
    required Day5BroadcastDirection direction,
    required Map<int, EvaluationResult> first,
    required Day2GroupPerformanceSnapshot day2,
    required Day3IconResultSnapshot day3,
    required Day4ResultSnapshot day4,
    required Set<int> comebackIds,
    required Set<int> memorableIds}) {
  if (activeIds.length != 9 || activeIds.toSet().length != 9) {
    throw ArgumentError('9 aktif yarışmacı gerekli.');
  }
  final temp = <int, (int, int, int, int, double, double)>{};
  for (final id in activeIds) {
    final f = first[id]!,
        d2 = day2.individualResults[id]!,
        d3 = day3.results[id]!,
        d4 = day4.results[id]!,
        p = groupTaskProfiles[id]!;
    final role = p.primaryRole == GroupRole.vocal ? 1 : 2;
    final live = (f.overall * .20 +
            d2.overall * .20 +
            d3.performance * .15 +
            d4.finalScore * .25 +
            f.stage * .20 +
            role)
        .round()
        .clamp(0, 100);
    final personality = switch (p.workStyle) {
      WorkStyle.cameraSavvy => 5,
      WorkStyle.social || WorkStyle.playful => 4,
      WorkStyle.bold || WorkStyle.instinctive => 3,
      WorkStyle.spontaneous ||
      WorkStyle.sensitive ||
      WorkStyle.calm ||
      WorkStyle.experienced ||
      WorkStyle.direct ||
      WorkStyle.protective =>
        2,
      _ => 1
    };
    final camera = (d3.camera * .35 +
            d3.identity * .25 +
            f.stage * .15 +
            d4.finalScore * .10 +
            75 * .15 +
            personality)
        .round()
        .clamp(0, 100);
    final scores = [f.overall, d2.overall, d3.iconScore, d4.finalScore];
    final average = scores.reduce((a, b) => a + b) / scores.length;
    final variance =
        scores.map((x) => pow(x - average, 2)).reduce((a, b) => a + b) /
            scores.length;
    final consistency = (average - sqrt(variance) * .12).clamp(0, 100);
    final history = (comebackIds.contains(id) ? 4 : 0) +
        (memorableIds.contains(id) ? 4 : 0);
    final fan = (camera * .30 +
            d3.identity * .20 +
            consistency * .20 +
            (70 + history) * .15 +
            (72 + history) * .15 +
            _fanStyle(p.workStyle))
        .round()
        .clamp(0, 100);
    final fit = _directionFit(direction, p, comebackIds.contains(id));
    final base = live * .40 + camera * .30 + fan * .30;
    final raw = (base + fit).clamp(0, 100).toDouble();
    temp[id] = (live, camera, fan, fit, raw, base);
  }
  List<int> rank(bool base) {
    final ids = activeIds.toList()
      ..sort((a, b) {
        final x = temp[a]!, y = temp[b]!;
        var c = (base ? y.$6 : y.$5).compareTo(base ? x.$6 : x.$5);
        if (c != 0) return c;
        c = y.$1.compareTo(x.$1);
        return c != 0 ? c : a.compareTo(b);
      });
    return ids;
  }

  final ranking = rank(false), baseline = rank(true);
  final results = <int, Day5ContestantResult>{};
  for (var i = 0; i < ranking.length; i++) {
    final id = ranking[i], v = temp[id]!;
    results[id] = Day5ContestantResult(
        contestantId: id,
        liveStage: v.$1,
        cameraTalk: v.$2,
        fanConnect: v.$3,
        broadcastFitModifier: v.$4,
        rawLiveScore: v.$5,
        scoreWithoutDirection: v.$6,
        rank: i + 1);
  }
  return Day5ResultSnapshot(
      direction: direction,
      results: Map.unmodifiable(results),
      rankingIds: List.unmodifiable(ranking),
      finalistIds: List.unmodifiable(ranking.take(7)),
      eliminatedIds: List.unmodifiable(ranking.skip(7)),
      playerChangedCut: ranking
          .skip(7)
          .toSet()
          .difference(baseline.skip(7).toSet())
          .isNotEmpty);
}

int _directionFit(Day5BroadcastDirection d, GroupTaskProfile p, bool comeback) {
  if (d == Day5BroadcastDirection.bigStage) {
    return (switch (p.workStyle) {
              WorkStyle.bold => 3,
              WorkStyle.competitive || WorkStyle.experienced => 2,
              WorkStyle.playful ||
              WorkStyle.spontaneous ||
              WorkStyle.cameraSavvy ||
              WorkStyle.controlled =>
                1,
              WorkStyle.sensitive => -1,
              _ => 0
            } +
            (p.primaryRole == GroupRole.dance
                ? 4
                : p.secondaryRole == GroupRole.dance
                    ? 2
                    : p.primaryRole == GroupRole.stage
                        ? 3
                        : 0))
        .clamp(-2, 4);
  }
  if (d == Day5BroadcastDirection.closeCamera) {
    return (switch (p.workStyle) {
              WorkStyle.cameraSavvy => 4,
              WorkStyle.sensitive || WorkStyle.instinctive => 3,
              WorkStyle.calm || WorkStyle.observant || WorkStyle.bold => 2,
              WorkStyle.social ||
              WorkStyle.playful ||
              WorkStyle.controlled =>
                1,
              WorkStyle.chaotic => -1,
              _ => 0
            } +
            (p.primaryRole == GroupRole.stage ? 2 : 0))
        .clamp(-2, 4);
  }
  return ((comeback ? 3 : 0) +
          switch (p.workStyle) {
            WorkStyle.sensitive ||
            WorkStyle.social ||
            WorkStyle.instinctive =>
              2,
            WorkStyle.playful ||
            WorkStyle.protective ||
            WorkStyle.calm ||
            WorkStyle.bold ||
            WorkStyle.cameraSavvy =>
              1,
            _ => 0
          })
      .clamp(-2, 4);
}

int _fanStyle(WorkStyle s) => switch (s) {
      WorkStyle.social || WorkStyle.playful => 3,
      WorkStyle.sensitive ||
      WorkStyle.instinctive ||
      WorkStyle.protective ||
      WorkStyle.cameraSavvy =>
        2,
      WorkStyle.bold ||
      WorkStyle.calm ||
      WorkStyle.spontaneous ||
      WorkStyle.experienced ||
      WorkStyle.chaotic =>
        1,
      _ => 0
    };
