import 'package:yildiz_kadro/l10n/l10n.dart';
import 'package:flutter/widgets.dart';
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

String leadershipCommentFor(Contestant contestant, BuildContext context) {
  final isEn = isAppEnglish(context);
  final identity = identityFor(contestant);
  if (!isEn) {
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
  } else {
    final strength = identity.leadership >= 80
        ? 'Listens to the team and provides steady, reassuring direction.'
        : identity.visibility >= 85
            ? 'Never hesitates in crucial moments and commands the stage direction.'
            : 'Establishes quiet leadership and catches subtle details.';
    final risk = identity.competition >= 80
        ? 'However, competitive drive might harden her decisions excessively.'
        : identity.teamwork < 65
            ? 'However, she may struggle to align varying work tempos.'
            : identity.leadership < 65
                ? 'However, she might delay having the final say in a crisis.'
                : 'However, taking on everyone’s burden risks draining her own energy.';
    return '$strength $risk';
  }
}

String roleSuitabilityFor(
  Contestant contestant,
  String role,
  BuildContext context,
) {
  final isEn = isAppEnglish(context);
  final identity = identityFor(contestant);
  final score = role.contains('VOKAL') || role.contains('VOCAL')
      ? contestant.vocal
      : role.contains('DANCER') ||
              role.contains('DANS') ||
              role.contains('DANCE')
          ? contestant.dance
          : contestant.stage;
  final characterBonus = role == 'CENTER' || role == 'MERKEZ'
      ? identity.visibility
      : role.startsWith('LEAD') || role.startsWith('KAPTAN')
          ? identity.leadership
          : identity.teamwork;
  final fit = (score * .7 + characterBonus * .3).round();
  if (!isEn) {
    if (fit >= 86) {
      return '★ GÜÇLÜ UYUM · Karakteri ve yeteneği bu rolü taşıyor.';
    }
    if (fit >= 76) return 'DENGELİ UYUM · Prova sonucu belirleyici olacak.';
    return 'RİSKLİ TERCİH · Bu rol daha fazla hazırlık isteyecek.';
  } else {
    if (fit >= 86) {
      return '★ STRONG FIT · Her skills and disposition excel here.';
    }
    if (fit >= 76) return 'BALANCED FIT · Rehearsal synergy will be decisive.';
    return 'RISKY CHOICE · This role demands substantial additional prep.';
  }
}

String localizedHook(Contestant c, BuildContext context) {
  final isEn = isAppEnglish(context);
  final style = groupTaskProfiles[c.id]!.workStyle;
  if (!isEn) return _hook(c, style);
  return switch (style) {
    WorkStyle.competitive => 'Pressure fuels her competitive drive and focus.',
    WorkStyle.calm =>
      'Technically skilled; requires patience to step into the spotlight.',
    WorkStyle.social =>
      'Naturally defuses backstage tension within the ensemble.',
    WorkStyle.controlled =>
      'Quiet and rigorously disciplined; hates being caught unprepared.',
    WorkStyle.cameraSavvy =>
      'Her stage energy ignites as soon as the camera turns on.',
    WorkStyle.chaotic =>
      'High raw natural talent; rehearsal focus fluctuates day by day.',
    WorkStyle.sensitive =>
      'Feels critiques deeply, but flourishes with constructive mentorship.',
    WorkStyle.bold =>
      'Unfazed by sharing the stage; refuses to fade into the background.',
    _ => c.shortBackground,
  };
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

String localizedGoal(Contestant c, BuildContext context) {
  final isEn = isAppEnglish(context);
  if (!isEn) {
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
  } else {
    if (c.primaryRole.contains('Vokal') || c.primaryRole.contains('Vocal')) {
      return 'Anchor the debut lineup with reliable, powerhouse vocals.';
    }
    if (c.primaryRole.contains('Dans') || c.primaryRole.contains('Dance')) {
      return 'Set the performance benchmark for the entire group.';
    }
    if (c.primaryRole.contains('Merkez') || c.primaryRole.contains('Center')) {
      return 'Become the unforgettable center face of the debut stage.';
    }
    return 'Emerge as a versatile star who transcends any single role.';
  }
}

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
