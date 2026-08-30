import 'dart:math';

import 'package:yildiz_kadro/features/contestants/data/contestant_identity_profiles.dart';
import 'package:yildiz_kadro/features/contestants/data/contestant_seed_data.dart';
import 'package:yildiz_kadro/features/producer/domain/contestant_social_state.dart';
import 'package:yildiz_kadro/features/producer/domain/story_event.dart';

int get storyEventTemplateCount => _templates.length;

typedef _Template = ({
  String id,
  StoryEventFamily family,
  StoryEventCategory category,
  String title,
  List<String> bodies,
  List<StoryChoice> choices,
});

enum _Audience {
  any,
  vocal,
  dance,
  stage,
  popular,
  lowEnergy,
  relationship,
  gulce,
  lara,
  zeynepEla,
}

typedef _TemplateMeta = ({
  _Audience audience,
  int weight,
  int cooldownDays,
  String? requiredFlag,
  List<String> requirements,
});

StoryEvent createStoryEvent({
  required int seasonSeed,
  required int day,
  required List<int> eligibleIds,
  required Set<String> seenEventIds,
  Map<int, ContestantSocialState> socialStates = const {},
  Map<int, Map<int, int>> relationships = const {},
  List<int> recentContestantIds = const [],
  Map<String, int> decisionFlags = const {},
}) {
  if (eligibleIds.isEmpty) throw StateError('Aktif yarışmacı bulunamadı.');
  final random = Random(seasonSeed + day * 7919 + seenEventIds.length * 101);
  final pool = _templates.where((template) {
    if (seenEventIds.contains(template.id)) return false;
    final meta = _meta(template.id);
    if (meta.requiredFlag case final flag?) {
      if ((decisionFlags[flag] ?? 0) == 0) return false;
    }
    return eligibleIds.any((id) => _matches(meta.audience, id, socialStates));
  }).toList();
  final source = pool.isEmpty
      ? _templates.where((event) => !seenEventIds.contains(event.id)).toList()
      : pool;
  final candidates = source.isEmpty ? _templates : source;
  final positiveWanted = day.isEven &&
      !seenEventIds.any(
        (id) => id.startsWith('breakout') || id.startsWith('bonding'),
      );
  final balanced = positiveWanted
      ? candidates
          .where((e) => e.category == StoryEventCategory.positive)
          .toList()
      : candidates;
  final selectionPool = balanced.isEmpty ? candidates : balanced;
  final template = _weightedTemplate(selectionPool, random);
  final meta = _meta(template.id);
  var matchingIds = eligibleIds
      .where((id) => _matches(meta.audience, id, socialStates))
      .toList();
  final withoutRecent =
      matchingIds.where((id) => !recentContestantIds.contains(id)).toList();
  if (withoutRecent.isNotEmpty) matchingIds = withoutRecent;
  matchingIds.sort((a, b) {
    final aState = socialStates[a];
    final bState = socialStates[b];
    final aPressure = (100 - (aState?.morale ?? 70)) + (aState?.buzz ?? 0);
    final bPressure = (100 - (bState?.morale ?? 70)) + (bState?.buzz ?? 0);
    return bPressure.compareTo(aPressure);
  });
  final shortlist = matchingIds.take(5).toList();
  final first = shortlist[random.nextInt(shortlist.length)];
  final firstIdentity = identityFor(
    contestantSeedData.firstWhere((c) => c.id == first),
  );
  final partnerPool = eligibleIds.where((id) => id != first).toList()
    ..sort((a, b) {
      final ar = relationships[first]?[a] ?? 50;
      final br = relationships[first]?[b] ?? 50;
      return ar.compareTo(br);
    });
  final second = partnerPool.isEmpty ? null : partnerPool.first;
  final participantIds =
      (template.category == StoryEventCategory.relationship ||
                  meta.audience == _Audience.relationship) &&
              second != null
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
    confessional: _confessional(
      template.id,
      firstIdentity.competition,
      names.first,
    ),
    probabilityWeight: meta.weight,
    cooldownDays: meta.cooldownDays,
    requirements: meta.requirements,
  );
}

_Template _weightedTemplate(List<_Template> templates, Random random) {
  final total = templates.fold<int>(
    0,
    (sum, item) => sum + _meta(item.id).weight,
  );
  var roll = random.nextInt(total);
  for (final template in templates) {
    roll -= _meta(template.id).weight;
    if (roll < 0) return template;
  }
  return templates.last;
}

