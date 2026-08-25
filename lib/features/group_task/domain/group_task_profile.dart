enum GroupRole { vocal, dance, stage, allRounder }

enum WorkStyle {
  instinctive,
  calm,
  observant,
  direct,
  competitive,
  social,
  bold,
  experienced,
  controlled,
  spontaneous,
  cameraSavvy,
  chaotic,
  protective,
  sensitive,
  playful,
}

class GroupTaskProfile {
  const GroupTaskProfile({
    required this.contestantId,
    required this.primaryRole,
    required this.secondaryRole,
    required this.workStyle,
  });

  final int contestantId;
  final GroupRole primaryRole;
  final GroupRole secondaryRole;
  final WorkStyle workStyle;
}
