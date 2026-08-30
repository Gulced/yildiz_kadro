enum StoryEventFamily { relationship, rehearsal, privateLife, viral, coach }

enum StoryEventCategory { crisis, positive, social, performance, relationship }

class StoryChoice {
  const StoryChoice({
    required this.id,
    required this.label,
    required this.feedback,
    required this.effects,
    this.characterAware = true,
    this.followUpFlags = const [],
  });
  final String id;
  final String label;
  final String feedback;
  final Map<String, int> effects;
  final bool characterAware;
  final List<String> followUpFlags;
}

class StoryEvent {
  const StoryEvent({
    required this.id,
    required this.family,
    required this.category,
    required this.title,
    required this.body,
    required this.why,
    required this.contestantIds,
    required this.choices,
    this.confessional,
    this.probabilityWeight = 10,
    this.cooldownDays = 2,
    this.requirements = const [],
    this.followUpFlags = const [],
  });
  final String id;
  final StoryEventFamily family;
  final StoryEventCategory category;
  final String title;
  final String body;
  final String why;
  final List<int> contestantIds;
  final List<StoryChoice> choices;
  final String? confessional;
  final int probabilityWeight;
  final int cooldownDays;
  final List<String> requirements;
  final List<String> followUpFlags;
}

class StoryEventRecord {
  const StoryEventRecord({
    required this.day,
    required this.event,
    this.choiceId,
    this.before = const {},
    this.after = const {},
  });
  final int day;
  final StoryEvent event;
  final String? choiceId;
  final Map<int, Map<String, int>> before;
  final Map<int, Map<String, int>> after;

  StoryEventRecord resolve(
    String id, {
    required Map<int, Map<String, int>> before,
    required Map<int, Map<String, int>> after,
  }) =>
      StoryEventRecord(
        day: day,
        event: event,
        choiceId: id,
        before: before,
        after: after,
      );
}