bool _matches(
  _Audience audience,
  int id,
  Map<int, ContestantSocialState> socialStates,
) {
  final contestant = contestantSeedData.firstWhere((value) => value.id == id);
  final social = socialStates[id];
  return switch (audience) {
    _Audience.any => true,
    _Audience.vocal => contestant.vocal >= 84,
    _Audience.dance => contestant.dance >= 84,
    _Audience.stage => contestant.stage >= 88,
    _Audience.popular => (social?.popularity ?? contestant.popularity) >= 68,
    _Audience.lowEnergy => (social?.energy ?? 78) <= 72,
    _Audience.relationship => true,
    _Audience.gulce => id == 1,
    _Audience.lara => id == 8,
    _Audience.zeynepEla => id == 13,
  };
}

_TemplateMeta _meta(String id) =>
    _templateMetadata[id] ??
    const (
      audience: _Audience.any,
      weight: 10,
      cooldownDays: 2,
      requiredFlag: null,
      requirements: <String>[],
    );

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

String _why(
  String id,
  int first,
  int? second,
  Map<int, ContestantSocialState> states,
  int relationship,
) {
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
      '{first} kritik provaya zamanında yetişemedi.',
    ],
    choices: [
      StoryChoice(
        id: 'warn',
        label: 'NET BİR UYARI VER',
        feedback: 'Sınır netleşti.',
        effects: {'professionalism': 7, 'morale': -4, 'buzz': 2},
      ),
      StoryChoice(
        id: 'listen',
        label: 'ÖNCE DİNLE',
        feedback: 'Güven ilişkisi güçlendi.',
        effects: {'morale': 7, 'professionalism': 2},
      ),
      StoryChoice(
        id: 'plan',
        label: 'TELAFİ PROVASI PLANLA',
        feedback: 'Eksik çalışma kapatıldı.',
        effects: {'preparation': 7, 'energy': -3},
      ),
    ],
  ),
  (
    id: 'visibility_conflict',
    family: StoryEventFamily.relationship,
    category: StoryEventCategory.relationship,
    title: 'CENTER TARTIŞMASI',
    bodies: [
      '{first}, {second} ile merkez anını paylaşmak istemiyor.',
      'Prova sırasında {first} ve {second} arasında görünürlük konusu yeniden açıldı.',
    ],
    choices: [
      StoryChoice(
        id: 'share',
        label: 'CENTER ANINI PAYLAŞTIR',
        feedback: 'Sahne dengesi kuruldu.',
        effects: {'relationship': 7, 'morale': 2, 'buzz': 2},
      ),
      StoryChoice(
        id: 'audition',
        label: 'KISA BİR KARŞILAŞTIRMA YAP',
        feedback: 'Rekabet performansı yükseltti.',
        effects: {'relationship': -5, 'preparation': 6, 'buzz': 6},
      ),
      StoryChoice(
        id: 'keep',
        label: 'MEVCUT ROLÜ KORU',
        feedback: 'Karar net ama herkes memnun değil.',
        effects: {'relationship': -3, 'professionalism': 3},
      ),
    ],
  ),
  (
    id: 'vocal_sharing',
    family: StoryEventFamily.relationship,
    category: StoryEventCategory.crisis,
    title: 'VOKAL PART PAYLAŞIMI',
    bodies: [
      '{first} ve {second} final notasını kimin söyleyeceği konusunda anlaşamıyor.',
      '{second}, {first}’in part dağılımını adil bulmadığını söyledi.',
    ],
    choices: [
      StoryChoice(
        id: 'fit',
        label: 'TEKNİK UYUMA GÖRE DAĞIT',
        feedback: 'Teknik karar kabul gördü.',
        effects: {'preparation': 7, 'relationship': 2},
      ),
      StoryChoice(
        id: 'rotate',
        label: 'PROVADA DÖNÜŞÜMLÜ DENE',
        feedback: 'İki yorum da değerlendirildi.',
        effects: {'relationship': 6, 'energy': -2, 'confidence': 3},
      ),
    ],
  ),
  (
    id: 'confidence_drop',
    family: StoryEventFamily.privateLife,
    category: StoryEventCategory.crisis,
    title: 'ÖZGÜVENİ SARSILDI',
    bodies: [
      '{first} son hatasından sonra sahneye çıkmaktan çekiniyor.',
      '{first} jüri geri bildirimini aklından çıkaramıyor.',
    ],
    choices: [
      StoryChoice(
        id: 'rest',
        label: 'KISA BİR MOLA VER',
        feedback: 'Enerjisi toparlandı.',
        effects: {'morale': 9, 'energy': 10, 'preparation': -3},
      ),
      StoryChoice(
        id: 'coach',
        label: 'BİRE BİR PROVA YAP',
        feedback: 'Hazırlık güven verdi.',
        effects: {'confidence': 8, 'preparation': 7, 'energy': -3},
      ),
      StoryChoice(
        id: 'stage',
        label: 'KÜÇÜK SAHNE TESTİ VER',
        feedback: 'Korkusuyla yüzleşti.',
        effects: {'confidence': 5, 'buzz': 4, 'energy': -2},
      ),
    ],
  ),
  (
    id: 'fan_pressure',
    family: StoryEventFamily.viral,
    category: StoryEventCategory.social,
    title: 'FAVORİ BASKISI',
    bodies: [
      '{first} favori gösterildikçe hata yapmaktan daha çok korkuyor.',
      '{first} için büyüyen fan ilgisi kuliste yeni bir baskı yarattı.',
    ],
    choices: [
      StoryChoice(
        id: 'protect',
        label: 'SOSYAL MEDYADAN UZAK TUT',
        feedback: 'Baskı azaldı.',
        effects: {'morale': 7, 'buzz': -3, 'energy': 3},
      ),
      StoryChoice(
        id: 'embrace',
        label: 'İLGİYİ SAHİPLENMESİNİ İSTE',
        feedback: 'Görünürlük büyüdü.',
        effects: {'popularity': 5, 'buzz': 9, 'confidence': 3},
      ),
    ],
  ),
  (
    id: 'breakout_moment',
    family: StoryEventFamily.coach,
    category: StoryEventCategory.positive,
    title: 'BEKLENMEDİK ÇIKIŞ',
    bodies: [
      '{first} provada kimsenin beklemediği kadar güçlü bir an çıkardı.',
      'Hoca, {first}’in bugünkü gelişimini özellikle not etti.',
    ],
    choices: [
      StoryChoice(
        id: 'feature',
        label: 'SAHNEDE ÖNE ÇIKAR',
        feedback: 'Çıkış anı görünür hale geldi.',
        effects: {'confidence': 7, 'popularity': 4, 'buzz': 8},
      ),
      StoryChoice(
        id: 'stabilize',
        label: 'AYNI ANI SAĞLAMLAŞTIR',
        feedback: 'Sürpriz gelişim kalıcılaştırıldı.',
        effects: {'preparation': 8, 'professionalism': 4, 'confidence': 3},
      ),
    ],
  ),
  (
    id: 'bonding',
    family: StoryEventFamily.relationship,
    category: StoryEventCategory.positive,
    title: 'BEKLENMEDİK UYUM',
    bodies: [
      '{first} ve {second} prova sonrasında birbirlerinin eksiğini tamamladı.',
      '{first}, zorlanan {second}’e kendi prova zamanından ayırdı.',
    ],
    choices: [
      StoryChoice(
        id: 'duo',
        label: 'İKİLİ ANI GÜÇLENDİR',
        feedback: 'Yeni bir performans ikilisi doğdu.',
        effects: {'relationship': 10, 'buzz': 5, 'preparation': 3},
      ),
      StoryChoice(
        id: 'team',
        label: 'ENERJİYİ TAKIMA YAY',
        feedback: 'Takım morali yükseldi.',
        effects: {'relationship': 7, 'morale': 6},
      ),
    ],
  ),
  (
    id: 'viral_rehearsal',
    family: StoryEventFamily.viral,
    category: StoryEventCategory.positive,
    title: 'PROVA ANI VİRAL',
    bodies: [
      '{first}’in doğal prova anı kısa sürede konuşulmaya başladı.',
      'Kulis kamerası {first} için beklenmedik bir fan anı yakaladı.',
    ],
    choices: [
      StoryChoice(
        id: 'share',
        label: 'ANI YAYINLA',
        feedback: 'Görünürlük hızla arttı.',
        effects: {'popularity': 5, 'buzz': 12, 'followers': 18000},
      ),
      StoryChoice(
        id: 'protect',
        label: 'DOĞAL KALSIN',
        feedback: 'Kişisel sınırlar korundu.',
        effects: {'morale': 5, 'professionalism': 3, 'followers': 5000},
      ),
    ],
  ),
  (
    id: 'vocal_fatigue',
    family: StoryEventFamily.rehearsal,
    category: StoryEventCategory.crisis,
    title: 'SES YORGUNLUĞU',
    bodies: [
      '{first} uzun vokal provasından sonra sesinde baskı hissediyor. Önemli kayıt ise birkaç saat sonra.',
    ],
    choices: [
      StoryChoice(
        id: 'perform',
        label: 'KAYDA DEVAM ET',
        feedback: 'Kaydı tamamladı ama bedeli enerjisine yansıdı.',
        effects: {'buzz': 7, 'energy': -10, 'vocalCoach': -2},
        followUpFlags: ['pushed_when_tired'],
      ),
      StoryChoice(
        id: 'rest',
        label: 'SESİNİ DİNLENDİR',
        feedback: 'Sesini korudu; kayıt planı geriye alındı.',
        effects: {'energy': 9, 'preparation': -4, 'morale': 3},
      ),
      StoryChoice(
        id: 'coach',
        label: 'VOKAL HOCASINA DANIŞ',
        feedback: 'Program güvenli bir orta yolda yeniden kuruldu.',
        effects: {'energy': 4, 'vocalCoach': 5, 'preparation': 2},
      ),
    ],
  ),
  (
    id: 'solo_offer',
    family: StoryEventFamily.coach,
    category: StoryEventCategory.positive,
    title: 'SOLO TEKLİFİ',
    bodies: [
      'Yapım ekibi {first} için kısa bir solo bölüm önerdi. Bu fırsat görünürlüğü artırabilir ama grup dengesini zorlayabilir.',
    ],
    choices: [
      StoryChoice(
        id: 'accept',
        label: 'SOLOYU KABUL ET',
        feedback: 'Solo büyük ilgi gördü; kuliste rekabet yükseldi.',
        effects: {'popularity': 6, 'buzz': 10, 'morale': -2},
        followUpFlags: ['center_favored'],
      ),
      StoryChoice(
        id: 'share',
        label: 'BÖLÜMÜ GRUPLA PAYLAŞ',
        feedback: 'Görünürlük paylaşıldı ve takım rahatladı.',
        effects: {'popularity': 2, 'morale': 5, 'professionalism': 4},
      ),
    ],
  ),
  (
    id: 'high_note_pressure',
    family: StoryEventFamily.coach,
    category: StoryEventCategory.performance,
    title: 'YÜKSEK NOTA BASKISI',
    bodies: [
      '{first} teknik olarak notaya hazır, fakat tek denemelik canlı kayıt baskıyı büyütüyor.',
    ],
    choices: [
      StoryChoice(
        id: 'live',
        label: 'CANLI SÖYLESİN',
        feedback: 'Riskli tercih güçlü bir sahne anına dönüştü.',
        effects: {'confidence': 6, 'buzz': 7, 'energy': -5},
      ),
      StoryChoice(
        id: 'lower',
        label: 'TONU GÜVENLİ HALE GETİR',
        feedback: 'Performans temiz kaldı, sürpriz etkisi azaldı.',
        effects: {'preparation': 6, 'professionalism': 3, 'buzz': -2},
      ),
    ],
  ),
  (
    id: 'dance_challenge',
    family: StoryEventFamily.viral,
    category: StoryEventCategory.positive,
    title: 'DANS CHALLENGE’I YÜKSELİYOR',
    bodies: [
      '{first}’in prova hareketi kısa videolarda hızla yayılıyor. Ekip trendi nasıl yöneteceğine karar vermeli.',
    ],
    choices: [
      StoryChoice(
        id: 'publish',
        label: 'RESMİ VİDEOYU YAYINLA',
        feedback: 'Challenge geniş bir kitleye ulaştı.',
        effects: {'followers': 24000, 'buzz': 11, 'energy': -4},
      ),
      StoryChoice(
        id: 'team',
        label: 'TÜM GRUBU VİDEOYA AL',
        feedback: 'Trend bireysel değil, takım anına dönüştü.',
        effects: {'followers': 14000, 'morale': 5, 'popularity': 3},
      ),
    ],
  ),
  (
    id: 'choreo_strain',
    family: StoryEventFamily.rehearsal,
    category: StoryEventCategory.crisis,
    title: 'KOREOGRAFİDE ZORLANMA',
    bodies: [
      '{first} yoğun tekrar sırasında ayağında ağrı hissetti. Provanın kritik bölümü henüz tamamlanmadı.',
    ],
    choices: [
      StoryChoice(
        id: 'continue',
        label: 'PROVAYI TAMAMLASIN',
        feedback: 'Koreografi oturdu, fiziksel yük arttı.',
        effects: {'preparation': 8, 'energy': -12},
        followUpFlags: ['pushed_when_tired'],
      ),
      StoryChoice(
        id: 'modify',
        label: 'HAREKETİ UYARLA',
        feedback: 'Risk azaldı ve sahne akışı korundu.',
        effects: {'energy': 5, 'preparation': 3, 'danceCoach': 3},
      ),
      StoryChoice(
        id: 'rest',
        label: 'BUGÜN DİNLENDİR',
        feedback: 'Fiziksel durum toparlandı; prova eksiği kaldı.',
        effects: {'energy': 12, 'preparation': -5},
      ),
    ],
  ),
  (
    id: 'brand_interest',
    family: StoryEventFamily.viral,
    category: StoryEventCategory.positive,
    title: 'MARKA İLGİSİ',
    bodies: [
      'Bir moda markası {first} ile kısa içerik çekmek istiyor. Teklif görünürlük sağlıyor ancak prova gününe denk geliyor.',
    ],
    choices: [
      StoryChoice(
        id: 'accept',
        label: 'TEKLİFİ KABUL ET',
        feedback: 'İş birliği konuşuldu; yoğun program enerjiyi düşürdü.',
        effects: {'followers': 20000, 'popularity': 5, 'energy': -7},
      ),
      StoryChoice(
        id: 'group',
        label: 'GRUBA ÖZEL ANLAŞMA İSTE',
        feedback: 'Daha küçük ama dengeli bir grup fırsatı doğdu.',
        effects: {'followers': 9000, 'morale': 6, 'buzz': 4},
      ),
    ],
  ),
  (
    id: 'unexpected_views',
    family: StoryEventFamily.viral,
    category: StoryEventCategory.positive,
    title: 'PERFORMANS REKOR İZLENDİ',
    bodies: [
      '{first}’in performans kesiti beklenenden çok daha fazla izlendi. Yeni ilgiyi hızlı mı yoksa kontrollü mü kullanacaksın?',
    ],
    choices: [
      StoryChoice(
        id: 'boost',
        label: 'İLGİYİ BÜYÜT',
        feedback: 'Yeni içerik dalgası takipçiyi hızla artırdı.',
        effects: {'followers': 28000, 'buzz': 10, 'energy': -4},
      ),
      StoryChoice(
        id: 'pace',
        label: 'TEMPOYU KORU',
        feedback: 'İlgi sürdürülebilir biçimde yönetildi.',
        effects: {'followers': 11000, 'professionalism': 5, 'morale': 3},
      ),
    ],
  ),
  (
    id: 'styling_attention',
    family: StoryEventFamily.viral,
    category: StoryEventCategory.positive,
    title: 'STYLING KONUŞULUYOR',
    bodies: [
      '{first}’in prova styling’i fan hesaplarında öne çıktı. Ekip bu estetik yönü sahne konseptine taşımayı düşünüyor.',
    ],
    choices: [
      StoryChoice(
        id: 'feature',
        label: 'KONSEPTE TAŞI',
        feedback: 'Görsel kimlik daha güçlü ve konuşulur hale geldi.',
        effects: {'buzz': 9, 'popularity': 4, 'confidence': 3},
      ),
      StoryChoice(
        id: 'keep',
        label: 'SAHNEYİ SADE TUT',
        feedback: 'Dikkat performansta kaldı.',
        effects: {'preparation': 5, 'professionalism': 3},
      ),
    ],
  ),
  (
    id: 'athlete_schedule',
    family: StoryEventFamily.privateLife,
    category: StoryEventCategory.crisis,
    title: 'PROGRAM ÇAKIŞMASI',
    bodies: [
      'Zeynep Ela’nın profesyonel spor programı önemli prova saatine denk geldi. İki disiplin de tam katılım bekliyor.',
    ],
    choices: [
      StoryChoice(
        id: 'stage',
        label: 'PROVAYI ÖNCELİKLENDİR',
        feedback: 'Sahne hazırlığı güçlendi; fiziksel toparlanma kısaldı.',
        effects: {'preparation': 8, 'energy': -8},
      ),
      StoryChoice(
        id: 'balance',
        label: 'PROGRAMI BÖL',
        feedback: 'İki sorumluluk dengelendi, gün yorucu geçti.',
        effects: {'professionalism': 6, 'energy': -3, 'morale': 3},
      ),
      StoryChoice(
        id: 'coach',
        label: 'HOCALARLA PLANLA',
        feedback: 'Yük güvenli biçimde yeniden dağıtıldı.',
        effects: {'energy': 5, 'preparation': 4, 'professionalism': 3},
      ),
    ],
  ),
  (
    id: 'athlete_viral',
    family: StoryEventFamily.viral,
    category: StoryEventCategory.positive,
    title: 'SPORCU GEÇMİŞİ VİRAL',
    bodies: [
      'Zeynep Ela’nın eski maç görüntüleri sosyal medyada yeniden keşfedildi. Disiplini yeni izleyicilerin dikkatini çekiyor.',
    ],
    choices: [
      StoryChoice(
        id: 'story',
        label: 'HİKÂYESİNİ PAYLAŞ',
        feedback: 'Spor ve sahne yolculuğu geniş bir kitleye ulaştı.',
        effects: {'followers': 26000, 'popularity': 6, 'buzz': 9},
      ),
      StoryChoice(
        id: 'team',
        label: 'TAKIM ANTRENMANINA ÇEVİR',
        feedback: 'İlgi grubun çalışma enerjisine yayıldı.',
        effects: {'followers': 12000, 'morale': 6, 'preparation': 4},
      ),
    ],
  ),
  (
    id: 'architecture_deadline',
    family: StoryEventFamily.privateLife,
    category: StoryEventCategory.crisis,
    title: 'TESLİM VE PROVA AYNI GÜN',
    bodies: [
      'Lara’nın mimarlık proje teslimi prova programıyla çakıştı. Uykusuz kalmadan ikisini birden tamamlaması zor görünüyor.',
    ],
    choices: [
      StoryChoice(
        id: 'rehearse',
        label: 'PROVAYI ÖNCELİKLENDİR',
        feedback: 'Sahne hazırlandı; teslim baskısı motivasyonunu etkiledi.',
        effects: {'preparation': 7, 'morale': -5, 'energy': -4},
      ),
      StoryChoice(
        id: 'deadline',
        label: 'TESLİM İÇİN ZAMAN VER',
        feedback: 'Lara zihnini toparladı; prova süresi kısaldı.',
        effects: {'morale': 8, 'preparation': -4, 'energy': 3},
      ),
      StoryChoice(
        id: 'plan',
        label: 'PROGRAMI YENİDEN KUR',
        feedback: 'Yaratıcı ve dengeli bir çalışma planı bulundu.',
        effects: {'professionalism': 6, 'preparation': 3, 'energy': -2},
      ),
    ],
  ),
  (
    id: 'lara_stage_design',
    family: StoryEventFamily.coach,
    category: StoryEventCategory.positive,
    title: 'LARA’DAN SAHNE FİKRİ',
    bodies: [
      'Lara renk, biçim ve kamera aksını birleştiren özgün bir sahne düzeni çizdi. Fikir güçlü ama son dakika değişikliği gerektiriyor.',
    ],
    choices: [
      StoryChoice(
        id: 'use',
        label: 'FİKRİ UYGULA',
        feedback: 'Yeni kompozisyon sahnenin görsel kimliğini güçlendirdi.',
        effects: {'buzz': 10, 'confidence': 6, 'preparation': -2},
      ),
      StoryChoice(
        id: 'adapt',
        label: 'FİKRİ SADELEŞTİR',
        feedback: 'Yaratıcı dokunuş prova düzenini bozmadan kullanıldı.',
        effects: {'buzz': 5, 'professionalism': 5, 'morale': 3},
      ),
    ],
  ),
  (
    id: 'gulce_center_tension',
    family: StoryEventFamily.relationship,
    category: StoryEventCategory.relationship,
    title: 'MERKEZDE FAZLA MI KALIYOR?',
    bodies: [
      'Gülce’nin güçlü performansı merkez anlarını artırdı. {second}, dağılımın takım dengesini bozduğunu düşünüyor.',
    ],
    choices: [
      StoryChoice(
        id: 'keep',
        label: 'GÜLCE’Yİ MERKEZDE TUT',
        feedback: 'Performans gücü korundu; kuliste mesafe oluştu.',
        effects: {'buzz': 8, 'relationship': -7, 'confidence': 4},
        followUpFlags: ['center_favored'],
      ),
      StoryChoice(
        id: 'share',
        label: 'MERKEZİ PAYLAŞTIR',
        feedback: 'Sahne dengesi ve takım güveni güçlendi.',
        effects: {'relationship': 9, 'morale': 5, 'buzz': 2},
      ),
      StoryChoice(
        id: 'audition',
        label: 'HOCALARA KISA TEST YAPTIR',
        feedback: 'Karar performans ölçümüne bağlandı.',
        effects: {'preparation': 6, 'relationship': 2, 'energy': -3},
      ),
    ],
  ),
  (
    id: 'gulce_solo_spotlight',
    family: StoryEventFamily.coach,
    category: StoryEventCategory.positive,
    title: 'GÜLCE’YE SOLO FIRSATI',
    bodies: [
      'Gülce’nin vokal, dans ve sahne gücü yapım ekibinden özel bir solo teklif getirdi. Fırsat büyük, beklenti daha da büyük.',
    ],
    choices: [
      StoryChoice(
        id: 'accept',
        label: 'SOLOYU AÇ',
        feedback: 'Gülce’nin yıldız anı gündeme oturdu.',
        effects: {'followers': 25000, 'buzz': 11, 'energy': -6},
        followUpFlags: ['center_favored'],
      ),
      StoryChoice(
        id: 'group',
        label: 'GRUP ANINA DÖNÜŞTÜR',
        feedback: 'Doğal yetenek takım sahnesini yukarı taşıdı.',
        effects: {'followers': 12000, 'morale': 6, 'professionalism': 4},
      ),
    ],
  ),
  (
    id: 'burnout_followup',
    family: StoryEventFamily.privateLife,
    category: StoryEventCategory.crisis,
    title: 'TÜKENMİŞLİK SİNYALİ',
    bodies: [
      '{first} son günlerde dinlenmeden çalıştı. Konsantrasyonu düşerken önemli prova yaklaşmaya devam ediyor.',
    ],
    choices: [
      StoryChoice(
        id: 'rest',
        label: 'TAM DİNLENME VER',
        feedback: 'Enerjisi geri geldi; hazırlık programı daraldı.',
        effects: {'energy': 16, 'morale': 7, 'preparation': -7},
      ),
      StoryChoice(
        id: 'light',
        label: 'HAFİF PROGRAM UYGULA',
        feedback: 'Tempo düşürüldü ve hazırlık tamamen kopmadı.',
        effects: {'energy': 8, 'preparation': 2, 'professionalism': 3},
      ),
      StoryChoice(
        id: 'push',
        label: 'PROGRAMI SÜRDÜR',
        feedback: 'Prova tamamlandı ama yorgunluk derinleşti.',
        effects: {'preparation': 9, 'energy': -14, 'morale': -6},
        followUpFlags: ['pushed_when_tired'],
      ),
    ],
  ),
  (
    id: 'team_harmony',
    family: StoryEventFamily.relationship,
    category: StoryEventCategory.positive,
    title: 'GRUP UYUMU YÜKSELİYOR',
    bodies: [
      '{first} ve {second} görev paylaşımını kendiliğinden dengeledi. Prova odasındaki rahatlık tüm takıma yansıyor.',
    ],
    choices: [
      StoryChoice(
        id: 'capture',
        label: 'BU ANI İÇERİĞE DÖNÜŞTÜR',
        feedback: 'Doğal arkadaşlık fanların dikkatini çekti.',
        effects: {'relationship': 8, 'followers': 14000, 'buzz': 6},
      ),
      StoryChoice(
        id: 'protect',
        label: 'KULİSTE BIRAK',
        feedback: 'Uyum gösteriye dönüşmeden güçlendi.',
        effects: {'relationship': 11, 'morale': 7},
      ),
    ],
  ),
];

