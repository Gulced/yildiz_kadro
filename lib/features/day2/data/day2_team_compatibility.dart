import 'package:yildiz_kadro/l10n/l10n.dart';
import 'package:flutter/widgets.dart';
import 'package:yildiz_kadro/features/evaluation/domain/evaluation_result.dart';
import 'package:yildiz_kadro/features/group_task/data/group_task_profiles.dart';
import 'package:yildiz_kadro/features/group_task/data/day2_rehearsal_engine.dart';
import 'package:yildiz_kadro/features/group_task/domain/group_task_profile.dart';

class CandidateTeamEvaluation {
  const CandidateTeamEvaluation({
    required this.compatibility,
    required this.risk,
    required this.strengths,
    required this.concerns,
    required this.relationshipNotes,
    this.strengthsEn = const [],
    this.concernsEn = const [],
    this.relationshipNotesEn = const {},
  });
  final int compatibility;
  final int risk;
  final List<String> strengths;
  final List<String> concerns;
  final Map<int, String> relationshipNotes;
  final List<String> strengthsEn;
  final List<String> concernsEn;
  final Map<int, String> relationshipNotesEn;

  List<String> localizedStrengths(BuildContext context) =>
      isAppEnglish(context) && strengthsEn.isNotEmpty ? strengthsEn : strengths;

  List<String> localizedConcerns(BuildContext context) =>
      isAppEnglish(context) && concernsEn.isNotEmpty ? concernsEn : concerns;

  Map<int, String> localizedRelationshipNotes(BuildContext context) =>
      isAppEnglish(context) && relationshipNotesEn.isNotEmpty
          ? relationshipNotesEn
          : relationshipNotes;
}

CandidateTeamEvaluation evaluateCandidateForTeam({
  required int candidateId,
  required List<int> currentTeamIds,
  required Map<int, EvaluationResult> results,
}) {
  if (currentTeamIds.isEmpty || currentTeamIds.contains(candidateId)) {
    throw ArgumentError('Aday ve mevcut takım geçersiz.');
  }
  final candidate = results[candidateId]!;
  final profile = groupTaskProfiles[candidateId]!;
  final pairScores = <int, int>{
    for (final id in currentTeamIds)
      id: workStyleCompatibility(
        profile.workStyle,
        groupTaskProfiles[id]!.workStyle,
      ),
  };
  final compatibility = (70 +
          pairScores.values.fold<int>(0, (sum, score) => sum + score) *
              3 ~/
              currentTeamIds.length)
      .clamp(45, 95);
  double average(int Function(EvaluationResult) pick) =>
      currentTeamIds.map((id) => pick(results[id]!)).reduce((a, b) => a + b) /
      currentTeamIds.length;
  final vocalGap = average((value) => value.vocal) < 84;
  final danceGap = average((value) => value.dance) < 84;
  final stageGap = average((value) => value.stage) < 84;
  final samePrimary = currentTeamIds
      .where((id) => groupTaskProfiles[id]!.primaryRole == profile.primaryRole)
      .length;
  final strengths = <String>[];
  final strengthsEn = <String>[];
  if (vocalGap && candidate.vocal >= 84) {
    strengths.add('Takımın eksik vokal gücünü tamamlıyor.');
    strengthsEn.add('Supplements the team’s missing vocal power.');
  }
  if (danceGap && candidate.dance >= 84) {
    strengths.add('Dans ortalamasını belirgin biçimde yükseltiyor.');
    strengthsEn.add('Noticeably elevates the squad’s dance average.');
  }
  if (stageGap && candidate.stage >= 84) {
    strengths.add('Takımın sahne görünürlüğünü güçlendiriyor.');
    strengthsEn.add('Boosts the team’s stage presence and visibility.');
  }
  if (pairScores.values.any((value) => value >= 2)) {
    strengths.add('En az bir üyeyle çalışma tarzı birbirini tamamlıyor.');
    strengthsEn.add('Work style directly complements at least one teammate.');
  }
  if (strengths.isEmpty) {
    strengths.add('Takımın genel performans derinliğini artırıyor.');
    strengthsEn.add('Deepens the squad’s overall performance depth.');
  }
  final concerns = <String>[];
  final concernsEn = <String>[];
  if (samePrimary >= 2) {
    concerns.add('Aynı ana role aday çok sayıda yarışmacı var.');
    concernsEn.add('Multiple candidates competing for the same primary role.');
  }
  if (pairScores.values.any((value) => value <= -2)) {
    concerns.add('Bazı üyelerle çalışma tarzı çatışabilir.');
    concernsEn.add('Work styles may clash with certain teammates.');
  }
  if (!vocalGap && profile.primaryRole == GroupRole.vocal) {
    concerns.add('Vokal hattında bölüm paylaşımı gerekecek.');
    concernsEn.add('Line distribution compromises needed in vocal line.');
  }
  if (!stageGap && profile.primaryRole == GroupRole.stage) {
    concerns.add('Görünürlük rekabeti oluşabilir.');
    concernsEn.add('Potential competition for stage visibility.');
  }
  if (concerns.isEmpty) {
    concerns.add('Belirgin bir rol çatışması görünmüyor.');
    concernsEn.add('No obvious role conflict detected.');
  }
  final notes = <int, String>{
    for (final entry in pairScores.entries)
      entry.key: entry.value >= 2
          ? 'Birbirini tamamlayabilir.'
          : entry.value <= -2
              ? 'Çalışma tarzları çatışabilir.'
              : groupTaskProfiles[entry.key]!.primaryRole == profile.primaryRole
                  ? 'Rol ve görünürlük paylaşımı gerekebilir.'
                  : 'Dengeli bir eşleşme.',
  };
  final notesEn = <int, String>{
    for (final entry in pairScores.entries)
      entry.key: entry.value >= 2
          ? 'Can complement each other well.'
          : entry.value <= -2
              ? 'Work styles might clash.'
              : groupTaskProfiles[entry.key]!.primaryRole == profile.primaryRole
                  ? 'May require sharing roles and spotlight.'
                  : 'A balanced pairing.',
  };
  return CandidateTeamEvaluation(
    compatibility: compatibility,
    risk: (100 - compatibility + samePrimary * 6).clamp(5, 80),
    strengths: List.unmodifiable(strengths),
    concerns: List.unmodifiable(concerns),
    relationshipNotes: Map.unmodifiable(notes),
    strengthsEn: List.unmodifiable(strengthsEn),
    concernsEn: List.unmodifiable(concernsEn),
    relationshipNotesEn: Map.unmodifiable(notesEn),
  );
}
