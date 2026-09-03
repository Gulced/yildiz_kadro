import 'package:yildiz_kadro/l10n/l10n.dart';
import 'package:flutter/widgets.dart';
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
  TeamRoleAssignments? teamARoles,
  TeamRoleAssignments? teamBRoles,
}) {
  if (teamAIds.length != 7 || teamBIds.length != 7) {
    throw ArgumentError('Prova için iki adet 7 kişilik takım gerekli.');
  }
  final rolesA = teamARoles ?? assignTeamRoles(teamAIds, evaluationResults);
  final rolesB = teamBRoles ?? assignTeamRoles(teamBIds, evaluationResults);
  if (!_validPlayerRoles(teamAIds, rolesA) ||
      !_validPlayerRoles(teamBIds, rolesB)) {
    throw ArgumentError('Oyuncu rol dağılımı geçersiz.');
  }
  final crisisA = detectRehearsalCrisis(
    teamId: 'A',
    teamIds: teamAIds,
    roles: rolesA,
    lastPickedContestantId: lastPickedContestantId,
    evaluationResults: evaluationResults,
  );
  final crisisB = detectRehearsalCrisis(
    teamId: 'B',
    teamIds: teamBIds,
    roles: rolesB,
    lastPickedContestantId: lastPickedContestantId,
    evaluationResults: evaluationResults,
    excludedTypes: {crisisA.type},
  );
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
    teamACrisis: crisisA,
    teamBCrisis: crisisB,
  );
}

