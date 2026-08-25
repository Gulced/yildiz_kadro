class LastChanceResult {
  const LastChanceResult({
    required this.contestantId,
    required this.vocal,
    required this.dance,
    required this.stage,
    required this.baseOverall,
    required this.tag,
    required this.comment,
  });

  final int contestantId;
  final int vocal;
  final int dance;
  final int stage;
  final int baseOverall;
  final String tag;
  final String comment;

  int finalScore({required bool coached}) =>
      (baseOverall + (coached ? 4 : 0)).clamp(0, 100);
}
