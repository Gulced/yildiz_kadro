class Day2JuryEvaluationResult {
  const Day2JuryEvaluationResult({
    required this.contestantId,
    required this.performanceScore,
    required this.developmentScore,
    required this.potentialScore,
    required this.rawJuryScore,
  });

  final int contestantId;
  final int performanceScore;
  final int developmentScore;
  final int potentialScore;
  final double rawJuryScore;
  int get juryScore => rawJuryScore.round().clamp(0, 100);
}

class Day2JuryResultSnapshot {
  const Day2JuryResultSnapshot({
    required this.evaluations,
    required this.rankingIds,
    required this.savedContestantId,
    required this.duelContestantIds,
  });

  final Map<int, Day2JuryEvaluationResult> evaluations;
  final List<int> rankingIds;
  final int savedContestantId;
  final List<int> duelContestantIds;
}
