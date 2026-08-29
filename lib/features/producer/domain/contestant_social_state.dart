class FollowerSnapshot {
  const FollowerSnapshot(
      {required this.day, required this.count, required this.reason});
  final int day;
  final int count;
  final String reason;
}

class ContestantSocialState {
  const ContestantSocialState({
    required this.popularity,
    required this.buzz,
    required this.followers,
    required this.morale,
    required this.confidence,
    required this.professionalism,
    required this.energy,
    required this.preparation,
    required this.vocalCoachImpression,
    required this.danceCoachImpression,
    required this.followerHistory,
    this.experienceXp = 0,
  });

  final int popularity;
  final int buzz;
  final int followers;
  final int morale;
  final int confidence;
  final int professionalism;
  final int energy;
  final int preparation;
  final int vocalCoachImpression;
  final int danceCoachImpression;
  final List<FollowerSnapshot> followerHistory;
  final int experienceXp;
  int get level => 1 + experienceXp ~/ 150;
  int get motivation => morale;

  String get currentForm => morale >= 78 && energy >= 70
      ? 'YÜKSELİŞTE'
      : morale < 55 || energy < 50
          ? 'KIRILGAN'
          : 'DENGELİ';

  int get weeklyFollowerGrowth => followerHistory.length < 2
      ? 0
      : followerHistory.last.count - followerHistory.first.count;

  ContestantSocialState apply({
    int popularity = 0,
    int buzz = 0,
    int followers = 0,
    int morale = 0,
    int confidence = 0,
    int professionalism = 0,
    int energy = 0,
    int preparation = 0,
    int vocalCoachImpression = 0,
    int danceCoachImpression = 0,
    int? day,
    String reason = '',
    int experienceXp = 0,
  }) {
    int bounded(int value) => value.clamp(0, 100);
    final nextFollowers = (this.followers + followers).clamp(0, 99999999);
    final history = [...followerHistory];
    if (followers != 0 && day != null) {
      history.add(
          FollowerSnapshot(day: day, count: nextFollowers, reason: reason));
    }
    return ContestantSocialState(
      popularity: bounded(this.popularity + popularity),
      buzz: bounded(this.buzz + buzz),
      followers: nextFollowers,
      morale: bounded(this.morale + morale),
      confidence: bounded(this.confidence + confidence),
      professionalism: bounded(this.professionalism + professionalism),
      energy: bounded(this.energy + energy),
      preparation: bounded(this.preparation + preparation),
      vocalCoachImpression:
          bounded(this.vocalCoachImpression + vocalCoachImpression),
      danceCoachImpression:
          bounded(this.danceCoachImpression + danceCoachImpression),
      followerHistory: List.unmodifiable(history),
      experienceXp: (this.experienceXp + experienceXp).clamp(0, 99999),
    );
  }
}

String relationshipLabel(int value) => value >= 75
    ? 'ÇOK YAKIN'
    : value >= 60
        ? 'İYİ'
        : value >= 42
            ? 'NÖTR'
            : value >= 28
                ? 'MESAFELİ'
                : value >= 15
                    ? 'REKABETÇİ'
                    : 'GERİLİMLİ';
