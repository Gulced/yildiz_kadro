import 'package:yildiz_kadro/l10n/l10n.dart';
import 'package:flutter/widgets.dart';
import 'package:yildiz_kadro/features/last_chance/domain/last_chance_result.dart';

const lastChanceResults = <int, LastChanceResult>{
  3: LastChanceResult(
    contestantId: 3,
    vocal: 81,
    dance: 88,
    stage: 92,
    baseOverall: 87,
    tag: 'BASKIDA AÇILDI',
    tagEn: 'BLOOMED UNDER PRESSURE',
    comment: 'İlk performansındaki hamlık bu kez daha kontrollüydü.',
    commentEn: 'Her initial raw edge was far more focused and dialed in.',
  ),
  6: LastChanceResult(
    contestantId: 6,
    vocal: 82,
    dance: 84,
    stage: 86,
    baseOverall: 84,
    tag: 'TEMİZ DÖNÜŞ',
    tagEn: 'CLEAN REBOUND',
    comment: 'Büyük bir patlama yapmadı ama hata da bırakmadı.',
    commentEn: 'Did not stage an explosion, but left zero mistakes behind.',
  ),
  13: LastChanceResult(
    contestantId: 13,
    vocal: 74,
    dance: 84,
    stage: 86,
    baseOverall: 82,
    tag: 'BASKIDA DİMDİK',
    tagEn: 'UNSHAKEN UNDER FIRE',
    comment: 'Maç disipliniyle temposunu korudu; ifadesi hâlâ kontrollüydü.',
    commentEn:
        'Maintained strict tempo with match discipline; expression remained restrained.',
  ),
  1: LastChanceResult(
    contestantId: 1,
    vocal: 92,
    dance: 90,
    stage: 94,
    baseOverall: 92,
    tag: 'YILDIZ REFLEKSİ',
    tagEn: 'STAR INSTINCT',
    comment:
        'Baskı altında doğal yeteneğine döndü ve üç alanda da güçlü kaldı.',
    commentEn:
        'Fell back on pure natural instinct under pressure and stayed dominant across all areas.',
  ),
  9: LastChanceResult(
    contestantId: 9,
    vocal: 83,
    dance: 79,
    stage: 81,
    baseOverall: 81,
    tag: 'KONTROLÜ BIRAKAMADI',
    tagEn: 'HELD ONTO CONTROL',
    comment: 'Temiz kaldı ama Son Şans sahnesi daha fazla risk istiyordu.',
    commentEn:
        'Stayed clean, but the Last Chance stage begged for a bolder gamble.',
  ),
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

const farewellMessagesEn = <int, String>{
  3: 'The rough diamond didn\'t get enough time to shine tonight.',
  6: 'Her warmth was felt, but the competition demanded more.',
  13: 'Her court discipline was strong, but the stage demanded deeper emotion.',
  1: 'Her immense talent wasn\'t enough to overcome the mountain of expectations tonight.',
  9: 'Never let go of control; yet the stage demanded taking a risk.',
};

String localizedFarewellMessage(int id, BuildContext context) {
  final isEn = isAppEnglish(context);
  return isEn
      ? (farewellMessagesEn[id] ?? farewellMessages[id] ?? '')
      : (farewellMessages[id] ?? '');
}

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