bool _validPlayerRoles(List<int> teamIds, TeamRoleAssignments roles) {
  final specialists = {roles.centerId, roles.mainVocalId, roles.danceLeadId};
  final detailedIds =
      roles.roleSlots.map((entry) => entry.contestantId).toSet();
  final detailedValid = roles.roleSlots.isEmpty ||
      (roles.roleSlots.length == teamIds.length &&
          detailedIds.length == teamIds.length &&
          detailedIds.containsAll(teamIds));
  return detailedValid &&
      specialists.length == 3 &&
      teamIds.toSet().containsAll(specialists) &&
      roles.groupMemberIds.toSet().length == 4 &&
      specialists.union(roles.groupMemberIds.toSet()).length == 7 &&
      teamIds.toSet().containsAll(roles.groupMemberIds);
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
      .where(
        (style) =>
            style == WorkStyle.experienced || style == WorkStyle.controlled,
      )
      .length;
  final energyStyleBonus = styleValues
      .where(
        (style) => {
          WorkStyle.bold,
          WorkStyle.competitive,
          WorkStyle.playful,
          WorkStyle.spontaneous,
          WorkStyle.cameraSavvy,
        }.contains(style),
      )
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
  Set<RehearsalCrisisType> excludedTypes = const {},
}) {
  final centerCandidates = teamIds.where((id) => id != roles.centerId).toList()
    ..sort(
      (a, b) => _centerScore(
        b,
        evaluationResults,
      ).compareTo(_centerScore(a, evaluationResults)),
    );
  final centerChallenger = centerCandidates.first;
  if (!excludedTypes.contains(RehearsalCrisisType.centerConflict) &&
      _centerScore(roles.centerId, evaluationResults) -
              _centerScore(centerChallenger, evaluationResults) <=
          5) {
    return RehearsalCrisis(
      teamId: teamId,
      type: RehearsalCrisisType.centerConflict,
      primaryContestantId: roles.centerId,
      secondaryContestantId: centerChallenger,
      title: 'CENTER TARTIŞMASI',
      titleEn: 'CENTER DISPUTE',
      headline: 'İki yarışmacı da geri çekilmek istemiyor.',
      headlineEn: 'Neither contestant wants to step back.',
      description: 'Center seçimi takımın görsel odağını ikiye böldü.',
      descriptionEn: 'Center selection split the team’s visual focus.',
    );
  }
  final vocalCandidates = teamIds
      .where((id) => id != roles.mainVocalId)
      .toList()
    ..sort(
      (a, b) =>
          evaluationResults[b]!.vocal.compareTo(evaluationResults[a]!.vocal),
    );
  final vocalChallenger = vocalCandidates.firstWhere(
    (id) =>
        (evaluationResults[roles.mainVocalId]!.vocal -
                    evaluationResults[id]!.vocal)
                .abs() <=
            6 ||
        groupTaskProfiles[id]!.secondaryRole == GroupRole.vocal,
    orElse: () => -1,
  );
  if (vocalChallenger != -1 &&
      !excludedTypes.contains(RehearsalCrisisType.vocalConflict)) {
    return RehearsalCrisis(
      teamId: teamId,
      type: RehearsalCrisisType.vocalConflict,
      primaryContestantId: roles.mainVocalId,
      secondaryContestantId: vocalChallenger,
      title: 'VOKAL PAYLAŞIMI',
      titleEn: 'VOCAL DISTRIBUTION',
      headline: 'İki güçlü ses, tek büyük bölüm.',
      headlineEn: 'Two massive voices, one climactic line.',
      description:
          'Kritik yüksek notanın kimde kalacağı prova temposunu düşürüyor.',
      descriptionEn:
          'Debating who carries the high note is slowing down rehearsal momentum.',
    );
  }
  const tenseStyles = {
    WorkStyle.chaotic,
    WorkStyle.spontaneous,
    WorkStyle.competitive,
    WorkStyle.bold,
  };
  final danceCandidates = teamIds
      .where(
        (id) =>
            id != roles.danceLeadId &&
            tenseStyles.contains(groupTaskProfiles[id]!.workStyle),
      )
      .toList()
    ..sort(
      (a, b) => evaluationResults[b]!.dance.compareTo(
            evaluationResults[a]!.dance,
          ),
    );
  if (danceCandidates.isNotEmpty &&
      !excludedTypes.contains(RehearsalCrisisType.danceConflict)) {
    return RehearsalCrisis(
      teamId: teamId,
      type: RehearsalCrisisType.danceConflict,
      primaryContestantId: roles.danceLeadId,
      secondaryContestantId: danceCandidates.first,
      title: 'KOREOGRAFİ GERİLİMİ',
      titleEn: 'CHOREOGRAPHY TENSION',
      headline: 'Tempo yükseldikçe prova bölünüyor.',
      headlineEn: 'As the tempo accelerates, rehearsal fragments.',
      description: 'Temiz koreografi ile sahnede özgürlük isteği çatışıyor.',
      descriptionEn:
          'Clean synchronized formations clash with demands for expressive freedom.',
    );
  }
  if (teamIds.contains(lastPickedContestantId) &&
      !excludedTypes.contains(RehearsalCrisisType.lastPickPressure)) {
    return RehearsalCrisis(
      teamId: teamId,
      type: RehearsalCrisisType.lastPickPressure,
      primaryContestantId: lastPickedContestantId,
      title: 'KENDİNİ KANITLAMA BASKISI',
      titleEn: 'PROVE-YOURSELF PRESSURE',
      headline: 'Takımın son seçimi provada fazla yükleniyor.',
      headlineEn: 'The squad’s final draft pick is burning out in rehearsal.',
      description: 'Kendini göstermek isterken hata yapma korkusu büyüyor.',
      descriptionEn:
          'Trying too hard to stand out is spiraling into fear of mistakes.',
    );
  }
  final compatibility = calculateInitialRehearsalMetrics(
    teamIds,
    roles,
    evaluationResults,
  ).harmony;
  if (!excludedTypes.contains(RehearsalCrisisType.positiveDevelopment) &&
      (compatibility >= 78 ||
          excludedTypes.contains(RehearsalCrisisType.generic))) {
    final strongest = teamIds.toList()
      ..sort(
        (a, b) => evaluationResults[b]!.overall.compareTo(
              evaluationResults[a]!.overall,
            ),
      );
    return RehearsalCrisis(
      teamId: teamId,
      type: RehearsalCrisisType.positiveDevelopment,
      primaryContestantId: strongest.first,
      secondaryContestantId: strongest[1],
      title: 'BEKLENMEDİK UYUM',
      titleEn: 'UNEXPECTED CHEMISTRY',
      headline: 'İki farklı profil provada ortak bir ritim buldu.',
      headlineEn:
          'Two starkly different profiles discovered a shared groove in rehearsal.',
      description: 'Takımın güçlü üyeleri birbirinin alanını açmaya başladı.',
      descriptionEn:
          'The team’s top members have begun opening up stage space for each other.',
    );
  }
  return RehearsalCrisis(
    teamId: teamId,
    type: RehearsalCrisisType.generic,
    primaryContestantId: teamIds.first,
    title: 'PROVA TIKANDI',
    titleEn: 'REHEARSAL STALEMATE',
    headline: 'Takım teknik olarak güçlü ama aynı anda hareket edemiyor.',
    headlineEn:
        'Squad is technically proficient but failing to move as one unit.',
    description: 'Çalışma biçimleri aynı plana dönüşmekte zorlanıyor.',
    descriptionEn:
        'Divergent rehearsal habits struggle to merge into a single vision.',
  );
}

