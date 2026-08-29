enum Day2DuelConcept { vocal, dance, stage }

enum Day2DuelApproach { clean, starMoment }

enum Day2DuelCoaching { technique, showYourself, tellStory }

class DuelContestantResult {
  const DuelContestantResult({
    required this.contestantId,
    required this.vocal,
    required this.dance,
    required this.stage,
    required this.conceptFitModifier,
    required this.approachModifier,
    required this.coachingModifier,
    this.formModifier = 0,
    required this.rawScore,
    required this.scoreWithoutPlayerModifiers,
  });
  final int contestantId;
  final int vocal;
  final int dance;
  final int stage;
  final int conceptFitModifier;
  final int approachModifier;
  final int coachingModifier;
  final int formModifier;
  final double rawScore;
  final double scoreWithoutPlayerModifiers;
  int get finalScore => rawScore.round().clamp(0, 100);
  int get totalModifier =>
      conceptFitModifier + approachModifier + coachingModifier + formModifier;
}

class Day2DuelResultSnapshot {
  const Day2DuelResultSnapshot({
    required this.concept,
    required this.approach,
    required this.coaching,
    required this.results,
    required this.performanceOrderIds,
    required this.winnerContestantId,
    required this.eliminatedContestantId,
    required this.playerChangedOutcome,
  });
  final Day2DuelConcept concept;
  final Day2DuelApproach approach;
  final Day2DuelCoaching coaching;
  final Map<int, DuelContestantResult> results;
  final List<int> performanceOrderIds;
  final int winnerContestantId;
  final int eliminatedContestantId;
  final bool playerChangedOutcome;
}
