import 'package:yildiz_kadro/features/evaluation/domain/evaluation_result.dart';
import 'package:yildiz_kadro/features/group_task/data/group_task_profiles.dart';
import 'package:yildiz_kadro/features/group_task/domain/day2_rehearsal.dart';
import 'package:yildiz_kadro/features/group_task/domain/group_task_profile.dart';

Day2RehearsalSetup initializeDay2Rehearsal({
  required List<int> teamAIds,
  required List<int> teamBIds,
  required int captainAId,
  required int captainBId,
  required int lastPickedContestantId,
  required Map<int, EvaluationResult> evaluationResults,
}) {
  if (teamAIds.length != 7 || teamBIds.length != 7) {
    throw ArgumentError('Prova için iki adet 7 kişilik takım gerekli.');
  }
  final rolesA = assignTeamRoles(teamAIds, evaluationResults);
  final rolesB = assignTeamRoles(teamBIds, evaluationResults);
  return Day2RehearsalSetup(
    teamARoles: rolesA,
    teamBRoles: rolesB,
    teamAInitialMetrics: calculateInitialRehearsalMetrics(
      teamAIds,
      rolesA,
      evaluationResults,
    ),
    teamBInitialMetrics: calculateInitialRehearsalMetrics(
      teamBIds,
      rolesB,
      evaluationResults,
    ),
    teamACrisis: detectRehearsalCrisis(
      teamId: 'A',
      teamIds: teamAIds,
      roles: rolesA,
      lastPickedContestantId: lastPickedContestantId,
      evaluationResults: evaluationResults,
    ),
    teamBCrisis: detectRehearsalCrisis(
      teamId: 'B',
      teamIds: teamBIds,
      roles: rolesB,
      lastPickedContestantId: lastPickedContestantId,
      evaluationResults: evaluationResults,
    ),
  );
}

TeamRoleAssignments assignTeamRoles(
  List<int> teamIds,
  Map<int, EvaluationResult> results,
) {
  int select(
    Iterable<int> ids,
    double Function(int) fit,
    int Function(EvaluationResult) mainStat,
  ) {
    final candidates = ids.toList()
      ..sort((a, b) {
        final fitOrder = fit(b).compareTo(fit(a));
        if (fitOrder != 0) return fitOrder;
        final statOrder =
            mainStat(results[b]!).compareTo(mainStat(results[a]!));
        if (statOrder != 0) return statOrder;
        final overall = results[b]!.overall.compareTo(results[a]!.overall);
        return overall != 0 ? overall : a.compareTo(b);
      });
    return candidates.first;
  }

  final center = select(
    teamIds,
    (id) => _centerScore(id, results),
    (result) => result.stage,
  );
  final mainVocal = select(
    teamIds.where((id) => id != center),
    (id) => _vocalScore(id, results),
    (result) => result.vocal,
  );
  final danceLead = select(
    teamIds.where((id) => id != center && id != mainVocal),
    (id) => _danceScore(id, results),
    (result) => result.dance,
  );
  return TeamRoleAssignments(
    centerId: center,
    mainVocalId: mainVocal,
    danceLeadId: danceLead,
    groupMemberIds: List.unmodifiable(
      teamIds.where((id) => id != center && id != mainVocal && id != danceLead),
    ),
  );
}

double _centerScore(int id, Map<int, EvaluationResult> results) {
  final result = results[id]!;
  final profile = groupTaskProfiles[id]!;
  var score = result.stage * .70 + result.dance * .30;
  if (profile.primaryRole == GroupRole.stage) score += 5;
  if (profile.workStyle == WorkStyle.cameraSavvy) score += 3;
  if (profile.workStyle == WorkStyle.bold) score += 2;
  if (profile.workStyle == WorkStyle.competitive) score += 1;
  return score;
}

double _vocalScore(int id, Map<int, EvaluationResult> results) {
  final result = results[id]!;
  final profile = groupTaskProfiles[id]!;
  var score = result.vocal * .85 + result.stage * .15;
  if (profile.primaryRole == GroupRole.vocal) score += 5;
  if (profile.secondaryRole == GroupRole.vocal) score += 2;
  if (profile.workStyle == WorkStyle.calm ||
      profile.workStyle == WorkStyle.experienced) {
    score += 1;
  }
  if (profile.workStyle == WorkStyle.chaotic) score -= 1;
  return score;
}

double _danceScore(int id, Map<int, EvaluationResult> results) {
  final result = results[id]!;
  final profile = groupTaskProfiles[id]!;
  var score = result.dance * .80 + result.stage * .20;
  if (profile.primaryRole == GroupRole.dance) score += 5;
  if (profile.secondaryRole == GroupRole.dance) score += 2;
  if (profile.workStyle == WorkStyle.experienced) score += 2;
  if (profile.workStyle == WorkStyle.controlled) score += 1;
  if (profile.workStyle == WorkStyle.chaotic) score -= 1;
  return score;
}