List<RehearsalChoice> choicesForCrisis(
  RehearsalCrisisType type,
) =>
    switch (type) {
      RehearsalCrisisType.centerConflict => const [
          RehearsalChoice(
            id: 'keep_center',
            title: 'ROLÜ KORU',
            titleEn: 'KEEP THE ROLE',
            description:
                'Center değişmesin. Kaptanın ilk kararının arkasında dur.',
            descriptionEn:
                'Keep the center. Stand behind the captain’s original choice.',
            narrative: 'Rol tartışması burada bitiyor.',
            narrativeEn: 'Role debate ends here.',
            harmonyModifier: 4,
            readinessModifier: 2,
            energyModifier: 0,
          ),
          RehearsalChoice(
            id: 'share_center',
            title: 'CENTER’I PAYLAŞTIR',
            titleEn: 'SPLIT CENTER TIME',
            description: 'İki yarışmacıya farklı bölümlerde center anı ver.',
            descriptionEn:
                'Give both members center spotlights across different song sections.',
            narrative: 'Sahnenin odağı artık tek kişide değil.',
            narrativeEn:
                'Stage focus is no longer confined to a single member.',
            harmonyModifier: 2,
            readinessModifier: -1,
            energyModifier: 5,
          ),
        ],
      RehearsalCrisisType.vocalConflict => const [
          RehearsalChoice(
            id: 'keep_vocal',
            title: 'ANA VOKALİ KORU',
            titleEn: 'BACK LEAD VOCAL',
            description: 'Ana vokal kritik bölümleri taşımaya devam etsin.',
            descriptionEn: 'Lead vocal continues carrying the critical climax.',
            narrative: 'Şarkının omurgası tek bir seste kaldı.',
            narrativeEn: 'Track backbone remains anchored in a single voice.',
            harmonyModifier: 1,
            readinessModifier: 4,
            energyModifier: 0,
          ),
          RehearsalChoice(
            id: 'share_high_note',
            title: 'YÜKSEK NOTAYI PAYLAŞTIR',
            titleEn: 'SPLIT THE CLIMAX',
            description: 'Diğer güçlü sese kısa bir spotlight ver.',
            descriptionEn: 'Give the challenger a distinct vocal spotlight.',
            narrative: 'Kritik an iki güçlü ses arasında paylaşıldı.',
            narrativeEn:
                'The climactic moment is shared between two powerhouse voices.',
            harmonyModifier: 3,
            readinessModifier: -1,
            energyModifier: 3,
          ),
        ],
      RehearsalCrisisType.danceConflict => const [
          RehearsalChoice(
            id: 'clean_choreo',
            title: 'KOREOGRAFİYİ TEMİZ TUT',
            titleEn: 'KEEP CHOREO CLEAN',
            description: 'Dans liderinin planını koru.',
            descriptionEn: 'Protect the dance leader’s formation blueprint.',
            narrative: 'Takım yeniden aynı tempoda buluştu.',
            narrativeEn:
                'The team reconnects to an identical synchronized tempo.',
            harmonyModifier: 1,
            readinessModifier: 5,
            energyModifier: -1,
          ),
          RehearsalChoice(
            id: 'freestyle',
            title: 'SERBEST BÖLÜM EKLE',
            titleEn: 'INJECT FREESTYLE',
            description: 'Kısa bir bireysel hareket alanı yarat.',
            descriptionEn:
                'Carve out short pockets of individual freestyle expression.',
            narrative: 'Kontrollü plana küçük bir risk eklendi.',
            narrativeEn:
                'A calculated spark of risk is introduced into the controlled routine.',
            harmonyModifier: 2,
            readinessModifier: -2,
            energyModifier: 5,
          ),
        ],
      RehearsalCrisisType.lastPickPressure => const [
          RehearsalChoice(
            id: 'reduce_pressure',
            title: 'BASKIYI AZALT',
            titleEn: 'EASE THE PRESSURE',
            description: 'Yarışmacının bölümünü biraz sadeleştir.',
            descriptionEn: 'Streamline and simplify their routine section.',
            narrative: 'Baskı azaldı, prova yeniden akmaya başladı.',
            narrativeEn:
                'Pressure lifts; rehearsal starts flowing smoothly again.',
            harmonyModifier: 3,
            readinessModifier: 4,
            energyModifier: -1,
          ),
          RehearsalChoice(
            id: 'star_moment',
            title: 'ONA BİR YILDIZ ANI VER',
            titleEn: 'GIFT A STAR MOMENT',
            description: 'Kısa bir spotlight ile güvenini yükselt.',
            descriptionEn:
                'Elevate their confidence with a dedicated solo spotlight.',
            narrative: 'Son seçilen isim kendine ait bir an buldu.',
            narrativeEn:
                'The last drafted talent finds a dedicated moment that belongs to her.',
            harmonyModifier: 2,
            readinessModifier: -1,
            energyModifier: 5,
          ),
        ],
      RehearsalCrisisType.positiveDevelopment => const [
          RehearsalChoice(
            id: 'protect_duo',
            title: 'İKİLİYİ KORU',
            titleEn: 'SHOWCASE THE DUO',
            description: 'Uyumlu anları performansın merkezinde tut.',
            descriptionEn:
                'Center their synchronized synergy at the heart of the performance.',
            narrative: 'Beklenmedik ikili takımın güvenini yükseltti.',
            narrativeEn:
                'The unexpected duo elevates the entire team’s collective morale.',
            harmonyModifier: 5,
            readinessModifier: 2,
            energyModifier: 2,
          ),
          RehearsalChoice(
            id: 'spread_energy',
            title: 'ENERJİYİ TAKIMA YAY',
            titleEn: 'SPREAD THE VIBE',
            description: 'İkilinin yöntemini bütün formasyona taşı.',
            descriptionEn:
                'Channel their cooperative momentum across the entire formation.',
            narrative: 'Olumlu prova enerjisi bütün takıma yayıldı.',
            narrativeEn:
                'Positive rehearsal synergy radiates across the entire squad.',
            harmonyModifier: 3,
            readinessModifier: 4,
            energyModifier: 1,
          ),
        ],
      RehearsalCrisisType.generic => const [
          RehearsalChoice(
            id: 'keep_plan',
            title: 'PLANA SADIK KALIN',
            titleEn: 'STICK TO THE PLAN',
            description: 'Takımı yeniden ortak plana döndür.',
            descriptionEn:
                'Steer the squad firmly back to the agreed blueprint.',
            narrative: 'Takım artık ne yapmak istediğini biliyor.',
            narrativeEn:
                'The squad regains crystal-clear clarity on their execution.',
            harmonyModifier: 2,
            readinessModifier: 4,
            energyModifier: 0,
          ),
          RehearsalChoice(
            id: 'take_risk',
            title: 'RİSK ALIN',
            titleEn: 'TAKE A RISK',
            description: 'Planı sadeleştirip enerjiyi yükselt.',
            descriptionEn:
                'Streamline the blueprint and turn up the raw emotional volume.',
            narrative: 'Prova daha cesur bir yöne döndü.',
            narrativeEn:
                'Rehearsal pivots in a daring, electrifying direction.',
            harmonyModifier: 1,
            readinessModifier: -1,
            energyModifier: 5,
          ),
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

Day2RehearsalOutcome resolveBothDay2Rehearsals({
  required Day2RehearsalSetup setup,
  required String teamAChoiceId,
  required String teamBChoiceId,
}) {
  final choiceA = choicesForCrisis(setup.teamACrisis.type)
      .firstWhere((choice) => choice.id == teamAChoiceId);
  final choiceB = choicesForCrisis(setup.teamBCrisis.type)
      .firstWhere((choice) => choice.id == teamBChoiceId);
  return Day2RehearsalOutcome(
    playerInterventionTeamId: 'BOTH',
    playerCrisisType: setup.teamACrisis.type,
    playerChoice: choiceA,
    captainResolutionTeamId: 'NONE',
    captainChoice: choiceB,
    teamAFinalMetrics: _applyChoice(
      setup.teamAInitialMetrics,
      choiceA,
      fullStrength: true,
    ),
    teamBFinalMetrics: _applyChoice(
      setup.teamBInitialMetrics,
      choiceB,
      fullStrength: true,
    ),
    playerChoicesByTeam: Map.unmodifiable({'A': choiceA, 'B': choiceB}),
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
    return choices.reduce(
      (a, b) => a.harmonyModifier >= b.harmonyModifier ? a : b,
    );
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
    harmony: (initial.harmony + modifier(choice.harmonyModifier)).clamp(
      60,
      100,
    ),
    readiness: (initial.readiness + modifier(choice.readinessModifier)).clamp(
      60,
      100,
    ),
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

String rehearsalLabel(int score, [BuildContext? context]) {
  final isEn = isAppEnglish(context);
  if (score >= 90) return isEn ? 'STAGE READY' : 'SAHNEYE HAZIR';
  if (score >= 85) return isEn ? 'STRONG READINESS' : 'GÜÇLÜ HAZIRLIK';
  if (score >= 80) return isEn ? 'BALANCED' : 'DENGELİ';
  if (score >= 75) return isEn ? 'UNRESOLVED QUESTIONS' : 'SORU İŞARETLERİ VAR';
  return isEn ? 'RISKY REHEARSAL' : 'RİSKLİ PROVA';
}
