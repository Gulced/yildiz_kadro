import 'dart:math';

import 'package:yildiz_kadro/features/contestants/data/contestant_seed_data.dart';
import 'package:yildiz_kadro/features/contestants/domain/contestant.dart';
import 'package:yildiz_kadro/features/evaluation/domain/evaluation_result.dart';
import 'package:yildiz_kadro/features/group_task/data/group_task_profiles.dart';
import 'package:yildiz_kadro/features/group_task/domain/day2_group_performance.dart';
import 'package:yildiz_kadro/features/group_task/domain/day3_icon_result.dart';
import 'package:yildiz_kadro/features/group_task/domain/day4_position_result.dart';
import 'package:yildiz_kadro/features/group_task/domain/day5_live_result.dart';
import 'package:yildiz_kadro/features/group_task/domain/day6_final_result.dart';
import 'package:yildiz_kadro/features/group_task/domain/group_task_profile.dart';

Day6ResultSnapshot calculateDay6Results({
  required List<int> finalistIds,
  required Day6DebutDirection direction,
  required Map<int, EvaluationResult> first,
  required Day2GroupPerformanceSnapshot day2,
  required Day3IconResultSnapshot day3,
  required Day4ResultSnapshot day4,
  required Day5ResultSnapshot day5,
}) {
  if (finalistIds.length != 7 || finalistIds.toSet().length != 7) {
    throw ArgumentError('7 benzersiz finalist gerekli.');
  }
  final raw = <int,
      ({
    int live,
    int star,
    int growth,
    int consistency,
    int fit,
    int score
  })>{};
  for (final id in finalistIds) {
    final a = first[id]!;
    final b = day2.individualResults[id]!;
    final c = day3.results[id]!;
    final d = day4.results[id]!;
    final e = day5.results[id]!;
    final contestant = _contestant(id);
    final profile = groupTaskProfiles[id]!;
    final live = _round(a.overall * .15 +
        b.overall * .15 +
        c.performance * .10 +
        d.finalScore * .15 +
        e.liveStage * .35 +
        e.cameraTalk * .10);
    final star = _round(c.camera * .30 +
        c.identity * .20 +
        e.fanConnect * .20 +
        a.stage * .15 +
        e.cameraTalk * .15);
    final season = <int>[
      a.overall,
      b.overall,
      c.iconScore,
      d.finalScore,
      e.liveScore
    ];
    final early = (season[0] + season[1]) / 2;
    final late = (season[3] + season[4]) / 2;
    final slope = (season.last - season.first) / 4;
    final growth = _round(74 +
        (late - early) * .75 +
        slope * .65 +
        (_average(season) - 78) * .18);
    final avg = _average(season);
    final deviation = sqrt(
        season.map((v) => pow(v - avg, 2)).reduce((x, y) => x + y) /
            season.length);
    final consistency = _round(avg - deviation * .55 + 8);
    final fit =
        _debutFit(direction, contestant, profile, a, c, e, live, consistency);
    final score = _round(
        live * .25 + star * .25 + growth * .15 + consistency * .15 + fit * .20);
    raw[id] = (
      live: live,
      star: star,
      growth: growth,
      consistency: consistency,
      fit: fit,
      score: score
    );
  }
  final ranking = finalistIds.toList()
    ..sort((a, b) {
      final score = raw[b]!.score.compareTo(raw[a]!.score);
      return score != 0 ? score : a.compareTo(b);
    });
  final results = <int, Day6ContestantResult>{};
  for (var i = 0; i < ranking.length; i++) {
    final id = ranking[i], value = raw[id]!;
    results[id] = Day6ContestantResult(
        contestantId: id,
        live: value.live,
        star: value.star,
        growth: value.growth,
        consistency: value.consistency,
        debutFit: value.fit,
        finalScore: value.score,
        rank: i + 1);
  }
  final combinations = _combinations(finalistIds, 5);
  combinations.sort((a, b) {
    final score = _recommendationScore(b, results, first, day3, day5)
        .compareTo(_recommendationScore(a, results, first, day3, day5));
    if (score != 0) return score;
    return _key(a).compareTo(_key(b));
  });
  return Day6ResultSnapshot(
      direction: direction,
      results: Map.unmodifiable(results),
      rankingIds: List.unmodifiable(ranking),
      recommendedLineupIds: List.unmodifiable(combinations.first));
}

