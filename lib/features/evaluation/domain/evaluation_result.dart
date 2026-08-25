class EvaluationResult {
  const EvaluationResult({
    required this.contestantId,
    required this.vocal,
    required this.dance,
    required this.stage,
    required this.overall,
    required this.comment,
    required this.tag,
  });

  final int contestantId;
  final int vocal;
  final int dance;
  final int stage;
  final int overall;
  final String comment;
  final String tag;
}
