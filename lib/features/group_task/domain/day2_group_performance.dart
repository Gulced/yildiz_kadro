class TeamGroupPerformanceResult {
  const TeamGroupPerformanceResult({
    required this.teamId,
    required this.vocal,
    required this.dance,
    required this.stage,
    required this.harmony,
    required this.rawGroupScore,
    required this.starContestantId,
  });

  final String teamId;
  final int vocal;
  final int dance;
  final int stage;
  final int harmony;
  final double rawGroupScore;
  final int starContestantId;
  int get groupScore => rawGroupScore.round().clamp(0, 100);
}

class IndividualGroupPerformanceResult {
  const IndividualGroupPerformanceResult({
    required this.contestantId,
    required this.teamId,
    required this.assignedRole,
    required this.vocal,
    required this.dance,
    required this.stage,
    required this.rawOverall,
    required this.receivedDecisionBonus,
  });

  final int contestantId;
  final String teamId;
  final String assignedRole;
  final int vocal;
  final int dance;
  final int stage;
  final double rawOverall;
  final bool receivedDecisionBonus;
  int get overall => rawOverall.round().clamp(0, 100);
}

class Day2GroupPerformanceSnapshot {
  const Day2GroupPerformanceSnapshot({
    required this.teamAResult,
    required this.teamBResult,
    required this.individualResults,
    required this.winningTeamId,
    required this.losingTeamId,
    required this.losingTeamRankingIds,
    required this.top3SafeIds,
    required this.initialRiskIds,
  });

  final TeamGroupPerformanceResult teamAResult;
  final TeamGroupPerformanceResult teamBResult;
  final Map<int, IndividualGroupPerformanceResult> individualResults;
  final String winningTeamId;
  final String losingTeamId;
  final List<int> losingTeamRankingIds;
  final List<int> top3SafeIds;
  final List<int> initialRiskIds;
}
