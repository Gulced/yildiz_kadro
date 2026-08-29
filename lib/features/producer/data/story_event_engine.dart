import 'dart:math';

import 'package:yildiz_kadro/features/contestants/data/contestant_identity_profiles.dart';
import 'package:yildiz_kadro/features/contestants/data/contestant_seed_data.dart';
import 'package:yildiz_kadro/features/producer/domain/contestant_social_state.dart';
import 'package:yildiz_kadro/features/producer/domain/story_event.dart';

typedef _Template = ({
  String id,
  StoryEventFamily family,
  StoryEventCategory category,
  String title,
  List<String> bodies,
  List<StoryChoice> choices,
});

StoryEvent createStoryEvent({
  required int seasonSeed,
  required int day,
  required List<int> eligibleIds,
  required Set<String> seenEventIds,
  Map<int, ContestantSocialState> socialStates = const {},
  Map<int, Map<int, int>> relationships = const {},
}) {
  if (eligibleIds.isEmpty) throw StateError('Aktif yarışmacı bulunamadı.');
  final random = Random(seasonSeed + day * 7919 + seenEventIds.length * 101);
  final ranked = [...eligibleIds]..sort((a, b) {
      final aState = socialStates[a];
      final bState = socialStates[b];
      final aPressure = (100 - (aState?.morale ?? 70)) + (aState?.buzz ?? 0);
      final bPressure = (100 - (bState?.morale ?? 70)) + (bState?.buzz ?? 0);
      return bPressure.compareTo(aPressure);
    });
  final first = ranked.take(5).toList()[random.nextInt(ranked.take(5).length)];
  final firstIdentity =
      identityFor(contestantSeedData.firstWhere((c) => c.id == first));
  final partnerPool = eligibleIds.where((id) => id != first).toList()
    ..sort((a, b) {
      final ar = relationships[first]?[a] ?? 50;
      final br = relationships[first]?[b] ?? 50;
      return ar.compareTo(br);
    });
  final second = partnerPool.isEmpty ? null : partnerPool.first;

  final pool = _templates.where((template) {
    if (seenEventIds.contains(template.id)) return false;
    if (template.category == StoryEventCategory.relationship &&
        second == null) {
      return false;
    }
    if (template.id == 'confidence_drop') {
      return (socialStates[first]?.morale ?? 70) < 72;
    }
    if (template.id == 'fan_pressure') {
      return (socialStates[first]?.popularity ?? 50) >= 70;
    }
    if (template.id == 'visibility_conflict') {
      return firstIdentity.visibility >= 75 && second != null;
    }
    return true;
  }).toList();
  final source = pool.isEmpty
      ? _templates.where((event) => !seenEventIds.contains(event.id)).toList()
      : pool;
  final candidates = source.isEmpty ? _templates : source;
  final positiveWanted = day.isEven &&
      !seenEventIds
          .any((id) => id.startsWith('breakout') || id.startsWith('bonding'));
  final balanced = positiveWanted
      ? candidates
          .where((e) => e.category == StoryEventCategory.positive)
          .toList()
      : candidates;
  final template = (balanced.isEmpty ? candidates : balanced)[
      random.nextInt((balanced.isEmpty ? candidates : balanced).length)];
  final participantIds =
      template.category == StoryEventCategory.relationship && second != null
          ? [first, second]
          : [first];
  final names = participantIds
      .map((id) => contestantSeedData.firstWhere((c) => c.id == id).displayName)
      .toList();
  final body = template.bodies[random.nextInt(template.bodies.length)]
      .replaceAll('{first}', names.first)
      .replaceAll('{second}', names.length > 1 ? names[1] : names.first);
  final relation = second == null ? 50 : relationships[first]?[second] ?? 50;
  final why = _why(template.id, first, second, socialStates, relation);
  return StoryEvent(
    id: '${template.id}_d${day}_s${seasonSeed.abs() % 997}',
    family: template.family,
    category: template.category,
    title: template.title,
    body: body,
    why: why,
    contestantIds: participantIds,
    choices: template.choices,
    confessional:
        _confessional(template.id, firstIdentity.competition, names.first),
  );
}

Map<String, int> adjustedStoryEffects({
  required StoryChoice choice,
  required int contestantId,
}) {
  final contestant = contestantSeedData.firstWhere((c) => c.id == contestantId);
  final identity = identityFor(contestant);
  final result = Map<String, int>.from(choice.effects);
  final morale = result['morale'];
  if (morale != null) {
    if (morale < 0 && identity.conflictDirectness < 50) {
      result['morale'] = morale - 2;
    } else if (morale > 0 && identity.teamwork >= 80) {
      result['morale'] = morale + 2;
    }
  }
  if ((result['relationship'] ?? 0) > 0 && identity.teamwork >= 80) {
    result['relationship'] = result['relationship']! + 2;
  }
  if ((result['preparation'] ?? 0) > 0 && identity.discipline >= 80) {
    result['preparation'] = result['preparation']! + 2;
  }
  if ((result['buzz'] ?? 0) > 0 && identity.visibility >= 80) {
    result['buzz'] = result['buzz']! + 2;
  }
  return Map.unmodifiable(result);
}