LineupBalance calculateLineupBalance({
  required Iterable<int> lineupIds,
  required Map<int, EvaluationResult> first,
  required Day3IconResultSnapshot day3,
  required Day5ResultSnapshot day5,
}) {
  final ids = lineupIds.toList();
  if (ids.isEmpty) {
    return const LineupBalance(
        vocal: 0, dance: 0, stage: 0, camera: 0, harmony: 0);
  }
  double role(int id, GroupRole target) {
    final profile = groupTaskProfiles[id]!;
    return profile.primaryRole == target
        ? 4
        : profile.secondaryRole == target
            ? 2
            : 0;
  }

  final vocal = _round(_average(ids.map((id) =>
      _contestant(id).vocal * .45 +
      first[id]!.vocal * .30 +
      day5.results[id]!.liveStage * .25 +
      role(id, GroupRole.vocal))));
  final dance = _round(_average(ids.map((id) =>
      _contestant(id).dance * .55 +
      first[id]!.dance * .30 +
      day5.results[id]!.liveStage * .15 +
      role(id, GroupRole.dance))));
  final stage = _round(_average(ids.map((id) =>
      first[id]!.stage * .40 +
      day5.results[id]!.liveStage * .35 +
      _contestant(id).stage * .25 +
      role(id, GroupRole.stage))));
  final camera = _round(_average(ids.map((id) =>
      day3.results[id]!.camera * .50 +
      day5.results[id]!.cameraTalk * .40 +
      (groupTaskProfiles[id]!.workStyle == WorkStyle.cameraSavvy ? 8 : 0))));
  final styles = ids.map((id) => groupTaskProfiles[id]!.workStyle).toList();
  final uniqueRoles =
      ids.map((id) => groupTaskProfiles[id]!.primaryRole).toSet().length;
  final calming = styles
      .where((s) =>
          s == WorkStyle.calm ||
          s == WorkStyle.social ||
          s == WorkStyle.experienced ||
          s == WorkStyle.protective)
      .length;
  final intense = styles
      .where((s) =>
          s == WorkStyle.competitive ||
          s == WorkStyle.direct ||
          s == WorkStyle.chaotic)
      .length;
  final harmony =
      _round(78 + uniqueRoles * 2.2 + calming * 1.6 - max(0, intense - 2) * 3);
  return LineupBalance(
      vocal: vocal,
      dance: dance,
      stage: stage,
      camera: camera,
      harmony: harmony);
}

Map<FinalGroupRole, int> assignSuggestedRoles({
  required List<int> lineupIds,
  required Day6ResultSnapshot finalResult,
  required Map<int, EvaluationResult> first,
  required Day3IconResultSnapshot day3,
  required Day4ResultSnapshot day4,
  required Day5ResultSnapshot day5,
}) {
  if (lineupIds.length != 5 || lineupIds.toSet().length != 5) {
    throw ArgumentError('5 üye gerekli.');
  }
  final roles = FinalGroupRole.values;
  List<int>? best;
  var bestScore = -1.0;
  for (final permutation in _permutations(lineupIds)) {
    var total = 0.0;
    for (var i = 0; i < roles.length; i++) {
      total += _roleFit(
          roles[i], permutation[i], finalResult, first, day3, day4, day5);
    }
    if (total > bestScore ||
        (total == bestScore &&
            _key(permutation).compareTo(_key(best ?? permutation)) < 0)) {
      bestScore = total;
      best = permutation;
    }
  }
  return Map.unmodifiable(
      {for (var i = 0; i < roles.length; i++) roles[i]: best![i]});
}

int _debutFit(
    Day6DebutDirection direction,
    Contestant contestant,
    GroupTaskProfile profile,
    EvaluationResult first,
    Day3IconContestantResult day3,
    Day5ContestantResult day5,
    int live,
    int consistency) {
  final primary = profile.primaryRole,
      secondary = profile.secondaryRole,
      style = profile.workStyle;
  final value = switch (direction) {
    Day6DebutDirection.popPower => contestant.vocal * .30 +
        ((contestant.vocal + contestant.dance + contestant.stage) / 3) * .20 +
        live * .20 +
        first.stage * .15 +
        consistency * .15 +
        (primary == GroupRole.vocal || primary == GroupRole.allRounder
            ? 3
            : 0) +
        (secondary == GroupRole.vocal ? 1 : 0) +
        (primary == GroupRole.stage ? 1 : 0),
    Day6DebutDirection.performanceUnit => contestant.dance * .30 +
        first.stage * .25 +
        live * .20 +
        day3.camera * .10 +
        consistency * .15 +
        (primary == GroupRole.dance
            ? 3
            : primary == GroupRole.stage
                ? 2
                : 0) +
        ({
          WorkStyle.bold,
          WorkStyle.competitive,
          WorkStyle.experienced,
          WorkStyle.playful
        }.contains(style)
            ? 2
            : 0),
    Day6DebutDirection.iconGroup => day3.camera * .30 +
        day3.identity * .25 +
        day5.fanConnect * .20 +
        first.stage * .15 +
        live * .10 +
        (style == WorkStyle.cameraSavvy ? 3 : 0) +
        (primary == GroupRole.stage ? 2 : 0) +
        ({WorkStyle.bold, WorkStyle.instinctive}.contains(style) ? 2 : 0),
  };
  return _round(value);
}

