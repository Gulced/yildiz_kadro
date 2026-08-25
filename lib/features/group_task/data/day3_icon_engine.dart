import 'package:yildiz_kadro/features/evaluation/domain/evaluation_result.dart';
import 'package:yildiz_kadro/features/group_task/domain/day3_icon_result.dart';
import 'package:yildiz_kadro/features/group_task/domain/day3_identity_setup.dart';

Day3IconResultSnapshot calculateDay3IconResults(
    {required List<int> activeIds,
    required Map<int, EvaluationResult> firstResults,
    required Map<int, double> day2Scores,
    required Day3IdentitySetupSnapshot setup}) {
  final results = <int, Day3IconContestantResult>{};
  for (final id in activeIds) {
    final first = firstResults[id]!;
    final fit = setup.allocation.conceptFitByContestantId[id]!;
    final self = setup.allocation.selfDirectionByContestantId[id]!;
    final directed = setup.creativeModifierByContestantId[id] ?? 0;
    final supported = setup.stylingSupportContestantIds.contains(id);
    final identity =
        (fit + self.identity + self.consistency + directed).clamp(0, 100);
    final styling = (72 +
            (first.stage - 80) * .25 +
            self.styling +
            (supported ? 2 : 0) +
            directed * .5)
        .round()
        .clamp(0, 100);
    final camera =
        (first.stage * .75 + first.overall * .25 + self.camera + directed)
            .round()
            .clamp(0, 100);
    final performance = ((day2Scores[id] ?? first.overall) * .65 +
            first.overall * .35 +
            self.performance)
        .round()
        .clamp(0, 100);
    final raw =
        identity * .28 + styling * .22 + camera * .28 + performance * .22;
    results[id] = Day3IconContestantResult(
        contestantId: id,
        identity: identity,
        styling: styling,
        camera: camera,
        performance: performance,
        rawIconScore: raw);
  }
  final ranking = activeIds.toList()
    ..sort((a, b) {
      final score =
          results[b]!.rawIconScore.compareTo(results[a]!.rawIconScore);
      return score != 0 ? score : a.compareTo(b);
    });
  final bottom = ranking.skip(ranking.length - 4).toList();
  final bottomRanked = bottom.toList()
    ..sort((a, b) {
      final score =
          results[b]!.rawIconScore.compareTo(results[a]!.rawIconScore);
      return score != 0 ? score : a.compareTo(b);
    });
  return Day3IconResultSnapshot(
      results: Map.unmodifiable(results),
      rankingIds: List.unmodifiable(ranking),
      bottom4Ids: List.unmodifiable(bottom),
      jurySavedIds: List.unmodifiable(bottomRanked.take(2)),
      finalCutContestantIds: List.unmodifiable(bottomRanked.skip(2)));
}
