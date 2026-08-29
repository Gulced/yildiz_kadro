class Contestant {
  const Contestant({
    required this.id,
    required this.number,
    required this.name,
    required this.age,
    required this.city,
    required this.occupationOrEducation,
    required this.shortBackground,
    required this.fullBackground,
    required this.archetype,
    required this.personalityTraits,
    required this.primaryRole,
    required this.secondaryRoles,
    required this.vocal,
    required this.dance,
    required this.stage,
    required this.popularity,
    required this.potential,
    required this.specialTraitTitle,
    required this.specialTraitDescription,
    required this.riskTitle,
    required this.riskDescription,
    required this.producerNote,
    required this.quote,
    this.initialMotivation = 70,
    this.portraitAsset,
  });

  final int id;
  final String number;
  final String name;
  final int age;
  final String city;
  final String occupationOrEducation;
  final String shortBackground;
  final String fullBackground;
  final String archetype;
  final List<String> personalityTraits;
  final String primaryRole;
  final List<String> secondaryRoles;
  final int vocal;
  final int dance;
  final int stage;
  final int popularity;
  final int potential;
  final String specialTraitTitle;
  final String specialTraitDescription;
  final String riskTitle;
  final String riskDescription;
  final String producerNote;
  final String quote;
  final int initialMotivation;
  final String? portraitAsset;

  String get displayName =>
      name.replaceAll('i', 'İ').replaceAll('ı', 'I').toUpperCase();

  List<String> get candidatePositions => [primaryRole, ...secondaryRoles];

  ({String label, int value}) get strongestStat {
    final stats = <({String label, int value})>[
      (label: 'VOKAL', value: vocal),
      (label: 'DANS', value: dance),
      (label: 'SAHNE', value: stage),
      (label: 'POPÜLERLİK', value: popularity),
      (label: 'POTANSİYEL', value: potential),
    ];
    stats.sort((a, b) => b.value.compareTo(a.value));
    return stats.first;
  }
}
