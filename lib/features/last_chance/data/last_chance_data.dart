import 'package:yildiz_kadro/features/last_chance/domain/last_chance_result.dart';

const lastChanceResults = <int, LastChanceResult>{
  3: LastChanceResult(
      contestantId: 3,
      vocal: 81,
      dance: 88,
      stage: 92,
      baseOverall: 87,
      tag: 'BASKIDA AÇILDI',
      comment: 'İlk performansındaki hamlık bu kez daha kontrollüydü.'),
  6: LastChanceResult(
      contestantId: 6,
      vocal: 82,
      dance: 84,
      stage: 86,
      baseOverall: 84,
      tag: 'TEMİZ DÖNÜŞ',
      comment: 'Büyük bir patlama yapmadı ama hata da bırakmadı.'),
  13: LastChanceResult(
      contestantId: 13,
      vocal: 74,
      dance: 84,
      stage: 86,
      baseOverall: 82,
      tag: 'BASKIDA DİMDİK',
      comment: 'Maç disipliniyle temposunu korudu; ifadesi hâlâ kontrollüydü.'),
  1: LastChanceResult(
      contestantId: 1,
      vocal: 92,
      dance: 90,
      stage: 94,
      baseOverall: 92,
      tag: 'YILDIZ REFLEKSİ',
      comment:
          'Baskı altında doğal yeteneğine döndü ve üç alanda da güçlü kaldı.'),
  9: LastChanceResult(
      contestantId: 9,
      vocal: 83,
      dance: 79,
      stage: 81,
      baseOverall: 81,
      tag: 'KONTROLÜ BIRAKAMADI',
      comment: 'Temiz kaldı ama Son Şans sahnesi daha fazla risk istiyordu.'),
};

const lastChanceRevealPriority = <int>[9, 1, 6, 3, 13];
const lastChanceSurvivalPriority = <int>[3, 13, 6, 1, 9];

const farewellMessages = <int, String>{
  3: 'Ham elmas bu kez parlamaya zaman bulamadı.',
  6: 'Sıcaklığı yetti, ama yarışma daha fazlasını istedi.',
  13: 'Saha disiplini güçlüydü; sahne bu kez daha fazla duygu istedi.',
  1: 'Büyük yeteneği bu kez üzerindeki beklentiyi aşmaya yetmedi.',
  9: 'Kontrolü hiç bırakmadı; yarışma ise risk istedi.',
};

List<LastChanceResult> rankLastChanceResults({
  required Iterable<int> contestantIds,
  required int coachContestantId,
}) {
  final ranked = contestantIds.map((id) => lastChanceResults[id]!).toList();
  ranked.sort((a, b) {
    final finalScore = b
        .finalScore(coached: b.contestantId == coachContestantId)
        .compareTo(a.finalScore(coached: a.contestantId == coachContestantId));
    if (finalScore != 0) return finalScore;
    final stage = b.stage.compareTo(a.stage);
    if (stage != 0) return stage;
    final vocal = b.vocal.compareTo(a.vocal);
    if (vocal != 0) return vocal;
    return lastChanceSurvivalPriority
        .indexOf(a.contestantId)
        .compareTo(lastChanceSurvivalPriority.indexOf(b.contestantId));
  });
  return ranked;
}
