enum RehearsalCrisisType {
  centerConflict,
  vocalConflict,
  danceConflict,
  lastPickPressure,
  generic,
}

class TeamRoleAssignments {
  const TeamRoleAssignments({
    required this.centerId,
    required this.mainVocalId,
    required this.danceLeadId,
    required this.groupMemberIds,
  });

  final int centerId;
  final int mainVocalId;
  final int danceLeadId;
  final List<int> groupMemberIds;
}

class RehearsalMetrics {
  const RehearsalMetrics({
    required this.harmony,
    required this.readiness,
    required this.energy,
  });

  final int harmony;
  final int readiness;
  final int energy;

  int get score => (harmony * 0.40 + readiness * 0.35 + energy * 0.25).round();
}

class RehearsalCrisis {
  const RehearsalCrisis({
    required this.teamId,
    required this.type,
    required this.primaryContestantId,
    this.secondaryContestantId,
    required this.title,
    required this.headline,
    required this.description,
  });

  final String teamId;
  final RehearsalCrisisType type;
  final int primaryContestantId;
  final int? secondaryContestantId;
  final String title;
  final String headline;
  final String description;
}

class RehearsalChoice {
  const RehearsalChoice({
    required this.id,
    required this.title,
    required this.description,
    required this.narrative,
    required this.harmonyModifier,
    required this.readinessModifier,
    required this.energyModifier,
  });

  final String id;
  final String title;
  final String description;
  final String narrative;
  final int harmonyModifier;
  final int readinessModifier;
  final int energyModifier;
}

class Day2RehearsalSetup {
  const Day2RehearsalSetup({
    required this.teamARoles,
    required this.teamBRoles,
    required this.teamAInitialMetrics,
    required this.teamBInitialMetrics,
    required this.teamACrisis,
    required this.teamBCrisis,
  });

  final TeamRoleAssignments teamARoles;
  final TeamRoleAssignments teamBRoles;
  final RehearsalMetrics teamAInitialMetrics;
  final RehearsalMetrics teamBInitialMetrics;
  final RehearsalCrisis teamACrisis;
  final RehearsalCrisis teamBCrisis;
}

class Day2RehearsalOutcome {
  const Day2RehearsalOutcome({
    required this.playerInterventionTeamId,
    required this.playerCrisisType,
    required this.playerChoice,
    required this.captainResolutionTeamId,
    required this.captainChoice,
    required this.teamAFinalMetrics,
    required this.teamBFinalMetrics,
  });

  final String playerInterventionTeamId;
  final RehearsalCrisisType playerCrisisType;
  final RehearsalChoice playerChoice;
  final String captainResolutionTeamId;
  final RehearsalChoice captainChoice;
  final RehearsalMetrics teamAFinalMetrics;
  final RehearsalMetrics teamBFinalMetrics;
}
