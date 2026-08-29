import 'package:yildiz_kadro/features/producer/domain/contestant_social_state.dart';

class PerformanceChange {
  const PerformanceChange({
    required this.contestantId,
    required this.before,
    required this.after,
    required this.reason,
  });

  final int contestantId;
  final ContestantSocialState before;
  final ContestantSocialState after;
  final String reason;

  int get followerDelta => after.followers - before.followers;
  int get popularityDelta => after.popularity - before.popularity;
  int get motivationDelta => after.motivation - before.motivation;
  int get xpDelta => after.experienceXp - before.experienceXp;
  bool get leveledUp => after.level > before.level;
}

class PerformanceAftermath {
  const PerformanceAftermath({required this.stageId, required this.changes});
  final String stageId;
  final List<PerformanceChange> changes;
}
