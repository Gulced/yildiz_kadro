class Day3IconContestantResult {
  const Day3IconContestantResult({
    required this.contestantId,
    required this.identity,
    required this.styling,
    required this.camera,
    required this.performance,
    required this.rawIconScore,
  });
  final int contestantId;
  final int identity;
  final int styling;
  final int camera;
  final int performance;
  final double rawIconScore;
  int get iconScore => rawIconScore.round().clamp(0, 100);
}

class Day3IconResultSnapshot {
  const Day3IconResultSnapshot({
    required this.results,
    required this.rankingIds,
    required this.bottom4Ids,
    required this.jurySavedIds,
    required this.finalCutContestantIds,
  });
  final Map<int, Day3IconContestantResult> results;
  final List<int> rankingIds;
  final List<int> bottom4Ids;
  final List<int> jurySavedIds;
  final List<int> finalCutContestantIds;
}
