enum Day3FinalCutFormat { coverShot, motionShot, liveCloseUp }

enum Day3FinalCutApproach { perfectFrame, boldFrame }

class Day3FinalCutContestantResult {
  const Day3FinalCutContestantResult({
    required this.contestantId,
    required this.baseScore,
    required this.testFitModifier,
    required this.approachModifier,
    required this.historyModifier,
    required this.rawScore,
  });
  final int contestantId;
  final double baseScore;
  final int testFitModifier;
  final int approachModifier;
  final int historyModifier;
  final double rawScore;
  int get finalScore => rawScore.round().clamp(0, 100);
  int get totalModifier => testFitModifier + approachModifier + historyModifier;
}

class Day3FinalCutResultSnapshot {
  const Day3FinalCutResultSnapshot({
    required this.format,
    required this.approach,
    required this.results,
    required this.winnerContestantId,
    required this.eliminatedContestantId,
    required this.playerChangedOutcome,
  });
  final Day3FinalCutFormat format;
  final Day3FinalCutApproach approach;
  final Map<int, Day3FinalCutContestantResult> results;
  final int winnerContestantId;
  final int eliminatedContestantId;
  final bool playerChangedOutcome;
}