const _templateMetadata = <String, _TemplateMeta>{
  'visibility_conflict': (
    audience: _Audience.relationship,
    weight: 8,
    cooldownDays: 3,
    requiredFlag: null,
    requirements: ['İki aktif yarışmacı'],
  ),
  'vocal_sharing': (
    audience: _Audience.relationship,
    weight: 8,
    cooldownDays: 3,
    requiredFlag: null,
    requirements: ['İki aktif yarışmacı'],
  ),
  'confidence_drop': (
    audience: _Audience.any,
    weight: 7,
    cooldownDays: 2,
    requiredFlag: null,
    requirements: ['Düşük motivasyon eğilimi'],
  ),
  'fan_pressure': (
    audience: _Audience.popular,
    weight: 7,
    cooldownDays: 3,
    requiredFlag: null,
    requirements: ['Yüksek popülerlik'],
  ),
  'bonding': (
    audience: _Audience.relationship,
    weight: 10,
    cooldownDays: 2,
    requiredFlag: null,
    requirements: ['İki aktif yarışmacı'],
  ),
  'vocal_fatigue': (
    audience: _Audience.vocal,
    weight: 9,
    cooldownDays: 3,
    requiredFlag: null,
    requirements: ['Vokal 84+'],
  ),
  'solo_offer': (
    audience: _Audience.vocal,
    weight: 7,
    cooldownDays: 3,
    requiredFlag: null,
    requirements: ['Vokal 84+'],
  ),
  'high_note_pressure': (
    audience: _Audience.vocal,
    weight: 8,
    cooldownDays: 2,
    requiredFlag: null,
    requirements: ['Vokal 84+'],
  ),
  'dance_challenge': (
    audience: _Audience.dance,
    weight: 10,
    cooldownDays: 2,
    requiredFlag: null,
    requirements: ['Dans 84+'],
  ),
  'choreo_strain': (
    audience: _Audience.dance,
    weight: 9,
    cooldownDays: 3,
    requiredFlag: null,
    requirements: ['Dans 84+'],
  ),
  'brand_interest': (
    audience: _Audience.popular,
    weight: 7,
    cooldownDays: 3,
    requiredFlag: null,
    requirements: ['Popülerlik 68+'],
  ),
  'unexpected_views': (
    audience: _Audience.stage,
    weight: 10,
    cooldownDays: 2,
    requiredFlag: null,
    requirements: ['Sahne 88+'],
  ),
  'styling_attention': (
    audience: _Audience.stage,
    weight: 8,
    cooldownDays: 2,
    requiredFlag: null,
    requirements: ['Sahne 88+'],
  ),
  'athlete_schedule': (
    audience: _Audience.zeynepEla,
    weight: 12,
    cooldownDays: 4,
    requiredFlag: null,
    requirements: ['Zeynep Ela aktif'],
  ),
  'athlete_viral': (
    audience: _Audience.zeynepEla,
    weight: 12,
    cooldownDays: 4,
    requiredFlag: null,
    requirements: ['Zeynep Ela aktif'],
  ),
  'architecture_deadline': (
    audience: _Audience.lara,
    weight: 12,
    cooldownDays: 4,
    requiredFlag: null,
    requirements: ['Lara aktif'],
  ),
  'lara_stage_design': (
    audience: _Audience.lara,
    weight: 12,
    cooldownDays: 4,
    requiredFlag: null,
    requirements: ['Lara aktif'],
  ),
  'gulce_center_tension': (
    audience: _Audience.gulce,
    weight: 11,
    cooldownDays: 4,
    requiredFlag: null,
    requirements: ['Gülce aktif', 'İki aktif yarışmacı'],
  ),
  'gulce_solo_spotlight': (
    audience: _Audience.gulce,
    weight: 11,
    cooldownDays: 4,
    requiredFlag: null,
    requirements: ['Gülce aktif'],
  ),
  'burnout_followup': (
    audience: _Audience.lowEnergy,
    weight: 14,
    cooldownDays: 3,
    requiredFlag: 'pushed_when_tired',
    requirements: ['Önceki yorgunluk kararı', 'Enerji 72-'],
  ),
  'team_harmony': (
    audience: _Audience.relationship,
    weight: 10,
    cooldownDays: 2,
    requiredFlag: null,
    requirements: ['İki aktif yarışmacı'],
  ),
};
