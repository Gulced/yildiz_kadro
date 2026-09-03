import 'package:yildiz_kadro/l10n/l10n.dart';
import 'package:flutter/widgets.dart';
import 'package:yildiz_kadro/features/evaluation/domain/evaluation_result.dart';
import 'package:yildiz_kadro/features/group_task/data/group_task_profiles.dart';
import 'package:yildiz_kadro/features/group_task/domain/day2_group_performance.dart';
import 'package:yildiz_kadro/features/group_task/domain/day2_jury_result.dart';
import 'package:yildiz_kadro/features/group_task/domain/group_task_profile.dart';
import 'package:yildiz_kadro/features/last_chance/domain/last_chance_result.dart';

Day2JuryResultSnapshot calculateDay2JuryResult({
  required List<int> juryRiskIds,
  required Map<int, EvaluationResult> firstEvaluationResults,
  required Map<int, LastChanceResult> lastChanceResults,
  required int? coachedContestantId,
  required Day2GroupPerformanceSnapshot groupPerformance,
}) {
  if (juryRiskIds.length != 3 || juryRiskIds.toSet().length != 3) {
    throw ArgumentError('Jüri risk listesinde 3 benzersiz yarışmacı olmalı.');
  }
  final evaluations = <int, Day2JuryEvaluationResult>{};
  for (final id in juryRiskIds) {
    final first = firstEvaluationResults[id]!;
    final day2 = groupPerformance.individualResults[id]!;
    final lastChance = lastChanceResults[id];
    final performance = day2.overall;
    final development = lastChance == null
        ? (78 + (performance - first.overall) * 2).clamp(60, 98)
        : _lastChanceDevelopment(
            first.overall,
            lastChance.finalScore(coached: coachedContestantId == id),
            performance,
          );
    final profile = groupTaskProfiles[id]!;
    final teamResult = day2.teamId == 'A'
        ? groupPerformance.teamAResult
        : groupPerformance.teamBResult;
    final isSpotlight = day2.assignedRole == 'CENTER' ||
        day2.assignedRole.startsWith('LEAD') ||
        day2.assignedRole == 'ANA VOKAL' ||
        day2.assignedRole == 'DANS LİDERİ';
    final potential = (first.stage * .50 +
            first.overall * .30 +
            day2.stage * .20 +
            _workStyleModifier(profile.workStyle) +
            (teamResult.starContestantId == id ? 2 : 0) +
            (isSpotlight ? 1 : 0))
        .round()
        .clamp(0, 100);
    evaluations[id] = Day2JuryEvaluationResult(
      contestantId: id,
      performanceScore: performance,
      developmentScore: development,
      potentialScore: potential,
      rawJuryScore: performance * .45 + development * .30 + potential * .25,
    );
  }
  final ranking = juryRiskIds.toList()
    ..sort((a, b) {
      final x = evaluations[a]!;
      final y = evaluations[b]!;
      var result = y.rawJuryScore.compareTo(x.rawJuryScore);
      if (result != 0) return result;
      result = y.performanceScore.compareTo(x.performanceScore);
      if (result != 0) return result;
      result = y.developmentScore.compareTo(x.developmentScore);
      if (result != 0) return result;
      result = y.potentialScore.compareTo(x.potentialScore);
      if (result != 0) return result;
      result = groupPerformance.individualResults[b]!.stage.compareTo(
        groupPerformance.individualResults[a]!.stage,
      );
      if (result != 0) return result;
      result = firstEvaluationResults[b]!.overall.compareTo(
            firstEvaluationResults[a]!.overall,
          );
      return result != 0 ? result : a.compareTo(b);
    });
  return Day2JuryResultSnapshot(
    evaluations: Map.unmodifiable(evaluations),
    rankingIds: List.unmodifiable(ranking),
    savedContestantId: ranking.first,
    duelContestantIds: List.unmodifiable(ranking.skip(1).toList()),
  );
}

int _lastChanceDevelopment(int first, int lastChance, int day2) {
  final weighted = first * .35 + lastChance * .25 + day2 * .40;
  final trend = (lastChance - first) * .7 + (day2 - lastChance) * 1.1;
  return (weighted + trend).round().clamp(60, 98);
}

int _workStyleModifier(WorkStyle style) => switch (style) {
      WorkStyle.cameraSavvy => 3,
      WorkStyle.bold => 2,
      WorkStyle.competitive ||
      WorkStyle.spontaneous ||
      WorkStyle.playful ||
      WorkStyle.experienced ||
      WorkStyle.instinctive =>
        1,
      WorkStyle.chaotic => -1,
      _ => 0,
    };

String juryCategoryComment(
  String category,
  int score, [
  BuildContext? context,
]) {
  final isEn = isAppEnglish(context);
  final cat = category.toUpperCase();
  if (cat == 'PERFORMANS' || cat == 'PERFORMANCE') {
    if (score >= 90) {
      return isEn
          ? 'Tonight you outshone the team’s overall score.'
          : 'Bu gece takım sonucundan daha iyiydin.';
    }
    if (score >= 85) {
      return isEn
          ? 'You delivered a solid stage that keeps you firmly in the game.'
          : 'Kendini oyunda tutacak bir performans verdin.';
    }
    if (score >= 80) {
      return isEn
          ? 'You had clean moments, but failed to seize command.'
          : 'Temiz anların vardı ama yeterince öne çıkamadın.';
    }
    return isEn
        ? 'Tonight you faded into the background.'
        : 'Bu gece geri planda kaldın.';
  }
  if (cat == 'GELİŞİM' || cat == 'GROWTH' || cat == 'DEVELOPMENT') {
    if (score >= 90) {
      return isEn
          ? 'You are lightyears ahead of where you started.'
          : 'Yarışmaya başladığın yerle bugün aynı yerde değilsin.';
    }
    if (score >= 85) {
      return isEn
          ? 'Your continuous growth is undeniable.'
          : 'Gelişimin görünür.';
    }
    if (score >= 80) {
      return isEn
          ? 'There is progress, but you lack consistency.'
          : 'İlerleme var ama henüz istikrarlı değil.';
    }
    return isEn
        ? 'The jury demands a sharper transformation from you.'
        : 'Jüri senden daha hızlı bir değişim bekliyor.';
  }
  if (score >= 92) {
    return isEn
        ? 'The jury envisions a long-term commercial pop star in you.'
        : 'Jüri sende uzun vadeli bir yıldız görüyor.';
  }
  if (score >= 87) {
    return isEn
        ? 'With the right mentorship, your ceiling is limitless.'
        : 'Doğru yönlendirmeyle çok daha fazlası olabilir.';
  }
  if (score >= 82) {
    return isEn
        ? 'The raw potential is there, but hasn’t translated into stage dominance.'
        : 'Potansiyel var ama henüz sahneye tam yansımıyor.';
  }
  return isEn
      ? 'Staying in this competition now requires more than just raw potential.'
      : 'Yarışmada kalmak için artık potansiyelden fazlası gerekiyor.';
}
