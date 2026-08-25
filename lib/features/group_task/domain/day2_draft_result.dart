class Day2DraftEvent {
  const Day2DraftEvent({
    required this.captainId,
    required this.selectedContestantId,
    required this.pickNumber,
    required this.teamId,
    required this.reason,
  });

  final int captainId;
  final int selectedContestantId;
  final int pickNumber;
  final String teamId;
  final String reason;
}

class TeamAverages {
  const TeamAverages({
    required this.vocal,
    required this.dance,
    required this.stage,
    required this.overall,
  });

  final double vocal;
  final double dance;
  final double stage;
  final double overall;
}

class Day2DraftResult {
  const Day2DraftResult({
    required this.captainAId,
    required this.captainBId,
    required this.teamAIds,
    required this.teamBIds,
    required this.events,
    required this.lastPickedContestantId,
    required this.teamAAverages,
    required this.teamBAverages,
  });

  final int captainAId;
  final int captainBId;
  final List<int> teamAIds;
  final List<int> teamBIds;
  final List<Day2DraftEvent> events;
  final int lastPickedContestantId;
  final TeamAverages teamAAverages;
  final TeamAverages teamBAverages;
}