String _why(String id, int first, int? second,
    Map<int, ContestantSocialState> states, int relationship) {
  final contestant = contestantSeedData.firstWhere((c) => c.id == first);
  final identity = identityFor(contestant);
  if (id == 'confidence_drop') {
    return '${contestant.displayName}’in motivasyonu ${states[first]?.morale ?? 70}; geri bildirimi karakteri gereği daha yoğun hissediyor.';
  }
  if (id == 'fan_pressure') {
    return '${contestant.displayName} yükselen popülerliğiyle birlikte daha fazla beklenti taşıyor.';
  }
  if (second != null) {
    final other = contestantSeedData.firstWhere((c) => c.id == second);
    return '${contestant.displayName} görünürlükte ${identity.visibility}; ${other.displayName} ile ilişkileri $relationship/100 seviyesinde.';
  }
  return '${contestant.displayName}’in çalışma disiplini ${identity.discipline}, risk alma eğilimi ${identity.riskTaking}.';
}

String _confessional(String id, int competition, String name) {
  if (id.contains('conflict') || id.contains('sharing')) {
    return competition >= 75
        ? '“Geri planda kalmak için burada değilim.” — $name'
        : '“Takım için paylaşırım ama görünmez olmak istemiyorum.” — $name';
  }
  if (id == 'confidence_drop') {
    return '“Bir hata bütün emeğimi silsin istemiyorum.” — $name';
  }
  return '“Bu anı sahneye taşımak istiyorum.” — $name';
}