RehearsalMetrics calculateInitialRehearsalMetrics(
  List<int> teamIds,
  TeamRoleAssignments roles,
  Map<int, EvaluationResult> results,
) {
  var compatibility = 0;
  for (var i = 0; i < teamIds.length; i++) {
    for (var j = i + 1; j < teamIds.length; j++) {
      compatibility += workStyleCompatibility(
        groupTaskProfiles[teamIds[i]]!.workStyle,
        groupTaskProfiles[teamIds[j]]!.workStyle,
      );
    }
  }
  double average(int Function(EvaluationResult) select) =>
      teamIds.map((id) => select(results[id]!)).reduce((a, b) => a + b) /
      teamIds.length;
  final styleValues = teamIds.map((id) => groupTaskProfiles[id]!.workStyle);
  final readinessStyleBonus = styleValues
      .where((style) =>
          style == WorkStyle.experienced || style == WorkStyle.controlled)
      .length;
  final energyStyleBonus = styleValues
      .where((style) => {
            WorkStyle.bold,
            WorkStyle.competitive,
            WorkStyle.playful,
            WorkStyle.spontaneous,
            WorkStyle.cameraSavvy,
          }.contains(style))
      .length;
  final roleReadiness = (results[roles.mainVocalId]!.vocal +
          results[roles.danceLeadId]!.dance +
          results[roles.centerId]!.stage) /
      3;
  return RehearsalMetrics(
    harmony: (75 + compatibility).clamp(65, 90),
    readiness: ((average((r) => r.vocal) + average((r) => r.dance)) * .3 +
            roleReadiness * .4 +
            readinessStyleBonus)
        .round()
        .clamp(70, 95),
    energy: (average((r) => r.stage).round() + energyStyleBonus).clamp(70, 95),
  );
}

RehearsalCrisis detectRehearsalCrisis({
  required String teamId,
  required List<int> teamIds,
  required TeamRoleAssignments roles,
  required int lastPickedContestantId,
  required Map<int, EvaluationResult> evaluationResults,
}) {
  final centerCandidates = teamIds.where((id) => id != roles.centerId).toList()
    ..sort((a, b) => _centerScore(b, evaluationResults)
        .compareTo(_centerScore(a, evaluationResults)));
  final centerChallenger = centerCandidates.first;
  if (_centerScore(roles.centerId, evaluationResults) -
          _centerScore(centerChallenger, evaluationResults) <=
      5) {
    return RehearsalCrisis(
      teamId: teamId,
      type: RehearsalCrisisType.centerConflict,
      primaryContestantId: roles.centerId,
      secondaryContestantId: centerChallenger,
      title: 'CENTER TARTIŞMASI',
      headline: 'İki yarışmacı da geri çekilmek istemiyor.',
      description: 'Center seçimi takımın görsel odağını ikiye böldü.',
    );
  }
  final vocalCandidates = teamIds
      .where((id) => id != roles.mainVocalId)
      .toList()
    ..sort((a, b) =>
        evaluationResults[b]!.vocal.compareTo(evaluationResults[a]!.vocal));
  final vocalChallenger = vocalCandidates.firstWhere(
    (id) =>
        (evaluationResults[roles.mainVocalId]!.vocal -
                    evaluationResults[id]!.vocal)
                .abs() <=
            6 ||
        groupTaskProfiles[id]!.secondaryRole == GroupRole.vocal,
    orElse: () => -1,
  );
  if (vocalChallenger != -1) {
    return RehearsalCrisis(
      teamId: teamId,
      type: RehearsalCrisisType.vocalConflict,
      primaryContestantId: roles.mainVocalId,
      secondaryContestantId: vocalChallenger,
      title: 'VOKAL PAYLAŞIMI',
      headline: 'İki güçlü ses, tek büyük bölüm.',
      description:
          'Kritik yüksek notanın kimde kalacağı prova temposunu düşürüyor.',
    );
  }
  const tenseStyles = {
    WorkStyle.chaotic,
    WorkStyle.spontaneous,
    WorkStyle.competitive,
    WorkStyle.bold,
  };
  final danceCandidates = teamIds
      .where((id) =>
          id != roles.danceLeadId &&
          tenseStyles.contains(groupTaskProfiles[id]!.workStyle))
      .toList()
    ..sort((a, b) =>
        evaluationResults[b]!.dance.compareTo(evaluationResults[a]!.dance));
  if (danceCandidates.isNotEmpty) {
    return RehearsalCrisis(
      teamId: teamId,
      type: RehearsalCrisisType.danceConflict,
      primaryContestantId: roles.danceLeadId,
      secondaryContestantId: danceCandidates.first,
      title: 'KOREOGRAFİ GERİLİMİ',
      headline: 'Tempo yükseldikçe prova bölünüyor.',
      description: 'Temiz koreografi ile sahnede özgürlük isteği çatışıyor.',
    );
  }
  if (teamIds.contains(lastPickedContestantId)) {
    return RehearsalCrisis(
      teamId: teamId,
      type: RehearsalCrisisType.lastPickPressure,
      primaryContestantId: lastPickedContestantId,
      title: 'KENDİNİ KANITLAMA BASKISI',
      headline: 'Takımın son seçimi provada fazla yükleniyor.',
      description: 'Kendini göstermek isterken hata yapma korkusu büyüyor.',
    );
  }
  return RehearsalCrisis(
    teamId: teamId,
    type: RehearsalCrisisType.generic,
    primaryContestantId: teamIds.first,
    title: 'PROVA TIKANDI',
    headline: 'Takım teknik olarak güçlü ama aynı anda hareket edemiyor.',
    description: 'Çalışma biçimleri aynı plana dönüşmekte zorlanıyor.',
  );
}