double _recommendationScore(
    List<int> ids,
    Map<int, Day6ContestantResult> results,
    Map<int, EvaluationResult> first,
    Day3IconResultSnapshot day3,
    Day5ResultSnapshot day5) {
  final balance = calculateLineupBalance(
      lineupIds: ids, first: first, day3: day3, day5: day5);
  final individual = _average(ids.map((id) => results[id]!.finalScore));
  final groupBalance = _average([
    balance.vocal,
    balance.dance,
    balance.stage,
    balance.camera,
    balance.harmony
  ]);
  final coverage =
      ids.map((id) => groupTaskProfiles[id]!.primaryRole).toSet().length /
          GroupRole.values.length *
          100;
  return individual * .55 +
      groupBalance * .25 +
      coverage * .10 +
      balance.harmony * .10;
}

double _roleFit(
    FinalGroupRole role,
    int id,
    Day6ResultSnapshot result,
    Map<int, EvaluationResult> first,
    Day3IconResultSnapshot day3,
    Day4ResultSnapshot day4,
    Day5ResultSnapshot day5) {
  final contestant = _contestant(id),
      profile = groupTaskProfiles[id]!,
      finalScore = result.results[id]!;
  return switch (role) {
    FinalGroupRole.mainVocal => contestant.vocal * .35 +
        first[id]!.vocal * .25 +
        day5.results[id]!.liveStage * .25 +
        finalScore.consistency * .15 +
        (profile.primaryRole == GroupRole.vocal ? 5 : 0),
    FinalGroupRole.center => day3.results[id]!.camera * .25 +
        first[id]!.stage * .20 +
        day3.results[id]!.identity * .20 +
        finalScore.star * .35 +
        (profile.workStyle == WorkStyle.cameraSavvy ? 4 : 0),
    FinalGroupRole.performanceLead => contestant.dance * .30 +
        first[id]!.stage * .20 +
        day4.results[id]!.finalScore * .20 +
        day5.results[id]!.liveStage * .30,
    FinalGroupRole.allRounder =>
      (contestant.vocal + contestant.dance + contestant.stage) / 3 * .65 +
          finalScore.consistency * .35 +
          (profile.primaryRole == GroupRole.allRounder ? 5 : 0),
    FinalGroupRole.starVisual => day3.results[id]!.camera * .25 +
        day3.results[id]!.identity * .20 +
        day5.results[id]!.fanConnect * .25 +
        finalScore.star * .30,
  };
}

Contestant _contestant(int id) =>
    contestantSeedData.firstWhere((value) => value.id == id);
int _round(num value) => value.round().clamp(0, 100);
double _average(Iterable<num> values) {
  final list = values.toList();
  return list.fold<double>(0, (sum, value) => sum + value) / list.length;
}

String _key(List<int> ids) =>
    (ids.toList()..sort()).map((id) => id.toString().padLeft(2, '0')).join();
List<List<int>> _combinations(List<int> source, int count, [int start = 0]) {
  if (count == 0) return [<int>[]];
  final result = <List<int>>[];
  for (var i = start; i <= source.length - count; i++) {
    for (final tail in _combinations(source, count - 1, i + 1)) {
      result.add([source[i], ...tail]);
    }
  }
  return result;
}

List<List<int>> _permutations(List<int> source) {
  if (source.length <= 1) return [source.toList()];
  final result = <List<int>>[];
  for (var i = 0; i < source.length; i++) {
    final rest = source.toList()..removeAt(i);
    for (final tail in _permutations(rest)) {
      result.add([source[i], ...tail]);
    }
  }
  return result;
}
