class ContestantIdentity {
  const ContestantIdentity({
    required this.hook,
    required this.goal,
    required this.characterStrength,
    required this.sensitivity,
    required this.competition,
    required this.leadership,
    required this.visibility,
    required this.teamwork,
    required this.discipline,
    required this.riskTaking,
    required this.conflictDirectness,
    required this.preferredRoles,
    required this.underPressure,
  });

  final String hook;
  final String goal;
  final String characterStrength;
  final String sensitivity;
  final int competition;
  final int leadership;
  final int visibility;
  final int teamwork;
  final int discipline;
  final int riskTaking;
  final int conflictDirectness;
  final List<String> preferredRoles;
  final String underPressure;
}