const _templates = <_Template>[
  (
    id: 'late_rehearsal',
    family: StoryEventFamily.rehearsal,
    category: StoryEventCategory.crisis,
    title: 'PROVAYA GEÇ KALDI',
    bodies: [
      '{first} prova programını aksattı.',
      '{first} kritik provaya zamanında yetişemedi.'
    ],
    choices: [
      StoryChoice(
          id: 'warn',
          label: 'NET BİR UYARI VER',
          feedback: 'Sınır netleşti.',
          effects: {'professionalism': 7, 'morale': -4, 'buzz': 2}),
      StoryChoice(
          id: 'listen',
          label: 'ÖNCE DİNLE',
          feedback: 'Güven ilişkisi güçlendi.',
          effects: {'morale': 7, 'professionalism': 2}),
      StoryChoice(
          id: 'plan',
          label: 'TELAFİ PROVASI PLANLA',
          feedback: 'Eksik çalışma kapatıldı.',
          effects: {'preparation': 7, 'energy': -3}),
    ]
  ),
  (
    id: 'visibility_conflict',
    family: StoryEventFamily.relationship,
    category: StoryEventCategory.relationship,
    title: 'CENTER TARTIŞMASI',
    bodies: [
      '{first}, {second} ile merkez anını paylaşmak istemiyor.',
      'Prova sırasında {first} ve {second} arasında görünürlük konusu yeniden açıldı.'
    ],
    choices: [
      StoryChoice(
          id: 'share',
          label: 'CENTER ANINI PAYLAŞTIR',
          feedback: 'Sahne dengesi kuruldu.',
          effects: {'relationship': 7, 'morale': 2, 'buzz': 2}),
      StoryChoice(
          id: 'audition',
          label: 'KISA BİR KARŞILAŞTIRMA YAP',
          feedback: 'Rekabet performansı yükseltti.',
          effects: {'relationship': -5, 'preparation': 6, 'buzz': 6}),
      StoryChoice(
          id: 'keep',
          label: 'MEVCUT ROLÜ KORU',
          feedback: 'Karar net ama herkes memnun değil.',
          effects: {'relationship': -3, 'professionalism': 3}),
    ]
  ),
  (
    id: 'vocal_sharing',
    family: StoryEventFamily.relationship,
    category: StoryEventCategory.crisis,
    title: 'VOKAL PART PAYLAŞIMI',
    bodies: [
      '{first} ve {second} final notasını kimin söyleyeceği konusunda anlaşamıyor.',
      '{second}, {first}’in part dağılımını adil bulmadığını söyledi.'
    ],
    choices: [
      StoryChoice(
          id: 'fit',
          label: 'TEKNİK UYUMA GÖRE DAĞIT',
          feedback: 'Teknik karar kabul gördü.',
          effects: {'preparation': 7, 'relationship': 2}),
      StoryChoice(
          id: 'rotate',
          label: 'PROVADA DÖNÜŞÜMLÜ DENE',
          feedback: 'İki yorum da değerlendirildi.',
          effects: {'relationship': 6, 'energy': -2, 'confidence': 3}),
    ]
  ),
  (
    id: 'confidence_drop',
    family: StoryEventFamily.privateLife,
    category: StoryEventCategory.crisis,
    title: 'ÖZGÜVENİ SARSILDI',
    bodies: [
      '{first} son hatasından sonra sahneye çıkmaktan çekiniyor.',
      '{first} jüri geri bildirimini aklından çıkaramıyor.'
    ],
    choices: [
      StoryChoice(
          id: 'rest',
          label: 'KISA BİR MOLA VER',
          feedback: 'Enerjisi toparlandı.',
          effects: {'morale': 9, 'energy': 10, 'preparation': -3}),
      StoryChoice(
          id: 'coach',
          label: 'BİRE BİR PROVA YAP',
          feedback: 'Hazırlık güven verdi.',
          effects: {'confidence': 8, 'preparation': 7, 'energy': -3}),
      StoryChoice(
          id: 'stage',
          label: 'KÜÇÜK SAHNE TESTİ VER',
          feedback: 'Korkusuyla yüzleşti.',
          effects: {'confidence': 5, 'buzz': 4, 'energy': -2}),
    ]
  ),
  (
    id: 'fan_pressure',
    family: StoryEventFamily.viral,
    category: StoryEventCategory.social,
    title: 'FAVORİ BASKISI',
    bodies: [
      '{first} favori gösterildikçe hata yapmaktan daha çok korkuyor.',
      '{first} için büyüyen fan ilgisi kuliste yeni bir baskı yarattı.'
    ],
    choices: [
      StoryChoice(
          id: 'protect',
          label: 'SOSYAL MEDYADAN UZAK TUT',
          feedback: 'Baskı azaldı.',
          effects: {'morale': 7, 'buzz': -3, 'energy': 3}),
      StoryChoice(
          id: 'embrace',
          label: 'İLGİYİ SAHİPLENMESİNİ İSTE',
          feedback: 'Görünürlük büyüdü.',
          effects: {'popularity': 5, 'buzz': 9, 'confidence': 3}),
    ]
  ),
  (
    id: 'breakout_moment',
    family: StoryEventFamily.coach,
    category: StoryEventCategory.positive,
    title: 'BEKLENMEDİK ÇIKIŞ',
    bodies: [
      '{first} provada kimsenin beklemediği kadar güçlü bir an çıkardı.',
      'Hoca, {first}’in bugünkü gelişimini özellikle not etti.'
    ],
    choices: [
      StoryChoice(
          id: 'feature',
          label: 'SAHNEDE ÖNE ÇIKAR',
          feedback: 'Çıkış anı görünür hale geldi.',
          effects: {'confidence': 7, 'popularity': 4, 'buzz': 8}),
      StoryChoice(
          id: 'stabilize',
          label: 'AYNI ANI SAĞLAMLAŞTIR',
          feedback: 'Sürpriz gelişim kalıcılaştırıldı.',
          effects: {'preparation': 8, 'professionalism': 4, 'confidence': 3}),
    ]
  ),
  (
    id: 'bonding',
    family: StoryEventFamily.relationship,
    category: StoryEventCategory.positive,
    title: 'BEKLENMEDİK UYUM',
    bodies: [
      '{first} ve {second} prova sonrasında birbirlerinin eksiğini tamamladı.',
      '{first}, zorlanan {second}’e kendi prova zamanından ayırdı.'
    ],
    choices: [
      StoryChoice(
          id: 'duo',
          label: 'İKİLİ ANI GÜÇLENDİR',
          feedback: 'Yeni bir performans ikilisi doğdu.',
          effects: {'relationship': 10, 'buzz': 5, 'preparation': 3}),
      StoryChoice(
          id: 'team',
          label: 'ENERJİYİ TAKIMA YAY',
          feedback: 'Takım morali yükseldi.',
          effects: {'relationship': 7, 'morale': 6}),
    ]
  ),
  (
    id: 'viral_rehearsal',
    family: StoryEventFamily.viral,
    category: StoryEventCategory.positive,
    title: 'PROVA ANI VİRAL',
    bodies: [
      '{first}’in doğal prova anı kısa sürede konuşulmaya başladı.',
      'Kulis kamerası {first} için beklenmedik bir fan anı yakaladı.'
    ],
    choices: [
      StoryChoice(
          id: 'share',
          label: 'ANI YAYINLA',
          feedback: 'Görünürlük hızla arttı.',
          effects: {'popularity': 5, 'buzz': 12, 'followers': 18000}),
      StoryChoice(
          id: 'protect',
          label: 'DOĞAL KALSIN',
          feedback: 'Kişisel sınırlar korundu.',
          effects: {'morale': 5, 'professionalism': 3, 'followers': 5000}),
    ]
  ),
];
