import 'package:yildiz_kadro/l10n/l10n.dart';
import 'package:flutter/widgets.dart';

enum StoryEventFamily { relationship, rehearsal, privateLife, viral, coach }

enum StoryEventCategory { crisis, positive, social, performance, relationship }

class StoryChoice {
  const StoryChoice({
    required this.id,
    required this.label,
    required this.feedback,
    required this.effects,
    this.labelEn,
    this.feedbackEn,
    this.characterAware = true,
    this.followUpFlags = const [],
  });
  final String id;
  final String label;
  final String? labelEn;
  final String feedback;
  final String? feedbackEn;
  final Map<String, int> effects;
  final bool characterAware;
  final List<String> followUpFlags;

  String localizedLabel(BuildContext context) {
    if (isAppEnglish(context) && labelEn != null) return labelEn!;
    return label;
  }

  String localizedFeedback(BuildContext context) {
    if (isAppEnglish(context) && feedbackEn != null) return feedbackEn!;
    return feedback;
  }
}

class StoryEvent {
  const StoryEvent({
    required this.id,
    required this.templateId,
    required this.family,
    required this.category,
    required this.title,
    this.titleEn,
    required this.body,
    this.bodyEn,
    required this.why,
    this.whyEn,
    required this.contestantIds,
    required this.choices,
    this.confessional,
    this.confessionalEn,
    this.probabilityWeight = 10,
    this.cooldownDays = 2,
    this.requirements = const [],
    this.followUpFlags = const [],
  });
  final String id;
  final String templateId;
  final StoryEventFamily family;
  final StoryEventCategory category;
  final String title;
  final String? titleEn;
  final String body;
  final String? bodyEn;
  final String why;
  final String? whyEn;
  final List<int> contestantIds;
  final List<StoryChoice> choices;
  final String? confessional;
  final String? confessionalEn;
  final int probabilityWeight;
  final int cooldownDays;
  final List<String> requirements;
  final List<String> followUpFlags;

  String localizedTitle(BuildContext context) {
    if (isAppEnglish(context) && titleEn != null) return titleEn!;
    return title;
  }

  String localizedBody(BuildContext context) {
    if (isAppEnglish(context) && bodyEn != null) return bodyEn!;
    return body;
  }

  String localizedWhy(BuildContext context) {
    if (isAppEnglish(context) && whyEn != null) return whyEn!;
    return why;
  }

  String? localizedConfessional(BuildContext context) {
    if (isAppEnglish(context) && confessionalEn != null) return confessionalEn!;
    return confessional;
  }
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
