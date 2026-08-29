import 'package:yildiz_kadro/features/contestants/domain/contestant.dart';
import 'package:yildiz_kadro/features/contestants/domain/contestant_identity.dart';
import 'package:yildiz_kadro/features/group_task/data/group_task_profiles.dart';
import 'package:yildiz_kadro/features/group_task/domain/group_task_profile.dart';

ContestantIdentity identityFor(Contestant contestant) {
  final style = groupTaskProfiles[contestant.id]!.workStyle;
  final competitive = {
    WorkStyle.competitive,
    WorkStyle.bold,
    WorkStyle.direct,
  }.contains(style);
  final supportive = {
    WorkStyle.calm,
    WorkStyle.social,
    WorkStyle.protective,
    WorkStyle.experienced,
  }.contains(style);
  final visibility = contestant.stage >= 90 ||
          style == WorkStyle.cameraSavvy ||
          style == WorkStyle.bold
      ? 88
      : contestant.stage;
  return ContestantIdentity(
    hook: _hook(contestant, style),
    goal: _goal(contestant),
    characterStrength: contestant.specialTraitDescription,
    sensitivity: contestant.riskDescription,
    competition: competitive ? 88 : 48 + contestant.stage ~/ 3,
    leadership: supportive
        ? 82
        : style == WorkStyle.direct || style == WorkStyle.controlled
            ? 76
            : 55,
    visibility: visibility.clamp(0, 100),
    teamwork: supportive
        ? 88
        : competitive
            ? 58
            : 72,
    discipline: switch (style) {
      WorkStyle.controlled || WorkStyle.experienced => 92,
      WorkStyle.chaotic || WorkStyle.spontaneous => 48,
      _ => 68 + (contestant.vocal + contestant.dance) ~/ 12,
    }
        .clamp(0, 100),
    riskTaking: switch (style) {
      WorkStyle.bold || WorkStyle.spontaneous => 90,
      WorkStyle.calm || WorkStyle.controlled => 42,
      _ => 64,
    },
    conflictDirectness: switch (style) {
      WorkStyle.direct || WorkStyle.competitive || WorkStyle.bold => 88,
      WorkStyle.sensitive || WorkStyle.calm => 38,
      _ => 62,
    },
    preferredRoles: contestant.candidatePositions,
    underPressure: _pressure(style),
  );
}

String leadershipCommentFor(Contestant contestant) {
  final identity = identityFor(contestant);
  final strength = identity.leadership >= 80
      ? 'Takımın sesini dinleyip güven veren bir yön çizebilir.'
      : identity.visibility >= 85
          ? 'Karar anında geri çekilmez ve sahnedeki yönü netleştirir.'
          : 'Sessiz bir liderlik kurup ayrıntıları fark edebilir.';
  final risk = identity.competition >= 80
      ? 'Ancak rekabet duygusu kararlarını gereğinden sertleştirebilir.'
      : identity.teamwork < 65
          ? 'Ancak farklı çalışma hızlarını aynı çizgide tutmakta zorlanabilir.'
          : identity.leadership < 65
              ? 'Ancak kriz anında son sözü söylemeyi erteleyebilir.'
              : 'Ancak herkesin yükünü üstlenirse kendi enerjisini tüketebilir.';
  return '$strength $risk';
}

String roleSuitabilityFor(Contestant contestant, String role) {
  final identity = identityFor(contestant);
  final score = role.contains('VOKAL')
      ? contestant.vocal
      : role.contains('DANCER') || role.contains('DANS')
          ? contestant.dance
          : contestant.stage;
  final characterBonus = role == 'CENTER'
      ? identity.visibility
      : role.startsWith('LEAD')
          ? identity.leadership
          : identity.teamwork;
  final fit = (score * .7 + characterBonus * .3).round();
  if (fit >= 86) return '★ GÜÇLÜ UYUM · Karakteri ve yeteneği bu rolü taşıyor.';
  if (fit >= 76) return 'DENGELİ UYUM · Prova sonucu belirleyici olacak.';
  return 'RİSKLİ TERCİH · Bu rol daha fazla hazırlık isteyecek.';
}

String _hook(Contestant c, WorkStyle style) => switch (style) {
      WorkStyle.competitive => 'Rekabet baskısı onu daha güçlü yapabiliyor.',
      WorkStyle.calm =>
        'Teknik olarak güçlü; görünür olmak için zamana ihtiyaç duyuyor.',
      WorkStyle.social => 'Takım içindeki gerilimi doğal biçimde yatıştırıyor.',
      WorkStyle.controlled =>
        'Sessiz ama çok disiplinli; hazırlıksız yakalanmayı sevmiyor.',
      WorkStyle.cameraSavvy =>
        'Kamera açıldığında enerjisi belirgin biçimde yükseliyor.',
      WorkStyle.chaotic =>
        'Doğal yeteneği yüksek; prova disiplini gününe göre değişiyor.',
      WorkStyle.sensitive =>
        'Geri bildirimi derinden hissediyor ama doğru destekle büyüyor.',
      WorkStyle.bold =>
        'Sahneyi paylaşmaktan korkmuyor; geri planda kalmayı sevmiyor.',
      _ => c.shortBackground,
    };

String _goal(Contestant c) {
  if (c.primaryRole.contains('Vokal')) {
    return 'Final grubunun güvenilir vokal hattında yer almak.';
  }
  if (c.primaryRole.contains('Dans')) {
    return 'Grubun performans standardını belirlemek.';
  }
  if (c.primaryRole.contains('Merkez')) {
    return 'Final sahnesinin unutulmayan yüzü olmak.';
  }
  return 'Kendisini tek bir rolle sınırlamayan bir yıldız olmak.';
}

String _pressure(WorkStyle style) => switch (style) {
      WorkStyle.competitive ||
      WorkStyle.bold =>
        'Baskı yükseldikçe daha iddialı davranır.',
      WorkStyle.calm ||
      WorkStyle.controlled =>
        'Planına tutunur ve hata payını azaltır.',
      WorkStyle.sensitive =>
        'İlk anda içine kapanabilir; güven verilince toparlanır.',
      WorkStyle.chaotic ||
      WorkStyle.spontaneous =>
        'Risk alır; sonucu parlak da dağınık da olabilir.',
      _ => 'Önce gözlemler, ardından kendi ritmini bulur.',
    };