List<RehearsalChoice> choicesForCrisis(RehearsalCrisisType type) =>
    switch (type) {
      RehearsalCrisisType.centerConflict => const [
          RehearsalChoice(
              id: 'keep_center',
              title: 'ROLÜ KORU',
              description:
                  'Center değişmesin. Kaptanın ilk kararının arkasında dur.',
              narrative: 'Rol tartışması burada bitiyor.',
              harmonyModifier: 4,
              readinessModifier: 2,
              energyModifier: 0),
          RehearsalChoice(
              id: 'share_center',
              title: 'CENTER’I PAYLAŞTIR',
              description: 'İki yarışmacıya farklı bölümlerde center anı ver.',
              narrative: 'Sahnenin odağı artık tek kişide değil.',
              harmonyModifier: 2,
              readinessModifier: -1,
              energyModifier: 5),
        ],
      RehearsalCrisisType.vocalConflict => const [
          RehearsalChoice(
              id: 'keep_vocal',
              title: 'ANA VOKALİ KORU',
              description: 'Ana vokal kritik bölümleri taşımaya devam etsin.',
              narrative: 'Şarkının omurgası tek bir seste kaldı.',
              harmonyModifier: 1,
              readinessModifier: 4,
              energyModifier: 0),
          RehearsalChoice(
              id: 'share_high_note',
              title: 'YÜKSEK NOTAYI PAYLAŞTIR',
              description: 'Diğer güçlü sese kısa bir spotlight ver.',
              narrative: 'Kritik an iki güçlü ses arasında paylaşıldı.',
              harmonyModifier: 3,
              readinessModifier: -1,
              energyModifier: 3),
        ],
      RehearsalCrisisType.danceConflict => const [
          RehearsalChoice(
              id: 'clean_choreo',
              title: 'KOREOGRAFİYİ TEMİZ TUT',
              description: 'Dans liderinin planını koru.',
              narrative: 'Takım yeniden aynı tempoda buluştu.',
              harmonyModifier: 1,
              readinessModifier: 5,
              energyModifier: -1),
          RehearsalChoice(
              id: 'freestyle',
              title: 'SERBEST BÖLÜM EKLE',
              description: 'Kısa bir bireysel hareket alanı yarat.',
              narrative: 'Kontrollü plana küçük bir risk eklendi.',
              harmonyModifier: 2,
              readinessModifier: -2,
              energyModifier: 5),
        ],
      RehearsalCrisisType.lastPickPressure => const [
          RehearsalChoice(
              id: 'reduce_pressure',
              title: 'BASKIYI AZALT',
              description: 'Yarışmacının bölümünü biraz sadeleştir.',
              narrative: 'Baskı azaldı, prova yeniden akmaya başladı.',
              harmonyModifier: 3,
              readinessModifier: 4,
              energyModifier: -1),
          RehearsalChoice(
              id: 'star_moment',
              title: 'ONA BİR YILDIZ ANI VER',
              description: 'Kısa bir spotlight ile güvenini yükselt.',
              narrative: 'Son seçilen isim kendine ait bir an buldu.',
              harmonyModifier: 2,
              readinessModifier: -1,
              energyModifier: 5),
        ],
      RehearsalCrisisType.generic => const [
          RehearsalChoice(
              id: 'keep_plan',
              title: 'PLANA SADIK KALIN',
              description: 'Takımı yeniden ortak plana döndür.',
              narrative: 'Takım artık ne yapmak istediğini biliyor.',
              harmonyModifier: 2,
              readinessModifier: 4,
              energyModifier: 0),
          RehearsalChoice(
              id: 'take_risk',
              title: 'RİSK ALIN',
              description: 'Planı sadeleştirip enerjiyi yükselt.',
              narrative: 'Prova daha cesur bir yöne döndü.',
              harmonyModifier: 1,
              readinessModifier: -1,
              energyModifier: 5),
        ],
    };

