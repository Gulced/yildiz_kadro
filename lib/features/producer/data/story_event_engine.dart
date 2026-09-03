// Generated bilingual Story Event Engine
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
  String titleEn,
  List<String> bodies,
  List<String> bodiesEn,
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
  duru,
  ada,
  alara,
  derin,
  mina,
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
  if (matchingIds.isEmpty) matchingIds = eligibleIds;
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
  final bodyEn = template.bodiesEn[random.nextInt(template.bodiesEn.length)]
      .replaceAll('{first}', names.first)
      .replaceAll('{second}', names.length > 1 ? names[1] : names.first);
  final relation = second == null ? 50 : relationships[first]?[second] ?? 50;
  final why = _why(template.id, first, second, socialStates, relation);
  final whyEn = _whyEn(template.id, first, second, socialStates, relation);
  return StoryEvent(
    id: '${template.id}_d${day}_s${seasonSeed.abs() % 997}',
    templateId: template.id,
    family: template.family,
    category: template.category,
    title: template.title,
    titleEn: template.titleEn,
    body: body,
    bodyEn: bodyEn,
    why: why,
    whyEn: whyEn,
    contestantIds: participantIds,
    choices: template.choices,
    confessional: _confessional(
      template.id,
      firstIdentity.competition,
      names.first,
    ),
    confessionalEn: _confessionalEn(
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
    _Audience.duru => id == 2,
    _Audience.ada => id == 6,
    _Audience.alara => id == 4,
    _Audience.derin => id == 5,
    _Audience.mina => id == 12,
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

String _whyEn(
  String id,
  int first,
  int? second,
  Map<int, ContestantSocialState> states,
  int relationship,
) {
  final contestant = contestantSeedData.firstWhere((c) => c.id == first);
  final identity = identityFor(contestant);
  if (id == 'confidence_drop') {
    return "${contestant.displayName}'s morale is at ${states[first]?.morale ?? 70}; she feels critical feedback deeply due to her sensitive nature.";
  }
  if (id == 'fan_pressure') {
    return "${contestant.displayName} faces mounting pressure alongside her rising popularity.";
  }
  if (second != null) {
    final other = contestantSeedData.firstWhere((c) => c.id == second);
    return "${contestant.displayName}'s visibility drive is ${identity.visibility}; relationship with ${other.displayName} is currently at $relationship/100.";
  }
  return "${contestant.displayName}'s discipline rating is ${identity.discipline}, risk tolerance is ${identity.riskTaking}.";
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

String _confessionalEn(String id, int competition, String name) {
  if (id.contains('conflict') || id.contains('sharing')) {
    return competition >= 75
        ? '“I’m not here just to stay in the background.” — $name'
        : '“I’ll share for the team, but I won’t become invisible.” — $name';
  }
  if (id == 'confidence_drop') {
    return '“I don’t want one mistake to erase all my hard work.” — $name';
  }
  return '“I want to carry this breakthrough straight onto the stage.” — $name';
}

const _templates = <_Template>[
  (
    id: 'late_rehearsal',
    family: StoryEventFamily.rehearsal,
    category: StoryEventCategory.crisis,
    title: "PROVAYA GEÇ KALDI",
    titleEn: "LATE FOR REHEARSAL",
    bodies: [
      "{first} prova programını aksattı.",
      "{first} kritik provaya zamanında yetişemedi.",
    ],
    bodiesEn: [
      "{first} fell behind on the rehearsal schedule.",
      "{first} missed the start of a critical practice run.",
    ],
    choices: [
      StoryChoice(
        id: 'warn',
        label: "NET BİR UYARI VER",
        labelEn: "GIVE A FIRM WARNING",
        feedback: "Sınır netleşti.",
        feedbackEn: "The boundary was set.",
        effects: {'professionalism': 7, 'morale': -4, 'buzz': 2},
      ),
      StoryChoice(
        id: 'listen',
        label: "ÖNCE DİNLE",
        labelEn: "LISTEN FIRST",
        feedback: "Güven ilişkisi güçlendi.",
        feedbackEn: "Mutual trust was strengthened.",
        effects: {'morale': 7, 'professionalism': 2},
      ),
      StoryChoice(
        id: 'plan',
        label: "TELAFİ PROVASI PLANLA",
        labelEn: "PLAN EXTRA REHEARSAL",
        feedback: "Eksik çalışma kapatıldı.",
        feedbackEn: "The training gap was closed.",
        effects: {'preparation': 7, 'energy': -3},
      ),
    ],
  ),
  (
    id: 'visibility_conflict',
    family: StoryEventFamily.relationship,
    category: StoryEventCategory.relationship,
    title: "CENTER TARTIŞMASI",
    titleEn: "CENTER POSITION DISPUTE",
    bodies: [
      "{first}, {second} ile merkez anını paylaşmak istemiyor.",
      "Prova sırasında {first} ve {second} arasında görünürlük konusu yeniden açıldı.",
    ],
    bodiesEn: [
      "{first} doesn't want to share the center moment with {second}.",
      "The question of stage visibility resurfaced between {first} and {second} during rehearsal.",
    ],
    choices: [
      StoryChoice(
        id: 'share',
        label: "CENTER ANINI PAYLAŞTIR",
        labelEn: "SPLIT THE CENTER MOMENT",
        feedback: "Sahne dengesi kuruldu.",
        feedbackEn: "Stage balance was achieved.",
        effects: {'relationship': 7, 'morale': 2, 'buzz': 2},
      ),
      StoryChoice(
        id: 'audition',
        label: "KISA BİR KARŞILAŞTIRMA YAP",
        labelEn: "HOLD A QUICK SHOWDOWN",
        feedback: "Rekabet performansı yükseltti.",
        feedbackEn: "Rivalry elevated the performance.",
        effects: {'relationship': -5, 'preparation': 6, 'buzz': 6},
      ),
      StoryChoice(
        id: 'keep',
        label: "MEVCUT ROLÜ KORU",
        labelEn: "KEEP CURRENT ROLES",
        feedback: "Karar net ama herkes memnun değil.",
        feedbackEn: "Clear decision, but not everyone is happy.",
        effects: {'relationship': -3, 'professionalism': 3},
      ),
    ],
  ),
  (
    id: 'vocal_sharing',
    family: StoryEventFamily.relationship,
    category: StoryEventCategory.crisis,
    title: "VOKAL PART PAYLAŞIMI",
    titleEn: "VOCAL LINE DIVISION",
    bodies: [
      "{first} ve {second} final notasını kimin söyleyeceği konusunda anlaşamıyor.",
      "{second}, {first}’in part dağılımını adil bulmadığını söyledi.",
    ],
    bodiesEn: [
      "{first} and {second} disagree over who delivers the final high note.",
      "{second} expressed that {first}'s line distribution didn't feel fair.",
    ],
    choices: [
      StoryChoice(
        id: 'fit',
        label: "TEKNİK UYUMA GÖRE DAĞIT",
        labelEn: "ASSIGN BY VOCAL FIT",
        feedback: "Teknik karar kabul gördü.",
        feedbackEn: "Technical reasoning was accepted.",
        effects: {'preparation': 7, 'relationship': 2},
      ),
      StoryChoice(
        id: 'rotate',
        label: "PROVADA DÖNÜŞÜMLÜ DENE",
        labelEn: "ALTERNATE IN REHEARSAL",
        feedback: "İki yorum da değerlendirildi.",
        feedbackEn: "Both vocal styles were tested.",
        effects: {'relationship': 6, 'energy': -2, 'confidence': 3},
      ),
    ],
  ),
  (
    id: 'confidence_drop',
    family: StoryEventFamily.privateLife,
    category: StoryEventCategory.crisis,
    title: "ÖZGÜVENİ SARSILDI",
    titleEn: "SHAKEN CONFIDENCE",
    bodies: [
      "{first} son hatasından sonra sahneye çıkmaktan çekiniyor.",
      "{first} jüri geri bildirimini aklından çıkaramıyor.",
    ],
    bodiesEn: [
      "{first} is hesitant to take the stage after her recent slip-up.",
      "{first} can't stop dwelling on the judges' critique.",
    ],
    choices: [
      StoryChoice(
        id: 'rest',
        label: "KISA BİR MOLA VER",
        labelEn: "CALL A SHORT BREAK",
        feedback: "Enerjisi toparlandı.",
        feedbackEn: "Her energy began to recover.",
        effects: {'morale': 9, 'energy': 10, 'preparation': -3},
      ),
      StoryChoice(
        id: 'coach',
        label: "BİRE BİR PROVA YAP",
        labelEn: "RUN 1-ON-1 COACHING",
        feedback: "Hazırlık güven verdi.",
        feedbackEn: "Focused practice restored certainty.",
        effects: {'confidence': 8, 'preparation': 7, 'energy': -3},
      ),
      StoryChoice(
        id: 'stage',
        label: "KÜÇÜK SAHNE TESTİ VER",
        labelEn: "TRY A MINI STAGE DRILL",
        feedback: "Korkusuyla yüzleşti.",
        feedbackEn: "She faced her hesitation directly.",
        effects: {'confidence': 5, 'buzz': 4, 'energy': -2},
      ),
    ],
  ),
  (
    id: 'fan_pressure',
    family: StoryEventFamily.viral,
    category: StoryEventCategory.social,
    title: "FAVORİ BASKISI",
    titleEn: "FAN FAVORITE PRESSURE",
    bodies: [
      "{first} favori gösterildikçe hata yapmaktan daha çok korkuyor.",
      "{first} için büyüyen fan ilgisi kuliste yeni bir baskı yarattı.",
    ],
    bodiesEn: [
      "As {first} is hailed as a frontrunner, her fear of mistakes grows.",
      "Rising fan buzz around {first} created fresh backstage tension.",
    ],
    choices: [
      StoryChoice(
        id: 'protect',
        label: "SOSYAL MEDYADAN UZAK TUT",
        labelEn: "UNPLUG FROM SOCIALS",
        feedback: "Baskı azaldı.",
        feedbackEn: "Pressure subsided noticeably.",
        effects: {'morale': 7, 'buzz': -3, 'energy': 3},
      ),
      StoryChoice(
        id: 'embrace',
        label: "İLGİYİ SAHİPLENMESİNİ İSTE",
        labelEn: "EMBRACE THE MOMENTUM",
        feedback: "Görünürlük büyüdü.",
        feedbackEn: "Her star presence grew.",
        effects: {'popularity': 5, 'buzz': 9, 'confidence': 3},
      ),
    ],
  ),
  (
    id: 'breakout_moment',
    family: StoryEventFamily.coach,
    category: StoryEventCategory.positive,
    title: "BEKLENMEDİK ÇIKIŞ",
    titleEn: "BREAKOUT MOMENT",
    bodies: [
      "{first} provada kimsenin beklemediği kadar güçlü bir an çıkardı.",
      "Hoca, {first}’in bugünkü gelişimini özellikle not etti.",
    ],
    bodiesEn: [
      "{first} delivered an unexpectedly captivating run during rehearsal.",
      "The vocal trainer specifically noted {first}'s rapid growth today.",
    ],
    choices: [
      StoryChoice(
        id: 'feature',
        label: "SAHNEDE ÖNE ÇIKAR",
        labelEn: "SPOTLIGHT ON STAGE",
        feedback: "Çıkış anı görünür hale geldi.",
        feedbackEn: "Her breakthrough moment became visible.",
        effects: {'confidence': 7, 'popularity': 4, 'buzz': 8},
      ),
      StoryChoice(
        id: 'stabilize',
        label: "AYNI ANI SAĞLAMLAŞTIR",
        labelEn: "CEMENT THE FOUNDATION",
        feedback: "Sürpriz gelişim kalıcılaştırıldı.",
        feedbackEn: "The surprise surge became lasting skill.",
        effects: {'preparation': 8, 'professionalism': 4, 'confidence': 3},
      ),
    ],
  ),
  (
    id: 'bonding',
    family: StoryEventFamily.relationship,
    category: StoryEventCategory.positive,
    title: "BEKLENMEDİK UYUM",
    titleEn: "UNEXPECTED HARMONY",
    bodies: [
      "{first} ve {second} prova sonrasında birbirlerinin eksiğini tamamladı.",
      "{first}, zorlanan {second}’e kendi prova zamanından ayırdı.",
    ],
    bodiesEn: [
      "{first} and {second} stayed after practice to cover each other's weak spots.",
      "{first} dedicated her own rehearsal time to assist a struggling {second}.",
    ],
    choices: [
      StoryChoice(
        id: 'duo',
        label: "İKİLİ ANI GÜÇLENDİR",
        labelEn: "AMPLIFY DUO CHEMISTRY",
        feedback: "Yeni bir performans ikilisi doğdu.",
        feedbackEn: "A powerful performance duo was born.",
        effects: {'relationship': 10, 'buzz': 5, 'preparation': 3},
      ),
      StoryChoice(
        id: 'team',
        label: "ENERJİYİ TAKIMA YAY",
        labelEn: "SHARE ENERGY WITH TEAM",
        feedback: "Takım morali yükseldi.",
        feedbackEn: "Overall team morale soared.",
        effects: {'relationship': 7, 'morale': 6},
      ),
    ],
  ),
  (
    id: 'viral_rehearsal',
    family: StoryEventFamily.viral,
    category: StoryEventCategory.positive,
    title: "PROVA ANI VİRAL",
    titleEn: "REHEARSAL CLIP GOES VIRAL",
    bodies: [
      "{first}’in doğal prova anı kısa sürede konuşulmaya başladı.",
      "Kulis kamerası {first} için beklenmedik bir fan anı yakaladı.",
    ],
    bodiesEn: [
      "A candid rehearsal clip of {first} started blowing up across social feeds.",
      "A backstage camera caught an adorable, viral fan-favorite moment with {first}.",
    ],
    choices: [
      StoryChoice(
        id: 'share',
        label: "ANI YAYINLA",
        labelEn: "RELEASE THE FULL CLIP",
        feedback: "Görünürlük hızla arttı.",
        feedbackEn: "Visibility surged dramatically.",
        effects: {'popularity': 5, 'buzz': 12, 'followers': 18000},
      ),
      StoryChoice(
        id: 'protect',
        label: "DOĞAL KALSIN",
        labelEn: "KEEP IT PRIVATE",
        feedback: "Kişisel sınırlar korundu.",
        feedbackEn: "Personal boundaries remained protected.",
        effects: {'morale': 5, 'professionalism': 3, 'followers': 5000},
      ),
    ],
  ),
  (
    id: 'vocal_fatigue',
    family: StoryEventFamily.rehearsal,
    category: StoryEventCategory.crisis,
    title: "SES YORGUNLUĞU",
    titleEn: "VOCAL STRAIN",
    bodies: [
      "{first} uzun vokal provasından sonra sesinde baskı hissediyor. Önemli kayıt ise birkaç saat sonra.",
    ],
    bodiesEn: [
      "{first} feels strain in her voice after long drills, with a key recording only hours away.",
    ],
    choices: [
      StoryChoice(
        id: 'perform',
        label: "KAYDA DEVAM ET",
        labelEn: "POWER THROUGH RECORDING",
        feedback: "Kaydı tamamladı ama bedeli enerjisine yansıdı.",
        feedbackEn: "Nailed the cut, but at the expense of her stamina.",
        effects: {'buzz': 7, 'energy': -10, 'vocalCoach': -2},
        followUpFlags: ['pushed_when_tired'],
      ),
      StoryChoice(
        id: 'rest',
        label: "SESİNİ DİNLENDİR",
        labelEn: "REST HER VOICE",
        feedback: "Sesini korudu; kayıt planı geriye alındı.",
        feedbackEn: "Vocal health protected; recording was rescheduled.",
        effects: {'energy': 9, 'preparation': -4, 'morale': 3},
      ),
      StoryChoice(
        id: 'coach',
        label: "VOKAL HOCASINA DANIŞ",
        labelEn: "CONSULT VOCAL COACH",
        feedback: "Program güvenli bir orta yolda yeniden kuruldu.",
        feedbackEn: "A safe, effective middle ground was found.",
        effects: {'energy': 4, 'vocalCoach': 5, 'preparation': 2},
      ),
    ],
  ),
  (
    id: 'solo_offer',
    family: StoryEventFamily.coach,
    category: StoryEventCategory.positive,
    title: "SOLO TEKLİFİ",
    titleEn: "SOLO FEATURE OFFER",
    bodies: [
      "Yapım ekibi {first} için kısa bir solo bölüm önerdi. Bu fırsat görünürlüğü artırabilir ama grup dengesini zorlayabilir.",
    ],
    bodiesEn: [
      "The production team proposed a featured solo section for {first}. It boosts exposure, but could disrupt group balance.",
    ],
    choices: [
      StoryChoice(
        id: 'accept',
        label: "SOLOYU KABUL ET",
        labelEn: "ACCEPT THE SOLO",
        feedback: "Solo büyük ilgi gördü; kuliste rekabet yükseldi.",
        feedbackEn:
            "The solo drew massive buzz; backstage competition intensified.",
        effects: {'popularity': 6, 'buzz': 10, 'morale': -2},
        followUpFlags: ['center_favored'],
      ),
      StoryChoice(
        id: 'share',
        label: "BÖLÜMÜ GRUPLA PAYLAŞ",
        labelEn: "SHARE WITH THE GROUP",
        feedback: "Görünürlük paylaşıldı ve takım rahatladı.",
        feedbackEn: "Exposure was shared and the team relaxed.",
        effects: {'popularity': 2, 'morale': 5, 'professionalism': 4},
      ),
    ],
  ),
  (
    id: 'high_note_pressure',
    family: StoryEventFamily.coach,
    category: StoryEventCategory.performance,
    title: "YÜKSEK NOTA BASKISI",
    titleEn: "HIGH NOTE PRESSURE",
    bodies: [
      "{first} teknik olarak notaya hazır, fakat tek denemelik canlı kayıt baskıyı büyütüyor.",
    ],
    bodiesEn: [
      "{first} is technically ready for the climax note, but a one-take live cut is ramping up the pressure.",
    ],
    choices: [
      StoryChoice(
        id: 'live',
        label: "CANLI SÖYLESİN",
        labelEn: "SING IT LIVE",
        feedback: "Riskli tercih güçlü bir sahne anına dönüştü.",
        feedbackEn: "The bold risk turned into a commanding stage moment.",
        effects: {'confidence': 6, 'buzz': 7, 'energy': -5},
      ),
      StoryChoice(
        id: 'lower',
        label: "TONU GÜVENLİ HALE GETİR",
        labelEn: "LOWER FOR SAFETY",
        feedback: "Performans temiz kaldı, sürpriz etkisi azaldı.",
        feedbackEn: "Execution remained clean, with less surprise impact.",
        effects: {'preparation': 6, 'professionalism': 3, 'buzz': -2},
      ),
    ],
  ),
  (
    id: 'dance_challenge',
    family: StoryEventFamily.viral,
    category: StoryEventCategory.positive,
    title: "DANS CHALLENGE’I YÜKSELİYOR",
    titleEn: "VIRAL DANCE CHALLENGE",
    bodies: [
      "{first}’in prova hareketi kısa videolarda hızla yayılıyor. Ekip trendi nasıl yöneteceğine karar vermeli.",
    ],
    bodiesEn: [
      "{first}'s rehearsal move is rapidly spreading in short clips. The team must decide how to steer the trend.",
    ],
    choices: [
      StoryChoice(
        id: 'publish',
        label: "RESMİ VİDEOYU YAYINLA",
        labelEn: "POST OFFICIAL VIDEO",
        feedback: "Challenge geniş bir kitleye ulaştı.",
        feedbackEn: "The challenge reached a mainstream audience.",
        effects: {'followers': 24000, 'buzz': 11, 'energy': -4},
      ),
      StoryChoice(
        id: 'team',
        label: "TÜM GRUBU VİDEOYA AL",
        labelEn: "FEATURE THE WHOLE GROUP",
        feedback: "Trend bireysel değil, takım anına dönüştü.",
        feedbackEn: "The viral spark became a team triumph.",
        effects: {'followers': 14000, 'morale': 5, 'popularity': 3},
      ),
    ],
  ),
  (
    id: 'choreo_strain',
    family: StoryEventFamily.rehearsal,
    category: StoryEventCategory.crisis,
    title: "KOREOGRAFİDE ZORLANMA",
    titleEn: "CHOREOGRAPHY STRAIN",
    bodies: [
      "{first} yoğun tekrar sırasında ayağında ağrı hissetti. Provanın kritik bölümü henüz tamamlanmadı.",
    ],
    bodiesEn: [
      "{first} felt foot pain during high-intensity repetitions, with critical formations still unfinished.",
    ],
    choices: [
      StoryChoice(
        id: 'continue',
        label: "PROVAYI TAMAMLASIN",
        labelEn: "FINISH FULL PRACTICE",
        feedback: "Koreografi oturdu, fiziksel yük arttı.",
        feedbackEn: "Choreography cemented, but physical exhaustion set in.",
        effects: {'preparation': 8, 'energy': -12},
        followUpFlags: ['pushed_when_tired'],
      ),
      StoryChoice(
        id: 'modify',
        label: "HAREKETİ UYARLA",
        labelEn: "ADAPT THE FORMATION",
        feedback: "Risk azaldı ve sahne akışı korundu.",
        feedbackEn: "Risk reduced while keeping the routine intact.",
        effects: {'energy': 5, 'preparation': 3, 'danceCoach': 3},
      ),
      StoryChoice(
        id: 'rest',
        label: "BUGÜN DİNLENDİR",
        labelEn: "BENCH FOR TODAY",
        feedback: "Fiziksel durum toparlandı; prova eksiği kaldı.",
        feedbackEn: "Physical stamina saved; a practice gap remains.",
        effects: {'energy': 12, 'preparation': -5},
      ),
    ],
  ),
  (
    id: 'brand_interest',
    family: StoryEventFamily.viral,
    category: StoryEventCategory.positive,
    title: "MARKA İLGİSİ",
    titleEn: "BRAND COLLAB INTEREST",
    bodies: [
      "Bir moda markası {first} ile kısa içerik çekmek istiyor. Teklif görünürlük sağlıyor ancak prova gününe denk geliyor.",
    ],
    bodiesEn: [
      "A fashion label wants to film a short promo with {first}. It promises great reach, but coincides with rehearsal day.",
    ],
    choices: [
      StoryChoice(
        id: 'accept',
        label: "TEKLİFİ KABUL ET",
        labelEn: "ACCEPT BRAND DEAL",
        feedback: "İş birliği konuşuldu; yoğun program enerjiyi düşürdü.",
        feedbackEn:
            "The collaboration gained buzz; tight hours lowered energy.",
        effects: {'followers': 20000, 'popularity': 5, 'energy': -7},
      ),
      StoryChoice(
        id: 'group',
        label: "GRUBA ÖZEL ANLAŞMA İSTE",
        labelEn: "REQUEST GROUP PACKAGE",
        feedback: "Daha küçük ama dengeli bir grup fırsatı doğdu.",
        feedbackEn: "Created a balanced, group-wide opportunity.",
        effects: {'followers': 9000, 'morale': 6, 'buzz': 4},
      ),
    ],
  ),
  (
    id: 'unexpected_views',
    family: StoryEventFamily.viral,
    category: StoryEventCategory.positive,
    title: "PERFORMANS REKOR İZLENDİ",
    titleEn: "RECORD PERFORMANCE VIEWS",
    bodies: [
      "{first}’in performans kesiti beklenenden çok daha fazla izlendi. Yeni ilgiyi hızlı mı yoksa kontrollü mü kullanacaksın?",
    ],
    bodiesEn: [
      "A fancam cut of {first} racked up far higher views than anticipated. How will you steer this new wave of attention?",
    ],
    choices: [
      StoryChoice(
        id: 'boost',
        label: "İLGİYİ BÜYÜT",
        labelEn: "AMPLIFY THE MOMENTUM",
        feedback: "Yeni içerik dalgası takipçiyi hızla artırdı.",
        feedbackEn: "A wave of new content surged follower numbers.",
        effects: {'followers': 28000, 'buzz': 10, 'energy': -4},
      ),
      StoryChoice(
        id: 'pace',
        label: "TEMPOYU KORU",
        labelEn: "MAINTAIN STEADY PACE",
        feedback: "İlgi sürdürülebilir biçimde yönetildi.",
        feedbackEn: "Audience interest was managed sustainably.",
        effects: {'followers': 11000, 'professionalism': 5, 'morale': 3},
      ),
    ],
  ),
  (
    id: 'styling_attention',
    family: StoryEventFamily.viral,
    category: StoryEventCategory.positive,
    title: "STYLING KONUŞULUYOR",
    titleEn: "STYLING HIGHLIGHT",
    bodies: [
      "{first}’in prova styling’i fan hesaplarında öne çıktı. Ekip bu estetik yönü sahne konseptine taşımayı düşünüyor.",
    ],
    bodiesEn: [
      "{first}'s practice outfit became a trending topic on fan channels. The team considers weaving this visual edge into stage concept.",
    ],
    choices: [
      StoryChoice(
        id: 'feature',
        label: "KONSEPTE TAŞI",
        labelEn: "INTEGRATE INTO CONCEPT",
        feedback: "Görsel kimlik daha güçlü ve konuşulur hale geldi.",
        feedbackEn: "Visual identity gained distinct character and buzz.",
        effects: {'buzz': 9, 'popularity': 4, 'confidence': 3},
      ),
      StoryChoice(
        id: 'keep',
        label: "SAHNEYİ SADE TUT",
        labelEn: "KEEP STAGE SIMPLE",
        feedback: "Dikkat performansta kaldı.",
        feedbackEn: "Focus remained squarely on performance craft.",
        effects: {'preparation': 5, 'professionalism': 3},
      ),
    ],
  ),
  (
    id: 'athlete_schedule',
    family: StoryEventFamily.privateLife,
    category: StoryEventCategory.crisis,
    title: "PROGRAM ÇAKIŞMASI",
    titleEn: "SCHEDULE CONFLICT",
    bodies: [
      "Zeynep Ela’nın profesyonel spor programı önemli prova saatine denk geldi. İki disiplin de tam katılım bekliyor.",
    ],
    bodiesEn: [
      "Zeynep Ela's professional athletic commitments coincided with a pivotal rehearsal time. Both disciplines demand total commitment.",
    ],
    choices: [
      StoryChoice(
        id: 'stage',
        label: "PROVAYI ÖNCELİKLENDİR",
        labelEn: "PRIORITIZE REHEARSAL",
        feedback: "Sahne hazırlığı güçlendi; fiziksel toparlanma kısaldı.",
        feedbackEn: "Stage execution sharpened; recovery time was compressed.",
        effects: {'preparation': 8, 'energy': -8},
      ),
      StoryChoice(
        id: 'balance',
        label: "PROGRAMI BÖL",
        labelEn: "SPLIT THE TIMETABLE",
        feedback: "İki sorumluluk dengelendi, gün yorucu geçti.",
        feedbackEn: "Both duties met, resulting in a taxing day.",
        effects: {'professionalism': 6, 'energy': -3, 'morale': 3},
      ),
      StoryChoice(
        id: 'coach',
        label: "HOCALARLA PLANLA",
        labelEn: "COORDINATE WITH COACHES",
        feedback: "Yük güvenli biçimde yeniden dağıtıldı.",
        feedbackEn: "Workload was safely redistributed.",
        effects: {'energy': 5, 'preparation': 4, 'professionalism': 3},
      ),
    ],
  ),
  (
    id: 'athlete_viral',
    family: StoryEventFamily.viral,
    category: StoryEventCategory.positive,
    title: "SPORCU GEÇMİŞİ VİRAL",
    titleEn: "ATHLETE ROOTS GO VIRAL",
    bodies: [
      "Zeynep Ela’nın eski maç görüntüleri sosyal medyada yeniden keşfedildi. Disiplini yeni izleyicilerin dikkatini çekiyor.",
    ],
    bodiesEn: [
      "Old match clips of Zeynep Ela were rediscovered online. Her fierce athletic discipline is drawing fresh eyes to the show.",
    ],
    choices: [
      StoryChoice(
        id: 'story',
        label: "HİKÂYESİNİ PAYLAŞ",
        labelEn: "SHARE HER JOURNEY",
        feedback: "Spor ve sahne yolculuğu geniş bir kitleye ulaştı.",
        feedbackEn:
            "Her dual path in sports and music touched a broad audience.",
        effects: {'followers': 26000, 'popularity': 6, 'buzz': 9},
      ),
      StoryChoice(
        id: 'team',
        label: "TAKIM ANTRENMANINA ÇEVİR",
        labelEn: "TURN INTO TEAM DRILL",
        feedback: "İlgi grubun çalışma enerjisine yayıldı.",
        feedbackEn: "Her stamina inspired the entire team's rehearsal.",
        effects: {'followers': 12000, 'morale': 6, 'preparation': 4},
      ),
    ],
  ),
  (
    id: 'architecture_deadline',
    family: StoryEventFamily.privateLife,
    category: StoryEventCategory.crisis,
    title: "TESLİM VE PROVA AYNI GÜN",
    titleEn: "DEADLINE CRUNCH",
    bodies: [
      "Lara’nın mimarlık proje teslimi prova programıyla çakıştı. Uykusuz kalmadan ikisini birden tamamlaması zor görünüyor.",
    ],
    bodiesEn: [
      "Lara's architecture studio submission clashes with main rehearsal. Finishing both without all-nighters looks nearly impossible.",
    ],
    choices: [
      StoryChoice(
        id: 'rehearse',
        label: "PROVAYI ÖNCELİKLENDİR",
        labelEn: "PRIORITIZE REHEARSAL",
        feedback: "Sahne hazırlandı; teslim baskısı motivasyonunu etkiledi.",
        feedbackEn: "Stage was prepared; project stress weighed on her mood.",
        effects: {'preparation': 7, 'morale': -5, 'energy': -4},
      ),
      StoryChoice(
        id: 'deadline',
        label: "TESLİM İÇİN ZAMAN VER",
        labelEn: "GIVE TIME FOR DEADLINE",
        feedback: "Lara zihnini toparladı; prova süresi kısaldı.",
        feedbackEn: "Lara cleared her head; rehearsal time shrank.",
        effects: {'morale': 8, 'preparation': -4, 'energy': 3},
      ),
      StoryChoice(
        id: 'plan',
        label: "PROGRAMI YENİDEN KUR",
        labelEn: "REDISPATCH SCHEDULE",
        feedback: "Yaratıcı ve dengeli bir çalışma planı bulundu.",
        feedbackEn: "A creative, balanced study plan was found.",
        effects: {'professionalism': 6, 'preparation': 3, 'energy': -2},
      ),
    ],
  ),
  (
    id: 'lara_stage_design',
    family: StoryEventFamily.coach,
    category: StoryEventCategory.positive,
    title: "LARA’DAN SAHNE FİKRİ",
    titleEn: "LARA’S STAGE CONCEPT",
    bodies: [
      "Lara renk, biçim ve kamera aksını birleştiren özgün bir sahne düzeni çizdi. Fikir güçlü ama son dakika değişikliği gerektiriyor.",
    ],
    bodiesEn: [
      "Lara sketched a fresh stage layout merging color, spatial geometry, and camera angles. A brilliant idea, but requires last-minute tweaks.",
    ],
    choices: [
      StoryChoice(
        id: 'use',
        label: "FİKRİ UYGULA",
        labelEn: "ADAPT THE CONCEPT",
        feedback: "Yeni kompozisyon sahnenin görsel kimliğini güçlendirdi.",
        feedbackEn: "The new visual composition elevated the entire set.",
        effects: {'buzz': 10, 'confidence': 6, 'preparation': -2},
      ),
      StoryChoice(
        id: 'adapt',
        label: "FİKRİ SADELEŞTİR",
        labelEn: "SIMPLIFY FOR RUNTIME",
        feedback: "Yaratıcı dokunuş prova düzenini bozmadan kullanıldı.",
        feedbackEn:
            "Creative flair incorporated without disrupting formations.",
        effects: {'buzz': 5, 'professionalism': 5, 'morale': 3},
      ),
    ],
  ),
  (
    id: 'gulce_center_tension',
    family: StoryEventFamily.relationship,
    category: StoryEventCategory.relationship,
    title: "MERKEZDE FAZLA MI KALIYOR?",
    titleEn: "TOO MUCH TIME AT CENTER?",
    bodies: [
      "Gülce’nin güçlü performansı merkez anlarını artırdı. {second}, dağılımın takım dengesini bozduğunu düşünüyor.",
    ],
    bodiesEn: [
      "Gülce's commanding stage presence has steadily increased her center time. {second} feels the distribution tilts group balance.",
    ],
    choices: [
      StoryChoice(
        id: 'keep',
        label: "GÜLCE’Yİ MERKEZDE TUT",
        labelEn: "KEEP GÜLCE AT CENTER",
        feedback: "Performans gücü korundu; kuliste mesafe oluştu.",
        feedbackEn: "Stage impact was undeniable; backstage distance formed.",
        effects: {'buzz': 8, 'relationship': -7, 'confidence': 4},
        followUpFlags: ['center_favored'],
      ),
      StoryChoice(
        id: 'share',
        label: "MERKEZİ PAYLAŞTIR",
        labelEn: "SHARE CENTER FORMATION",
        feedback: "Sahne dengesi ve takım güveni güçlendi.",
        feedbackEn: "Stage balance and mutual trust were reaffirmed.",
        effects: {'relationship': 9, 'morale': 5, 'buzz': 2},
      ),
      StoryChoice(
        id: 'audition',
        label: "HOCALARA KISA TEST YAPTIR",
        labelEn: "RUN SHORT MENTOR TEST",
        feedback: "Karar performans ölçümüne bağlandı.",
        feedbackEn: "Placement decided through objective stage evaluation.",
        effects: {'preparation': 6, 'relationship': 2, 'energy': -3},
      ),
    ],
  ),
  (
    id: 'gulce_solo_spotlight',
    family: StoryEventFamily.coach,
    category: StoryEventCategory.positive,
    title: "GÜLCE’YE SOLO FIRSATI",
    titleEn: "SOLO SPOTLIGHT FOR GÜLCE",
    bodies: [
      "Gülce’nin vokal, dans ve sahne gücü yapım ekibinden özel bir solo teklif getirdi. Fırsat büyük, beklenti daha da büyük.",
    ],
    bodiesEn: [
      "Gülce's combined prowess in vocal, dance, and charisma prompted an exclusive solo pitch from directors. Huge opportunity, even bigger expectations.",
    ],
    choices: [
      StoryChoice(
        id: 'accept',
        label: "SOLOYU AÇ",
        labelEn: "GREENLIGHT SOLO",
        feedback: "Gülce’nin yıldız anı gündeme oturdu.",
        feedbackEn: "Gülce's spotlight became the top trending topic.",
        effects: {'followers': 25000, 'buzz': 11, 'energy': -6},
        followUpFlags: ['center_favored'],
      ),
      StoryChoice(
        id: 'group',
        label: "GRUP ANINA DÖNÜŞTÜR",
        labelEn: "REFRAME AS GROUP STAGE",
        feedback: "Doğal yetenek takım sahnesini yukarı taşıdı.",
        feedbackEn:
            "Her talent elevated the ensemble without leaving anyone out.",
        effects: {'followers': 12000, 'morale': 6, 'professionalism': 4},
      ),
    ],
  ),
  (
    id: 'burnout_followup',
    family: StoryEventFamily.privateLife,
    category: StoryEventCategory.crisis,
    title: "TÜKENMİŞLİK SİNYALİ",
    titleEn: "BURNOUT SIGNAL",
    bodies: [
      "{first} son günlerde dinlenmeden çalıştı. Konsantrasyonu düşerken önemli prova yaklaşmaya devam ediyor.",
    ],
    bodiesEn: [
      "{first} has trained without rest for days. As her stamina wavers, a critical group milestone draws near.",
    ],
    choices: [
      StoryChoice(
        id: 'rest',
        label: "TAM DİNLENME VER",
        labelEn: "MANDATE FULL REST",
        feedback: "Enerjisi geri geldi; hazırlık programı daraldı.",
        feedbackEn: "Energy returned, though prep time grew tight.",
        effects: {'energy': 16, 'morale': 7, 'preparation': -7},
      ),
      StoryChoice(
        id: 'light',
        label: "HAFİF PROGRAM UYGULA",
        labelEn: "SWITCH TO LIGHT DRILL",
        feedback: "Tempo düşürüldü ve hazırlık tamamen kopmadı.",
        feedbackEn: "Pace eased while preserving basic muscle memory.",
        effects: {'energy': 8, 'preparation': 2, 'professionalism': 3},
      ),
      StoryChoice(
        id: 'push',
        label: "PROGRAMI SÜRDÜR",
        labelEn: "STAY THE COURSE",
        feedback: "Prova tamamlandı ama yorgunluk derinleşti.",
        feedbackEn: "Practice completed, but physical fatigue intensified.",
        effects: {'preparation': 9, 'energy': -14, 'morale': -6},
        followUpFlags: ['pushed_when_tired'],
      ),
    ],
  ),
  (
    id: 'team_harmony',
    family: StoryEventFamily.relationship,
    category: StoryEventCategory.positive,
    title: "GRUP UYUMU YÜKSELİYOR",
    titleEn: "GROUP CHEMISTRY PEAKING",
    bodies: [
      "{first} ve {second} görev paylaşımını kendiliğinden dengeledi. Prova odasındaki rahatlık tüm takıma yansıyor.",
    ],
    bodiesEn: [
      "{first} and {second} balanced their responsibilities instinctively. The warmth in their rehearsal room is spreading to all members.",
    ],
    choices: [
      StoryChoice(
        id: 'capture',
        label: "BU ANI İÇERİĞE DÖNÜŞTÜR",
        labelEn: "TURN INTO CONTENT",
        feedback: "Doğal arkadaşlık fanların dikkatini çekti.",
        feedbackEn: "Their genuine bond captured hearts on social feeds.",
        effects: {'relationship': 8, 'followers': 14000, 'buzz': 6},
      ),
      StoryChoice(
        id: 'protect',
        label: "KULİSTE BIRAK",
        labelEn: "KEEP FOR BACKSTAGE",
        feedback: "Uyum gösteriye dönüşmeden güçlendi.",
        feedbackEn: "Harmony deepened without being turned into a show.",
        effects: {'relationship': 11, 'morale': 7},
      ),
    ],
  ),
  (
    id: 'favoritism_backlash',
    family: StoryEventFamily.relationship,
    category: StoryEventCategory.crisis,
    title: "AYRICALIK TARTIŞMASI",
    titleEn: "FAVORITISM DISPUTE",
    bodies: [
      "{first}’e tanınan görünürlük kuliste ayrıcalık tartışması başlattı. {second}, adaletin sağlanmasını bekliyor.",
      "Grupta tek bir ismin öne çıkarılması {first} ve {second} arasında gerilim yarattı.",
    ],
    bodiesEn: [
      "Repeated spotlight on {first} sparked whispers of favoritism backstage. {second} is waiting for fair adjustments.",
      "Spotlighting a single contestant caused friction between {first} and {second}.",
    ],
    choices: [
      StoryChoice(
        id: 'balance',
        label: "TÜM GRUBA EŞİT ALAN TAAHHÜT ET",
        labelEn: "PROMISE EQUAL TIME",
        feedback: "Denge sağlandı, takım güveni tazelendi.",
        feedbackEn: "Balance restored and team trust refreshed.",
        effects: {'morale': 6, 'relationship': 8, 'buzz': -2},
      ),
      StoryChoice(
        id: 'star',
        label: "YILDIZIN PERFORMANSINI SAVUN",
        labelEn: "DEFEND THE ACE",
        feedback: "Kararlılık netleşti; kuliste mesafe büyüdü.",
        feedbackEn: "Decisiveness was clear, but backstage distance widened.",
        effects: {'buzz': 8, 'popularity': 4, 'relationship': -8, 'morale': -4},
      ),
      StoryChoice(
        id: 'coach',
        label: "HOCALARLA ORTAK TOPLANTI DÜZENLE",
        labelEn: "CONVENE WITH COACHES",
        feedback: "Koçların değerlendirmesi ortamı sakinleştirdi.",
        feedbackEn: "Mentor insights cooled the room and restored focus.",
        effects: {'professionalism': 6, 'morale': 3, 'preparation': 3},
      ),
    ],
  ),
  (
    id: 'duru_pitch_perfection',
    family: StoryEventFamily.rehearsal,
    category: StoryEventCategory.performance,
    title: "PERFEKSİYONİZM BASKISI",
    titleEn: "PERFECTIONISM STRAIN",
    bodies: [
      "Duru vokal armonilerinde kusursuzluk ararken provayı uzattı. Takım yorgunluk hissetmeye başladı.",
      "Duru en ufak detayı tekrar etmek istiyor; prova süresi daralıyor.",
    ],
    bodiesEn: [
      "Duru chased absolute perfection in vocal harmonies, dragging rehearsal late into the night. Weariness crept over the room.",
      "Duru insisted on repeating the slightest vocal inflection; rehearsal time was slipping away.",
    ],
    choices: [
      StoryChoice(
        id: 'encourage',
        label: "STANDARDI KORU",
        labelEn: "UPHOLD THE STANDARD",
        feedback: "Vokal seviyesi yükseldi, enerji düştü.",
        feedbackEn: "Vocal caliber rose, but energy levels dipped.",
        effects: {'preparation': 8, 'energy': -5, 'confidence': 4},
      ),
      StoryChoice(
        id: 'limit',
        label: "PROVAYI SINIRLA",
        labelEn: "WRAP UP REHEARSAL",
        feedback: "Ekip dinlendi; Duru içine sinmese de kabul etti.",
        feedbackEn: "Team rested; Duru accepted the compromise reluctantly.",
        effects: {'energy': 6, 'morale': 3, 'preparation': -2},
      ),
      StoryChoice(
        id: 'coach',
        label: "VOKAL KOÇUNA DEVRET",
        labelEn: "HAND OFF TO COACH",
        feedback: "Koç rehberliğinde verimli bir denge bulundu.",
        feedbackEn:
            "Under mentor guidance, an efficient middle ground was found.",
        effects: {'vocalCoach': 6, 'preparation': 4, 'morale': 2},
      ),
    ],
  ),
  (
    id: 'ada_backstage_warmth',
    family: StoryEventFamily.relationship,
    category: StoryEventCategory.positive,
    title: "KULİSTE MORAL DESTEĞİ",
    titleEn: "BACKSTAGE MORALE BOOST",
    bodies: [
      "Ada prova stresinin tırmandığı anda herkesi güldürüp ortamın havasını değiştirdi.",
      "Ada gergin geçen çalışmanın ardından takıma moral ikramı hazırladı.",
    ],
    bodiesEn: [
      "Ada had everyone laughing just as rehearsal tension peaked, completely shifting the mood.",
      "Ada prepared snacks and thoughtful notes for the crew after a gruelling run.",
    ],
    choices: [
      StoryChoice(
        id: 'highlight',
        label: "BU ENERJİYİ KAMERAYA YANSIT",
        labelEn: "AIR HER WARMTH",
        feedback: "Doğal neşe izleyicilerin sempatisini kazandı.",
        feedbackEn: "Her natural warmth won widespread fan sympathy.",
        effects: {'followers': 18000, 'popularity': 5, 'buzz': 6},
      ),
      StoryChoice(
        id: 'team',
        label: "TAKIM BAĞINI GÜÇLENDİR",
        labelEn: "SOLIDIFY TEAM BOND",
        feedback: "Kulis huzuru provaya doğrudan yansıdı.",
        feedbackEn:
            "Backstage peace translated into sharper stage coordination.",
        effects: {'morale': 8, 'relationship': 7, 'energy': 4},
      ),
    ],
  ),
  (
    id: 'alara_choreo_sync',
    family: StoryEventFamily.rehearsal,
    category: StoryEventCategory.crisis,
    title: "SENKRONİZASYON TARTIŞMASI",
    titleEn: "SYNCHRONIZATION CLASH",
    bodies: [
      "Alara dans temposunun yeterince keskin olmadığını belirterek ekibe ağır bir tempo dayattı.",
      "Alara koreografideki milimetrik hataları düzeltmek için sert bir üslup kullandı.",
    ],
    bodiesEn: [
      "Alara demanded razor-sharp dance precision, imposing an exhausting drill routine on the group.",
      "Alara used blunt language to fix millimeter mistakes across the formation.",
    ],
    choices: [
      StoryChoice(
        id: 'support',
        label: "DİSİPLİNİNİ DESTEKLE",
        labelEn: "BACK HER DISCIPLINE",
        feedback: "Dans hatasızlaştı; kuliste gerginlik oluştu.",
        feedbackEn: "Dance became flawless; backstage tension simmered.",
        effects: {'preparation': 9, 'professionalism': 5, 'morale': -4},
      ),
      StoryChoice(
        id: 'soften',
        label: "ÜSLUBUNU YUMUŞAT",
        labelEn: "SOFTEN HER TONE",
        feedback: "Daha yapıcı bir iletişim kuruldu.",
        feedbackEn: "Constructive dialogue took root across the room.",
        effects: {'morale': 6, 'relationship': 5, 'preparation': 3},
      ),
      StoryChoice(
        id: 'coach',
        label: "DANS KOÇUNU ÇAĞIR",
        labelEn: "CALL IN DANCE COACH",
        feedback: "Koç teknik düzeltmeleri üstlendi.",
        feedbackEn: "The coach took charge of technical refinements.",
        effects: {'danceCoach': 6, 'preparation': 5, 'energy': -2},
      ),
    ],
  ),
  (
    id: 'derin_stage_expression',
    family: StoryEventFamily.coach,
    category: StoryEventCategory.positive,
    title: "DUYGU AKTARIMI ETKİLEDİ",
    titleEn: "CAPTIVATING EMOTION",
    bodies: [
      "Derin sahne provasında şarkının duygusunu öyle hissettirdi ki stüdyo bir an sessizliğe büründü.",
      "Derin’in mimik ve bakış kontrolü yönetmenin özellikle dikkatini çekti.",
    ],
    bodiesEn: [
      "Derin poured such genuine emotion into the ballad rehearsal that the room briefly fell silent.",
      "Derin's delicate facial expressions and gaze control caught the director's eye.",
    ],
    choices: [
      StoryChoice(
        id: 'spotlight',
        label: "KAMERA PLANI VER",
        labelEn: "GRANT CLOSE-UP SHOTS",
        feedback: "Duygu dolu yakın planlar şovun zirvesi oldu.",
        feedbackEn:
            "Emotional close-ups became the crowning moment of the stage.",
        effects: {'buzz': 11, 'popularity': 5, 'confidence': 5},
      ),
      StoryChoice(
        id: 'depth',
        label: "VOKAL VE HAREKETLE BİRLEŞTİR",
        labelEn: "BLEND WITH ENSEMBLE",
        feedback: "Teknik ve duygu bütünlüğü sağlandı.",
        feedbackEn: "Seamless unity of vocal nuance and choreography.",
        effects: {'preparation': 7, 'professionalism': 4, 'morale': 4},
      ),
    ],
  ),
  (
    id: 'mina_social_rumor',
    family: StoryEventFamily.viral,
    category: StoryEventCategory.social,
    title: "SOSYAL MEDYADA ASILSIZ İDDİA",
    titleEn: "FALSE RUMOR SPREADS",
    bodies: [
      "Sosyal medyada Mina hakkında eski bir video üzerinden spekülasyon başlatıldı.",
      "Mina internetteki olumsuz yorumları görünce provaya odaklanmakta zorlandı.",
    ],
    bodiesEn: [
      "Speculation about Mina flared online based on an out-of-context video.",
      "Mina struggled to concentrate after seeing hurtful online chatter.",
    ],
    choices: [
      StoryChoice(
        id: 'statement',
        label: "RESMİ AÇIKLAMA YAP",
        labelEn: "ISSUE FORMAL STATEMENT",
        feedback: "Spekülasyon kesildi; profesyonel duruş övgü aldı.",
        feedbackEn: "Rumor debunked; management poise was widely commended.",
        effects: {'professionalism': 7, 'buzz': 5, 'morale': 3},
      ),
      StoryChoice(
        id: 'ignore',
        label: "GÖRMEZDEN GEL, SAHNEYE ODAKLAN",
        labelEn: "STAY SILENT, FOCUS ON STAGE",
        feedback: "Dedikodu kendi kendine söndü, enerji korundu.",
        feedbackEn: "Drama fizzled on its own, preserving energy.",
        effects: {'confidence': 6, 'preparation': 4, 'buzz': -2},
      ),
      StoryChoice(
        id: 'support',
        label: "EKİPÇE DESTEK VER",
        labelEn: "RALLY THE TEAM",
        feedback: "Takım dayanışması Mina’ya büyük moral oldu.",
        feedbackEn: "Team solidarity gave Mina immense emotional backing.",
        effects: {'morale': 9, 'relationship': 6, 'followers': 8000},
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
    requirements: <String>[],
  ),
  'vocal_sharing': (
    audience: _Audience.relationship,
    weight: 9,
    cooldownDays: 3,
    requiredFlag: null,
    requirements: <String>[],
  ),
  'confidence_drop': (
    audience: _Audience.any,
    weight: 11,
    cooldownDays: 2,
    requiredFlag: null,
    requirements: <String>[],
  ),
  'fan_pressure': (
    audience: _Audience.popular,
    weight: 10,
    cooldownDays: 2,
    requiredFlag: null,
    requirements: <String>[],
  ),
  'breakout_moment': (
    audience: _Audience.any,
    weight: 12,
    cooldownDays: 2,
    requiredFlag: null,
    requirements: <String>[],
  ),
  'bonding': (
    audience: _Audience.relationship,
    weight: 10,
    cooldownDays: 3,
    requiredFlag: null,
    requirements: <String>[],
  ),
  'viral_rehearsal': (
    audience: _Audience.any,
    weight: 11,
    cooldownDays: 2,
    requiredFlag: null,
    requirements: <String>[],
  ),
  'late_rehearsal': (
    audience: _Audience.any,
    weight: 10,
    cooldownDays: 2,
    requiredFlag: null,
    requirements: <String>[],
  ),
  'vocal_fatigue': (
    audience: _Audience.vocal,
    weight: 12,
    cooldownDays: 2,
    requiredFlag: null,
    requirements: <String>[],
  ),
  'solo_offer': (
    audience: _Audience.vocal,
    weight: 10,
    cooldownDays: 3,
    requiredFlag: null,
    requirements: <String>[],
  ),
  'high_note_pressure': (
    audience: _Audience.vocal,
    weight: 9,
    cooldownDays: 2,
    requiredFlag: null,
    requirements: <String>[],
  ),
  'dance_challenge': (
    audience: _Audience.dance,
    weight: 11,
    cooldownDays: 2,
    requiredFlag: null,
    requirements: <String>[],
  ),
  'choreo_strain': (
    audience: _Audience.dance,
    weight: 12,
    cooldownDays: 2,
    requiredFlag: null,
    requirements: <String>[],
  ),
  'brand_interest': (
    audience: _Audience.popular,
    weight: 9,
    cooldownDays: 3,
    requiredFlag: null,
    requirements: <String>[],
  ),
  'unexpected_views': (
    audience: _Audience.stage,
    weight: 10,
    cooldownDays: 2,
    requiredFlag: null,
    requirements: <String>[],
  ),
  'styling_attention': (
    audience: _Audience.stage,
    weight: 9,
    cooldownDays: 2,
    requiredFlag: null,
    requirements: <String>[],
  ),
  'athlete_schedule': (
    audience: _Audience.zeynepEla,
    weight: 14,
    cooldownDays: 3,
    requiredFlag: null,
    requirements: <String>[],
  ),
  'athlete_viral': (
    audience: _Audience.zeynepEla,
    weight: 12,
    cooldownDays: 3,
    requiredFlag: null,
    requirements: <String>[],
  ),
  'architecture_deadline': (
    audience: _Audience.lara,
    weight: 14,
    cooldownDays: 3,
    requiredFlag: null,
    requirements: <String>[],
  ),
  'lara_stage_design': (
    audience: _Audience.lara,
    weight: 12,
    cooldownDays: 3,
    requiredFlag: null,
    requirements: <String>[],
  ),
  'gulce_center_tension': (
    audience: _Audience.gulce,
    weight: 14,
    cooldownDays: 3,
    requiredFlag: null,
    requirements: <String>[],
  ),
  'gulce_solo_spotlight': (
    audience: _Audience.gulce,
    weight: 12,
    cooldownDays: 3,
    requiredFlag: null,
    requirements: <String>[],
  ),
  'burnout_followup': (
    audience: _Audience.lowEnergy,
    weight: 16,
    cooldownDays: 2,
    requiredFlag: 'pushed_when_tired',
    requirements: <String>['pushed_when_tired'],
  ),
  'team_harmony': (
    audience: _Audience.relationship,
    weight: 11,
    cooldownDays: 2,
    requiredFlag: null,
    requirements: <String>[],
  ),
  'favoritism_backlash': (
    audience: _Audience.relationship,
    weight: 16,
    cooldownDays: 2,
    requiredFlag: 'center_favored',
    requirements: <String>['center_favored'],
  ),
  'duru_pitch_perfection': (
    audience: _Audience.duru,
    weight: 14,
    cooldownDays: 3,
    requiredFlag: null,
    requirements: <String>[],
  ),
  'ada_backstage_warmth': (
    audience: _Audience.ada,
    weight: 13,
    cooldownDays: 3,
    requiredFlag: null,
    requirements: <String>[],
  ),
  'alara_choreo_sync': (
    audience: _Audience.alara,
    weight: 14,
    cooldownDays: 3,
    requiredFlag: null,
    requirements: <String>[],
  ),
  'derin_stage_expression': (
    audience: _Audience.derin,
    weight: 13,
    cooldownDays: 3,
    requiredFlag: null,
    requirements: <String>[],
  ),
  'mina_social_rumor': (
    audience: _Audience.mina,
    weight: 14,
    cooldownDays: 3,
    requiredFlag: null,
    requirements: <String>[],
  ),
};
