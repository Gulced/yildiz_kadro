import 'package:yildiz_kadro/l10n/l10n.dart';
import 'package:flutter/widgets.dart';

enum RehearsalCrisisType {
  centerConflict,
  vocalConflict,
  danceConflict,
  lastPickPressure,
  positiveDevelopment,
  generic,
}

enum Day2TeamRoleType { center, leadVocal, subVocal, leadDancer, subDancer }

class Day2RoleSlot {
  const Day2RoleSlot({required this.id, required this.type});
  final String id;
  final Day2TeamRoleType type;
}

List<Day2RoleSlot> getRolesForTeamSize(int teamSize) {
  if (teamSize < 3) throw ArgumentError.value(teamSize, 'teamSize');
  final slots = <Day2RoleSlot>[
    const Day2RoleSlot(id: 'center', type: Day2TeamRoleType.center),
    const Day2RoleSlot(id: 'lead_vocal', type: Day2TeamRoleType.leadVocal),
    const Day2RoleSlot(id: 'lead_dancer', type: Day2TeamRoleType.leadDancer),
  ];
  var index = 1;
  while (slots.length < teamSize) {
    final type =
        index.isOdd ? Day2TeamRoleType.subVocal : Day2TeamRoleType.subDancer;
    slots.add(Day2RoleSlot(id: '${type.name}_${(index + 1) ~/ 2}', type: type));
    index++;
  }
  // Editorial order: vocal line together, dance line together.
  slots.sort((a, b) => a.type.index.compareTo(b.type.index));
  return List.unmodifiable(slots);
}

String day2TeamRoleLabel(Day2TeamRoleType role, [BuildContext? context]) {
  final isEn = isAppEnglish(context);
  return switch (role) {
    Day2TeamRoleType.center => 'CENTER',
    Day2TeamRoleType.leadVocal => isEn ? 'LEAD VOCAL' : 'LEAD VOKAL',
    Day2TeamRoleType.subVocal => isEn ? 'SUB VOCAL' : 'SUB VOKAL',
    Day2TeamRoleType.leadDancer => 'LEAD DANCER',
    Day2TeamRoleType.subDancer => 'SUB DANCER',
  };
}

String day2TeamRoleDescription(Day2TeamRoleType role, [BuildContext? context]) {
  final isEn = isAppEnglish(context);
  return switch (role) {
    Day2TeamRoleType.center => isEn
        ? 'Best suited for members with high stage presence and visibility.'
        : 'Sahne etkisi ve görünürlüğü yüksek üyeye uygun.',
    Day2TeamRoleType.leadVocal => isEn
        ? 'Carries the team’s demanding vocal sections.'
        : 'Takımın güçlü vokal bölümlerini taşır.',
    Day2TeamRoleType.subVocal => isEn
        ? 'Supports the vocal line and anchors harmonies.'
        : 'Vokal hattını ve diğer bölümleri destekler.',
    Day2TeamRoleType.leadDancer => isEn
        ? 'Steps forward during challenging choreographies.'
        : 'Zor koreografilerde öne çıkar.',
    Day2TeamRoleType.subDancer => isEn
        ? 'Supports dance formations and movement flow.'
        : 'Dans formasyonunu ve lideri destekler.',
  };
}

class TeamRoleAssignments {
  const TeamRoleAssignments({
    required this.centerId,
    required this.mainVocalId,
    required this.danceLeadId,
    required this.groupMemberIds,
    this.roleSlots = const [],
  });

  final int centerId;
  final int mainVocalId;
  final int danceLeadId;
  final List<int> groupMemberIds;
  final List<({Day2RoleSlot slot, int contestantId})> roleSlots;

  String roleLabelFor(int contestantId, [BuildContext? context]) {
    final isEn = isAppEnglish(context);
    final match = roleSlots.where(
      (entry) => entry.contestantId == contestantId,
    );
    if (match.isNotEmpty) {
      return day2TeamRoleLabel(match.first.slot.type, context);
    }
    if (contestantId == centerId) return 'CENTER';
    if (contestantId == mainVocalId) return isEn ? 'LEAD VOCAL' : 'LEAD VOKAL';
    if (contestantId == danceLeadId) return 'LEAD DANCER';
    return isEn ? 'GROUP MEMBER' : 'GRUP ÜYESİ';
  }

  Day2TeamRoleType? roleTypeFor(int contestantId) {
    final match = roleSlots.where(
      (entry) => entry.contestantId == contestantId,
    );
    return match.isEmpty ? null : match.first.slot.type;
  }
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
    this.titleEn,
    this.headlineEn,
    this.descriptionEn,
  });

  final String teamId;
  final RehearsalCrisisType type;
  final int primaryContestantId;
  final int? secondaryContestantId;
  final String title;
  final String headline;
  final String description;
  final String? titleEn;
  final String? headlineEn;
  final String? descriptionEn;

  String localizedTitle(BuildContext context) =>
      isAppEnglish(context) ? (titleEn ?? title) : title;

  String localizedHeadline(BuildContext context) =>
      isAppEnglish(context) ? (headlineEn ?? headline) : headline;

  String localizedDescription(BuildContext context) =>
      isAppEnglish(context) ? (descriptionEn ?? description) : description;
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
    this.titleEn,
    this.descriptionEn,
    this.narrativeEn,
  });

  final String id;
  final String title;
  final String description;
  final String narrative;
  final int harmonyModifier;
  final int readinessModifier;
  final int energyModifier;
  final String? titleEn;
  final String? descriptionEn;
  final String? narrativeEn;

  String localizedTitle(BuildContext context) =>
      isAppEnglish(context) ? (titleEn ?? title) : title;

  String localizedDescription(BuildContext context) =>
      isAppEnglish(context) ? (descriptionEn ?? description) : description;

  String localizedNarrative(BuildContext context) =>
      isAppEnglish(context) ? (narrativeEn ?? narrative) : narrative;
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
    this.playerChoicesByTeam = const {},
  });

  final String playerInterventionTeamId;
  final RehearsalCrisisType playerCrisisType;
  final RehearsalChoice playerChoice;
  final String captainResolutionTeamId;
  final RehearsalChoice captainChoice;
  final RehearsalMetrics teamAFinalMetrics;
  final RehearsalMetrics teamBFinalMetrics;
  final Map<String, RehearsalChoice> playerChoicesByTeam;
}