Day2RehearsalOutcome resolveDay2Rehearsal({
  required Day2RehearsalSetup setup,
  required String playerTeamId,
  required String playerChoiceId,
  required int captainAId,
  required int captainBId,
}) {
  final playerCrisis =
      playerTeamId == 'A' ? setup.teamACrisis : setup.teamBCrisis;
  final captainCrisis =
      playerTeamId == 'A' ? setup.teamBCrisis : setup.teamACrisis;
  final playerChoice = choicesForCrisis(playerCrisis.type)
      .firstWhere((choice) => choice.id == playerChoiceId);
  final captainId = playerTeamId == 'A' ? captainBId : captainAId;
  final captainChoice = _captainChoice(
    crisis: captainCrisis,
    captainStyle: groupTaskProfiles[captainId]!.workStyle,
  );
  final teamAChoice = playerTeamId == 'A' ? playerChoice : captainChoice;
  final teamBChoice = playerTeamId == 'B' ? playerChoice : captainChoice;
  return Day2RehearsalOutcome(
    playerInterventionTeamId: playerTeamId,
    playerCrisisType: playerCrisis.type,
    playerChoice: playerChoice,
    captainResolutionTeamId: playerTeamId == 'A' ? 'B' : 'A',
    captainChoice: captainChoice,
    teamAFinalMetrics: _applyChoice(
      setup.teamAInitialMetrics,
      teamAChoice,
      fullStrength: playerTeamId == 'A',
    ),
    teamBFinalMetrics: _applyChoice(
      setup.teamBInitialMetrics,
      teamBChoice,
      fullStrength: playerTeamId == 'B',
    ),
  );
}

RehearsalChoice _captainChoice({
  required RehearsalCrisis crisis,
  required WorkStyle captainStyle,
}) {
  final choices = choicesForCrisis(crisis.type);
  const risky = {
    WorkStyle.bold,
    WorkStyle.competitive,
    WorkStyle.spontaneous,
    WorkStyle.playful,
    WorkStyle.cameraSavvy,
    WorkStyle.chaotic,
  };
  if (risky.contains(captainStyle)) return choices[1];
  if (captainStyle == WorkStyle.social || captainStyle == WorkStyle.sensitive) {
    return choices
        .reduce((a, b) => a.harmonyModifier >= b.harmonyModifier ? a : b);
  }
  return choices[0];
}

RehearsalMetrics _applyChoice(
  RehearsalMetrics initial,
  RehearsalChoice choice, {
  required bool fullStrength,
}) {
  int modifier(int value) => fullStrength ? value : (value * .65).round();
  return RehearsalMetrics(
    harmony:
        (initial.harmony + modifier(choice.harmonyModifier)).clamp(60, 100),
    readiness:
        (initial.readiness + modifier(choice.readinessModifier)).clamp(60, 100),
    energy: (initial.energy + modifier(choice.energyModifier)).clamp(60, 100),
  );
}

int workStyleCompatibility(WorkStyle a, WorkStyle b) {
  const values = <(WorkStyle, WorkStyle), int>{
    (WorkStyle.direct, WorkStyle.controlled): 1,
    (WorkStyle.direct, WorkStyle.chaotic): -1,
    (WorkStyle.competitive, WorkStyle.bold): 2,
    (WorkStyle.social, WorkStyle.sensitive): 2,
    (WorkStyle.calm, WorkStyle.chaotic): -1,
    (WorkStyle.observant, WorkStyle.spontaneous): 1,
    (WorkStyle.playful, WorkStyle.social): 2,
    (WorkStyle.experienced, WorkStyle.controlled): 2,
  };
  return values[(a, b)] ?? values[(b, a)] ?? 0;
}

String rehearsalLabel(int score) {
  if (score >= 90) return 'SAHNEYE HAZIR';
  if (score >= 85) return 'GÜÇLÜ HAZIRLIK';
  if (score >= 80) return 'DENGELİ';
  if (score >= 75) return 'SORU İŞARETLERİ VAR';
  return 'RİSKLİ PROVA';
}
